import { readFile } from "fs/promises";
import { existsSync } from "fs";
import { join } from "path";
import { fileURLToPath } from "url";
import { describe, it } from "node:test";
import assert from "node:assert";

const __dirname = fileURLToPath(new URL(".", import.meta.url));
const distPath = join(__dirname, "..", "dist", "index.html");

describe("build output", () => {
  it("produces dist/index.html", () => {
    assert.ok(existsSync(distPath), "dist/index.html should exist after build");
  });

  it("index.html contains Hello World", async () => {
    const content = await readFile(distPath, "utf-8");
    assert.ok(
      content.includes("Hello World"),
      "index.html should contain 'Hello World'"
    );
  });
});
