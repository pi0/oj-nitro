import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { getServerInfo, greet } from "../server/functions";

export const Route = createFileRoute("/")({
  loader: () => getServerInfo(),
  component: Home,
});

function Home() {
  const info = Route.useLoaderData();
  const [hydrated, setHydrated] = useState(false);
  const [count, setCount] = useState(0);
  const [name, setName] = useState("oj");
  const [result, setResult] = useState<unknown>(null);
  useEffect(() => setHydrated(true), []);

  return (
    <main>
      <h1>oj + nitro</h1>
      <p>
        Hydrated: <strong data-testid="hydrated">{hydrated ? "yes" : "no"}</strong>
      </p>

      <h2>Loader (server function, GET)</h2>
      <pre>{JSON.stringify(info, null, 2)}</pre>

      <h2>Client state</h2>
      <button onClick={() => setCount((c) => c + 1)}>count: {count}</button>

      <h2>Server function from the browser</h2>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <button onClick={async () => setResult(await greet({ data: { name } }))}>greet (POST)</button>
      <button onClick={async () => setResult(await getServerInfo())}>server info (GET)</button>
      {result ? <pre>{JSON.stringify(result, null, 2)}</pre> : null}
    </main>
  );
}
