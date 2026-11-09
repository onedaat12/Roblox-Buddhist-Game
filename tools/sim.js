// Runs a simulated playthrough of the game outside Roblox, to catch mistakes early.
//   node tools/sim.js <path to API-Dump.json> [folder for world snapshot]
// The API dump comes from Roblox Studio itself:  RobloxStudioBeta.exe -API API-Dump.json
const fs = require("fs");
const path = require("path");
const fengari = require("fengari");
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = fengari;

const apiPath = process.argv[2];
const outDir = process.argv[3];
if (!apiPath) {
  console.log("usage: node tools/sim.js <API-Dump.json> [snapshot folder]");
  process.exit(2);
}
const api = JSON.parse(fs.readFileSync(apiPath, "utf8"));

function q(s) {
  return JSON.stringify(String(s));
}
function longString(s) {
  let level = 3;
  while (s.includes("]" + "=".repeat(level) + "]")) level++;
  const eq = "=".repeat(level);
  return "[" + eq + "[\n" + s + "]" + eq + "]";
}

// The API description, as a Lua table
let apiLua = "API_CLASSES = {}\nAPI_ENUMS = {}\nlocal F = {k='F'}\nlocal E = {k='E'}\nlocal C = {k='C'}\n";
for (const cls of api.Classes) {
  const members = [];
  for (const m of cls.Members) {
    const tags = m.Tags || [];
    if (tags.includes("NotScriptable")) continue;
    const key = "[" + q(m.Name) + "]";
    if (m.MemberType === "Property") {
      const sec = m.Security || {};
      const ro = tags.includes("ReadOnly") || (sec.Write && sec.Write !== "None");
      if (sec.Read && sec.Read !== "None") continue;
      members.push(`${key}={k='P',cat=${q(m.ValueType.Category)},typ=${q(m.ValueType.Name)}${ro ? ",ro=true" : ""}}`);
    } else if (m.MemberType === "Function") {
      members.push(`${key}=F`);
    } else if (m.MemberType === "Event") {
      members.push(`${key}=E`);
    } else if (m.MemberType === "Callback") {
      members.push(`${key}=C`);
    }
  }
  const sup = cls.Superclass && cls.Superclass !== "<<<ROOT>>>" ? q(cls.Superclass) : "nil";
  apiLua += `API_CLASSES[${q(cls.Name)}]={s=${sup},t=${q((cls.Tags || []).filter((t) => typeof t === "string").join(","))},m={${members.join(",")}}}\n`;
}
for (const en of api.Enums) {
  apiLua += `API_ENUMS[${q(en.Name)}]={${en.Items.map((i) => q(i.Name)).join(",")}}\n`;
}

// The game's scripts
const root = path.join(__dirname, "..");
let filesLua = "FILES = {}\n";
for (const dir of ["shared", "server", "client"]) {
  for (const f of fs.readdirSync(path.join(root, "src", dir)).sort()) {
    if (!f.endsWith(".lua")) continue;
    let name = f.slice(0, -4), cls = "ModuleScript";
    if (name.endsWith(".server")) { name = name.slice(0, -7); cls = "Script"; }
    if (name.endsWith(".client")) { name = name.slice(0, -7); cls = "LocalScript"; }
    const src = fs.readFileSync(path.join(root, "src", dir, f), "utf8").replace(/\r\n/g, "\n");
    filesLua += `FILES[#FILES+1]={dir=${q(dir)},name=${q(name)},class=${q(cls)},source=${longString(src)}}\n`;
  }
}

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
function run(code, name) {
  if (lauxlib.luaL_loadbuffer(L, to_luastring(code), null, to_luastring("=" + name)) !== lua.LUA_OK) {
    console.log("LOAD ERROR in " + name + ": " + to_jsstring(lua.lua_tostring(L, -1)));
    process.exit(1);
  }
  lua.lua_getglobal(L, to_luastring("debug"));
  lua.lua_getfield(L, -1, to_luastring("traceback"));
  lua.lua_remove(L, -2);
  lua.lua_insert(L, -2);
  if (lua.lua_pcall(L, 0, 1, -2) !== lua.LUA_OK) {
    console.log("RUNTIME ERROR in " + name + ":\n" + to_jsstring(lua.lua_tostring(L, -1)));
    process.exit(1);
  }
}
run(apiLua, "api");
run(filesLua, "files");
run("MOCK = (function()\n" + fs.readFileSync(path.join(__dirname, "mock", "mock.lua"), "utf8") + "\nend)()", "mock");
run("OUT_DIR = " + (outDir ? "true" : "nil"), "out");
run(fs.readFileSync(path.join(__dirname, "mock", "sim.lua"), "utf8"), "sim");

if (outDir) {
  lua.lua_getglobal(L, to_luastring("WORLD_JSON"));
  if (lua.lua_isstring(L, -1)) {
    fs.mkdirSync(outDir, { recursive: true });
    fs.writeFileSync(path.join(outDir, "world.json"), to_jsstring(lua.lua_tostring(L, -1)));
    console.log("  wrote " + path.join(outDir, "world.json"));
  }
}
lua.lua_getglobal(L, to_luastring("SIM_ERRORS"));
const errors = lua.lua_tointeger(L, -1);
process.exit(errors > 0 ? 1 : 0);
