# oj + nitro

A simple TanStack Start app with [lovablelabs/oj](https://github.com/lovablelabs/oj) and [`nitro/vite`](https://nitro.build/docs/vite) for universal deployment.

**Live (Vercel):** https://oj-nitro-lyart.vercel.app (client assets served from `/_vercel/immutable/` with immutable caching)

> [!NOTE]
> This is a preview deployment for [lovablelabs/oj#596](https://github.com/lovablelabs/oj/pull/596) latest binary build, stored brotli-compressed as `bin/oj.br` (over GitHub's 100 MB file limit) and unpacked by `bin/oj.mjs` on first run

## Dev

```sh
pnpm dev # http://localhost:3000
```

## Prod

```sh
pnpm build # Generates .output/
pnpm start # Runs node .output/server/index.mjs -> http://localhost:3000
```

## Build benchmark (oj vs vite)

`pnpm bench` ([`bench.sh`](./bench.sh), Linux + GNU time) builds this app with Nitro's `vercel` preset (immutable static files on) with `oj build` and `vite build`. It alternates the two tools, does 10 runs per mode after a warmup, and reports medians:

| tool | mode | wall (median, min-max) | cpu user+sys | max RSS |
|---|---|---|---|---|
| vite | cold | 1.42s (1.39-1.51) | 2.46s | 774 MiB |
| oj | cold | 2.52s (2.48-2.60) | 3.42s | 427 MiB |
| vite | warm | 1.20s (1.17-1.26) | 2.31s | 775 MiB |
| oj | warm | 0.99s (0.97-0.99) | 1.53s | 391 MiB |
| vite | edit | 1.20s (1.16-1.27) | 2.25s | 775 MiB |
| oj | edit | 1.32s (1.31-1.37) | 1.96s | 391 MiB |

<sub>i7-10700K, 16 CPUs, Linux 6.12; oj 0.4.4 (lovablelabs/oj#596), vite 8.3.0, Node 24.22.1, nitro 3.0.261103-rc.</sub>

Modes:
- **cold:** no caches at all (`.oj-cache`, `node_modules/.nitro`, `node_modules/.vite`, and Node's compile cache, which vite turns on). This is like a fresh CI build.
- **warm:** a rebuild with nothing changed; each tool keeps its own caches.
- **edit:** a rebuild after changing the content of a route file.

Notes:
- oj is about 1.8x slower than vite on a cold build, about 1.2x faster on a warm rebuild, and about 1.1x slower after an edit. It uses roughly half the peak memory, and less CPU in the warm and edit modes.
- The app is tiny, so the numbers are mostly startup and setup cost. They say nothing about how either tool scales.
- The outputs are equivalent but not identical. Both use the same preset, both put client assets under `/_vercel/immutable/`, both minify the client, and neither emits sourcemaps. The differences:
  - oj's asset hashes are 8 characters; vite's are 16.
  - oj's output targets `nodejs26.x`, because its embedded runtime reports Node 26; vite's targets `nodejs24.x`.
