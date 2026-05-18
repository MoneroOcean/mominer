"use strict";

const { spawn } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const repoRoot = path.join(__dirname, "..");
const suites = {
  all: ["tests/all.js"],
  cpu: ["tests/cpu.js"],
  gpu: ["tests/gpu.js"],
  "sycl-cpu": ["tests/sycl_cpu.js"],
};

const suite = process.argv[2] || "all";
if (!suites[suite]) {
  console.error(`Unknown hash test suite: ${suite}`);
  process.exit(1);
}

const testArgs = [
  "--require",
  "./tests/common/test_output_buffer.js",
  "--test",
  "--test-reporter=./tests/common/spec_reporter.js",
  "--test-concurrency=1",
  ...suites[suite],
];

function isInsideRsh() {
  return process.env.MOMINER_R_SH === "1" || fs.existsSync("/.dockerenv");
}

let runner;
if (process.platform === "win32") {
  runner = { command: process.execPath, args: testArgs };
} else if (isInsideRsh()) {
  runner = { command: process.execPath, args: testArgs };
} else if (fs.existsSync(path.join(repoRoot, "r.sh"))) {
  runner = { command: "./r.sh", args: ["node", ...testArgs] };
} else if (fs.existsSync(path.join(repoRoot, "mominer")) || fs.existsSync(path.join(repoRoot, "mominer.exe"))) {
  runner = { command: process.execPath, args: testArgs };
} else {
  runner = { command: "./docker-mominer.sh", args: ["node", ...testArgs] };
}

const child = spawn(runner.command, runner.args, {
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
