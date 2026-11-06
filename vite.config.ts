import { tanstackStart } from "@tanstack/react-start/plugin/vite";
import react from "@vitejs/plugin-react";
import { nitro } from "nitro/vite";

export default {
  plugins: [
    nitro({
      serverDir: "./server",
      // Hashed client assets under /_vercel/immutable/ (Nitro's buildAssetsDir), cached as immutable.
      vercel: { immutableStaticFiles: true },
    }),
    tanstackStart(),
    react(),
  ],
};
