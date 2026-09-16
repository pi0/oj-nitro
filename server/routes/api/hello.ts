import { defineHandler } from "nitro";

// A plain nitro server route, served next to the TanStack Start app.
export default defineHandler((event) => {
  return { hello: "from nitro", path: event.url.pathname, time: new Date().toISOString() };
});
