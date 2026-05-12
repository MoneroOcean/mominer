"use strict";

const { spawn } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const repoRoot = path.join(__dirname, "..");
const testArgs = [
  "--require",
  "./tests/common/test_output_buffer.js",
  "--test",
  "--test-reporter=./tests/common/spec_reporter.js",
  "--test-concurrency=1",
  "tests/all.js",
];

let runner;
if (process.platform === "win32") {
  runner = { command: "node", args: testArgs };
} else if (fs.existsSync(path.join(repoRoot, "r.sh"))) {
  runner = { command: "./r.sh", args: ["node", ...testArgs] };
} else if (fs.existsSync(path.join(repoRoot, "mominer")) || fs.existsSync(path.join(repoRoot, "mominer.exe"))) {
  runner = { command: "node", args: testArgs };
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
