// Checks every Lua script for syntax errors and misspelled names.
// Run:  node tools/check.js
const fs = require("fs");
const path = require("path");
const luaparse = require("luaparse");

const KNOWN = new Set(("game workspace script Instance Vector3 Vector2 CFrame Color3 UDim UDim2 Enum Random TweenInfo " +
  "NumberRange NumberSequence NumberSequenceKeypoint ColorSequence ColorSequenceKeypoint task typeof warn print error " +
  "pcall require ipairs pairs tostring tonumber type math string table os select next setmetatable getmetatable " +
  "tick time unpack assert rawget rawset").split(" "));

function walk(dir, out) {
  for (const f of fs.readdirSync(dir)) {
    const full = path.join(dir, f);
    if (fs.statSync(full).isDirectory()) walk(full, out);
    else if (f.endsWith(".lua")) out.push(full);
  }
  return out;
}
let bad = 0, lines = 0;
const files = walk(path.join(__dirname, "..", "src"), []);
for (const file of files) {
  const src = fs.readFileSync(file, "utf8");
  lines += src.split("\n").length;
  const rel = path.relative(path.join(__dirname, ".."), file);
  try {
    const globals = new Map();
    luaparse.parse(src, {
      luaVersion: "5.1", scope: true, locations: true,
      onCreateNode(node) {
        if (node.type === "Identifier" && node.isLocal === false && !KNOWN.has(node.name)) {
          if (!globals.has(node.name)) globals.set(node.name, node.loc.start.line);
        }
      },
    });
    for (const [name, line] of globals) { bad++; console.log(`${rel}:${line}: unknown name "${name}"`); }
  } catch (e) {
    bad++;
    console.log(`${rel}: ${e.message}`);
  }
}
console.log(`${files.length} files, ${lines} lines, ${bad} problem(s)`);
process.exit(bad ? 1 : 0);
