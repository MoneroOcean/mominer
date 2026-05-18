"use strict";

const { spawn } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");
const { perfTests } = require("./vectors");

const repoRoot = path.join(__dirname, "..");
const algo = process.argv[2];
const testArgs = [
  "--require",
  "./tests/common/test_output_buffer.js",
  "--test",
  "--test-reporter=./tests/common/spec_reporter.js",
  "--test-concurrency=1",
  "tests/perf.js",
];
const testEnv = {};

if (algo && !perfTests.some((definition) => definition.algo === algo)) {
  console.error(`Unknown perf algo: ${algo}`);
  console.error(`Available algos: ${perfTests.map((definition) => definition.algo).join(", ")}`);
  process.exit(1);
}

if (algo) testEnv.MOMINER_PERF_ALGO = algo;

function isInsideRsh() {
  return process.env.MOMINER_R_SH === "1" || fs.existsSync("/.dockerenv");
}

let runner;
if (process.platform === "win32" || isInsideRsh()) {
  runner = { command: process.execPath, args: testArgs, env: testEnv };
} else if (fs.existsSync(path.join(repoRoot, "r.sh"))) {
  const args = ["env"];
  if (algo) args.push(`MOMINER_PERF_ALGO=${algo}`);
  runner = { command: "./r.sh", args: [...args, "node", ...testArgs] };
} else if (fs.existsSync(path.join(repoRoot, "mominer")) || fs.existsSync(path.join(repoRoot, "mominer.exe"))) {
  runner = { command: process.execPath, args: testArgs, env: testEnv };
} else {
  runner = { command: "./docker-mominer.sh", args: ["node", ...testArgs], env: testEnv };
}

const child = spawn(runner.command, runner.args, {
  cwd: repoRoot,
  env: { ...process.env, ...(runner.env || {}) },
  stdio: "inherit",
});

child.on("exit", (code, signal) => {
  if (signal) process.kill(process.pid, signal);
  process.exit(code === null ? 1 : code);
});

child.on("error", (error) => {
  console.error(error.message);
  process.exit(1);
});
