import { mkdir, writeFile } from "fs/promises";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const DIST_DIR = "dist";
const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, "..");

const indexHtml = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hello World | YouTube Zero ao AR</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-family: system-ui, -apple-system, sans-serif;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
      color: #eee;
    }
    h1 {
      font-size: clamp(2rem, 5vw, 3.5rem);
      font-weight: 700;
      margin: 0 0 0.5rem;
      letter-spacing: -0.02em;
    }
    p { font-size: 1.125rem; opacity: 0.85; margin: 0; }
  </style>
</head>
<body>
  <h1>Hello World</h1>
  <p>YouTube Zero ao AR — built with Node.js, deployed via GitHub Actions</p>
</body>
</html>
`;

async function build() {
  const distPath = join(projectRoot, DIST_DIR);
  await mkdir(distPath, { recursive: true });
  await writeFile(join(distPath, "index.html"), indexHtml, "utf-8");
  await writeFile(join(distPath, ".nojekyll"), "", "utf-8");
}

build().catch((err) => {
  console.error(err);
  process.exit(1);
});
