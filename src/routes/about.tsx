import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/about")({
  component: About,
});

function About() {
  return (
    <main>
      <h1>About</h1>
      <p>Edit this file while <code>pnpm dev</code> is running to try live reload.</p>
    </main>
  );
}
