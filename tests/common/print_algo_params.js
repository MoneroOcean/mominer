"use strict";

const { spawn } = require("node:child_process");
const path = require("node:path");

const repoRoot = path.join(__dirname, "..", "..");
const child = spawn("node", ["mominer.js", "algo_params"], {
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
