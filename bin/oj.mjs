#!/usr/bin/env node
// Runs oj from bin/oj.br (brotli; the binary is over GitHub's 100 MB file
// limit), unpacked to bin/oj when it is missing or older than the archive.
import { spawn } from "node:child_process";
import fs from "node:fs";
import { fileURLToPath } from "node:url";
import zlib from "node:zlib";

const bin = fileURLToPath(new URL("./oj", import.meta.url));
const archive = fileURLToPath(new URL("./oj.br", import.meta.url));
const stale = () => {
  try {
    return fs.statSync(bin).mtimeMs < fs.statSync(archive).mtimeMs;
  } catch {
    return true;
  }
};
if (stale()) {
  const tmp = `${bin}.${process.pid}.tmp`;
  fs.writeFileSync(tmp, zlib.brotliDecompressSync(fs.readFileSync(archive)), { mode: 0o755 });
  fs.renameSync(tmp, bin);
}
const child = spawn(bin, process.argv.slice(2), { stdio: "inherit" });
for (const sig of ["SIGINT", "SIGTERM"]) process.on(sig, () => child.kill(sig));
child.on("exit", (code, signal) => (signal ? process.kill(process.pid, signal) : process.exit(code ?? 1)));
