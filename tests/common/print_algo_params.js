"use strict";

const { spawn } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const repoRoot = path.join(__dirname, "..", "..");
const releaseExecutable = fs.existsSync(path.join(repoRoot, "mominer.exe"))
  ? path.join(repoRoot, "mominer.exe")
  : path.join(repoRoot, "mominer");
const command = fs.existsSync(releaseExecutable)
  ? [releaseExecutable, "algo_params"]
  : ["node", "mominer.js", "algo_params"];
const child = spawn(command[0], command.slice(1), {
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
