import { createRootRoute, HeadContent, Link, Outlet, Scripts } from "@tanstack/react-router";
import "../styles.css";

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "oj + nitro test app" },
    ],
  }),
  component: RootComponent,
});

function RootComponent() {
  return (
    <html lang="en">
      <head>
        <HeadContent />
      </head>
      <body>
        <nav>
          <Link to="/" activeProps={{ className: "active" }}>Home</Link>
          <Link to="/about" activeProps={{ className: "active" }}>About</Link>
          <a href="/api/hello">/api/hello (nitro route)</a>
        </nav>
        <Outlet />
        <Scripts />
      </body>
    </html>
  );
}
