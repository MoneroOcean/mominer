"use strict";

const { spawn } = require("node:child_process");
const path = require("node:path");

const repoRoot = path.join(__dirname, "..", "..");
let autoAlgoParamsPromise = null;

function quoteCommand(args) {
  return args
    .map((arg) => (/^[A-Za-z0-9_./:=+-]+$/.test(arg) ? arg : JSON.stringify(arg)))
    .join(" ");
}

function formatOutput(label, text) {
  return text ? `\n${label}:\n${text.trimEnd()}` : `\n${label}: <empty>`;
}

function formatFailure(title, args, result) {
  const exitStatus = result.error
    ? `error: ${result.error.message}`
    : `exit: ${result.code}${result.signal ? ` signal: ${result.signal}` : ""}`;

  return [
    title,
    `$ ${quoteCommand(["node", ...args])}`,
    exitStatus,
    formatOutput("stdout", result.stdout),
    formatOutput("stderr", result.stderr),
  ].join("\n");
}

function isMissingGpuOutput(result) {
  const output = `${result.stdout}\n${result.stderr}`;
  return /Unknown compute platform gpu|No device of requested type|No GPU|gpu[0-9]+.*not found|SYCL.*device/i.test(output);
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function runNode(args, options = {}) {
  const timeoutMs = options.timeoutMs || 5 * 60 * 1000;

  return new Promise((resolve) => {
    const child = spawn("node", args, {
      cwd: repoRoot,
      env: { ...process.env },
      stdio: ["ignore", "pipe", "pipe"],
    });

    const result = {
      code: null,
      signal: null,
      error: null,
      stdout: "",
      stderr: "",
    };
    let finished = false;

    const timeout = setTimeout(() => {
      if (finished) return;
      result.error = new Error(`Timed out after ${timeoutMs}ms`);
      child.kill("SIGKILL");
    }, timeoutMs);

    child.stdout.on("data", (chunk) => {
      result.stdout += chunk.toString("utf8");
    });
    child.stderr.on("data", (chunk) => {
      result.stderr += chunk.toString("utf8");
    });
    child.on("error", (error) => {
      result.error = error;
    });
    child.on("close", (code, signal) => {
      finished = true;
      clearTimeout(timeout);
      result.code = code;
      result.signal = signal;
      resolve(result);
    });
  });
}

async function getAutoAlgoParams() {
  if (!autoAlgoParamsPromise) {
    const args = ["tests/common/print_algo_params.js"];
    autoAlgoParamsPromise = runNode(args, { timeoutMs: 60 * 1000 })
      .then((result) => {
        if (result.error || result.code !== 0) {
          throw new Error(formatFailure("Unable to detect algo params", args, result));
        }

        const line = result.stdout
          .trim()
          .split(/\r?\n/)
          .reverse()
          .find((entry) => entry.startsWith("MOMINER_ALGO_PARAMS "));

        if (!line) {
          throw new Error(formatFailure("Algo params output did not contain JSON marker", args, result));
        }

        return JSON.parse(line.slice("MOMINER_ALGO_PARAMS ".length));
      });
  }

  return autoAlgoParamsPromise;
}

async function resolveBenchJob(definition) {
  const job = { ...definition.job };
  if (!definition.autoDev) return { job };

  const algoParams = await getAutoAlgoParams();
  const dev = algoParams[job.algo];
  if (dev) {
    job.dev = dev;
    return { job };
  }

  if (definition.gpu) {
    return { skipped: true, reason: "GPU device is not available in this environment" };
  }

  throw new Error(`No auto device config detected for ${job.algo}`);
}

async function runMinerTest(definition) {
  const job = { ...definition.job };
  const args = [
    "mominer.js",
    "test",
    job.algo,
    definition.expected,
    "--job",
    JSON.stringify(job),
  ];
  const result = await runNode(args, { timeoutMs: definition.timeoutMs });
  const output = `${result.stdout}\n${result.stderr}`;

  if (definition.gpu && isMissingGpuOutput(result)) {
    return { skipped: true, reason: "GPU device is not available in this environment" };
  }

  if (result.error || result.code !== 0) {
    throw new Error(formatFailure(`${definition.name} failed`, args, result));
  }
  if (!result.stdout.includes("PASSED") || /\bFAIL(?:ED)?\b/.test(output)) {
    throw new Error(formatFailure(`${definition.name} did not report a clean pass`, args, result));
  }

  return { skipped: false };
}

async function runMinerBench(definition) {
  const resolved = await resolveBenchJob(definition);
  if (resolved.skipped) return resolved;

  const job = resolved.job;
  const args = ["mominer.js", "bench", job.algo, "--job", JSON.stringify(job)];
  const timeoutMs = definition.timeoutMs || 150 * 1000;
  const hashratePattern = new RegExp(`Algo ${escapeRegExp(job.algo)} \\([^)]*\\) hashrate: ([0-9.]+) H\\/s`);

  return new Promise((resolve, reject) => {
    const child = spawn("node", args, {
      cwd: repoRoot,
      env: { ...process.env },
      stdio: ["ignore", "pipe", "pipe"],
    });
    const result = { code: null, signal: null, error: null, stdout: "", stderr: "" };
    let matchedHashrate = null;
    let stopping = false;

    const stop = () => {
      if (stopping) return;
      stopping = true;
      child.kill("SIGINT");
      setTimeout(() => child.kill("SIGKILL"), 5000).unref();
    };

    const timeout = setTimeout(() => {
      result.error = new Error(`Timed out after ${timeoutMs}ms`);
      stop();
    }, timeoutMs);

    const onData = (streamName, chunk) => {
      result[streamName] += chunk.toString("utf8");
      const match = `${result.stdout}\n${result.stderr}`.match(hashratePattern);
      if (match && !matchedHashrate) {
        matchedHashrate = Number.parseFloat(match[1]);
        stop();
      }
    };

    child.stdout.on("data", (chunk) => onData("stdout", chunk));
    child.stderr.on("data", (chunk) => onData("stderr", chunk));
    child.on("error", (error) => {
      result.error = error;
    });
    child.on("close", (code, signal) => {
      clearTimeout(timeout);
      result.code = code;
      result.signal = signal;

      if (matchedHashrate && matchedHashrate > 0) return resolve({ hashrate: matchedHashrate, dev: job.dev });
      if (definition.gpu && isMissingGpuOutput(result)) {
        return resolve({ skipped: true, reason: "GPU device is not available in this environment" });
      }

      reject(new Error(formatFailure(`${definition.name} did not report hashrate`, args, result)));
    });
  });
}

module.exports = {
  runMinerBench,
  runMinerTest,
};
