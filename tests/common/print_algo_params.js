"use strict";

const { spawn } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const repoRoot = path.join(__dirname, "..", "..");
const releaseExecutableNames = process.platform === "win32"
  ? ["mominer.exe", "mominer.cmd"]
  : ["mominer"];
const releaseExecutable = releaseExecutableNames
  .map((name) => path.join(repoRoot, name))
  .find((filePath) => fs.existsSync(filePath));

function quoteWindowsCmdArg(arg) {
  if (arg.length === 0) return '""';
  if (!/[\s"&|<>()^%]/.test(arg)) return arg;
  return `"${arg.replace(/"/g, '""')}"`;
}

const command = releaseExecutable
  ? /\.cmd$/i.test(releaseExecutable)
    ? [
        process.env.ComSpec || "cmd.exe",
        ["/d", "/s", "/c", [releaseExecutable, "algo_params"].map(quoteWindowsCmdArg).join(" ")],
      ]
    : [releaseExecutable, "algo_params"]
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
