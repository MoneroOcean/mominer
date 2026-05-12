"use strict";

const { spawn } = require("node:child_process");
const path = require("node:path");
const { perfTests } = require("./vectors");

const repoRoot = path.join(__dirname, "..");
const algo = process.argv[2];
const args = ["env"];

if (algo && !perfTests.some((definition) => definition.algo === algo)) {
  console.error(`Unknown perf algo: ${algo}`);
  console.error(`Available algos: ${perfTests.map((definition) => definition.algo).join(", ")}`);
  process.exit(1);
}

if (algo) args.push(`MOMINER_PERF_ALGO=${algo}`);

args.push(
  "node",
  "--require",
  "./tests/common/test_output_buffer.js",
  "--test",
  "--test-reporter=./tests/common/spec_reporter.js",
  "--test-concurrency=1",
  "tests/perf.js"
);

const child = spawn("./r.sh", args, {
  cwd: repoRoot,
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
