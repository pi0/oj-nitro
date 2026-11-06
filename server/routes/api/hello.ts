import { defineHandler } from "nitro";

// A Nitro server route (server/routes/), served at /api/hello.
export default defineHandler(() => ({ hello: "nitro", runtime: `node ${process.versions.node}` }));
