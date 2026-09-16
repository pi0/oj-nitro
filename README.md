# oj + nitro

A simple TanStack Start app with [lovablelabs/oj](https://github.com/lovablelabs/oj) and [`nitro/vite`](https://nitro.build/docs/vite) for universal deployment.

> [!NOTE]
> This is a preview deployment for [lovablelabs/oj#181](https://github.com/lovablelabs/oj/pull/181) latest binary build copied to `bin/oj`

## Dev

```sh
pnpm dev # http://localhost:3000
```

## Prod

```sh
pnpm build # Generates .output/
pnpm start # Runs node .output/server/index.mjs -> http://localhost:3000
```
