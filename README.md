# oj + nitro

A simple TanStack Start app with [lovablelabs/oj](https://github.com/lovablelabs/oj) and [`nitro/vite`](https://nitro.build/docs/vite) for universal deployment.

## Dev

```sh
pnpm dev             # ./bin/oj dev .   -> http://localhost:3000
```

Expected:
- `/`: the loader's server info says `"runtime": "worker-thread"` (rendered in nitro's env-runner worker).
- "Hydrated: yes", the counter, and the **greet (POST)** / **server info (GET)** buttons (server functions from the browser).
- `/about`, client-side navigation, and editing `src/routes/about.tsx` (live reload).
- `/api/hello`: a nitro route from `server/routes/api/hello.ts`.
- `/robots.txt`: served from `public/`.

## Prod

```sh
pnpm build           # ./bin/oj build .  -> .output/ (nitro's output, not dist/)
pnpm start           # node .output/server/index.mjs -> http://localhost:3000
```

Same checks; server info says `"runtime": "main-thread"` here.

## Deploy to Vercel

Linked to Vercel project `pigents-projects/oj-nitro-test-app` (`.vercel/project.json`);
live at https://oj-nitro-test-app.vercel.app.

```sh
rm -rf .vercel/output
NITRO_PRESET=vercel ./bin/oj build .              # -> .vercel/output (Build Output API)
npx vercel@latest deploy --prebuilt --yes         # preview; add --prod for production
```

`vercel` on this machine wraps `bunx vercel`, which exits silently; use `npx vercel@latest`.
`vercel link` wrote a `VERCEL_OIDC_TOKEN` into `.env.local` (gitignored).

## Compare with Vite

```sh
pnpm vite:dev
pnpm vite:build && pnpm start
```

## Layout

- `vite.config.ts`: `nitro({ serverDir: "./server" })`, `tanstackStart()`, `react()`
- `src/routes/`: `__root.tsx`, `index.tsx`, `about.tsx`
- `src/server/functions.ts`: `getServerInfo` (GET) and `greet` (POST, validated input)
- `server/routes/api/hello.ts`: nitro route
- `public/robots.txt`
