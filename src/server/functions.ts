import { createServerFn } from "@tanstack/react-start";
import { isMainThread } from "node:worker_threads";

// Where server code runs: under `oj dev` with nitro this is nitro's env-runner
// worker thread; in the built `.output` server it is the main thread.
export const getServerInfo = createServerFn({ method: "GET" }).handler(async () => {
  return {
    runtime: isMainThread ? "main-thread" : "worker-thread",
    node: process.version,
    pid: process.pid,
    time: new Date().toISOString(),
  };
});

export const greet = createServerFn({ method: "POST" })
  .validator((data: { name: string }) => data)
  .handler(async ({ data }) => {
    return { message: `Hello, ${data.name || "stranger"}!`, at: new Date().toISOString() };
  });
