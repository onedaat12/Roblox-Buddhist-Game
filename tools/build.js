// Packs the Lua scripts in src/ into a Roblox place file (BodhiPath.rbxlx) that
// Roblox Studio can open directly. Run:  node tools/build.js
// (The same layout is described in default.project.json for people who use Rojo.)
const fs = require("fs");
const path = require("path");

const rootDir = path.join(__dirname, "..");
let nextRef = 1;

function esc(s) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}
function cdata(s) {
  return "<![CDATA[" + s.split("]]>").join("]]]]><![CDATA[>") + "]]>";
}
function item(cls, name, props, children) {
  return (
    `<Item class="${cls}" referent="RBX${nextRef++}"><Properties><string name="Name">${esc(name)}</string>` +
    (props || "") + `</Properties>` + (children || []).join("") + `</Item>`
  );
}
function scriptsIn(dir) {
  const out = [];
  for (const file of fs.readdirSync(dir).sort()) {
    const full = path.join(dir, file);
    if (fs.statSync(full).isDirectory()) {
      out.push(item("Folder", file, "", scriptsIn(full)));
      continue;
    }
    if (!file.endsWith(".lua") && !file.endsWith(".luau")) continue;
    const base = file.replace(/\.luau?$/, "");
    let cls = "ModuleScript", name = base;
    if (base.endsWith(".server")) { cls = "Script"; name = base.slice(0, -7); }
    else if (base.endsWith(".client")) { cls = "LocalScript"; name = base.slice(0, -7); }
    const source = fs.readFileSync(full, "utf8").replace(/\r\n/g, "\n");
    out.push(item(cls, name, `<ProtectedString name="Source">${cdata(source)}</ProtectedString>`));
  }
  return out;
}
function build() {
  nextRef = 1;
  const src = path.join(rootDir, "src");
  const xml =
    `<roblox version="4">` +
    item("ReplicatedStorage", "ReplicatedStorage", "", [item("Folder", "Shared", "", scriptsIn(path.join(src, "shared")))]) +
    item("ServerScriptService", "ServerScriptService", "", [item("Folder", "Server", "", scriptsIn(path.join(src, "server")))]) +
    item("StarterPlayer", "StarterPlayer", "", [
      item("StarterPlayerScripts", "StarterPlayerScripts", "", [item("Folder", "Client", "", scriptsIn(path.join(src, "client")))]),
    ]) +
    `</roblox>\n`;
  return xml;
}
module.exports = { build, rootDir };
if (require.main === module) {
  const out = path.join(rootDir, "BodhiPath.rbxlx");
  const xml = build();
  fs.writeFileSync(out, xml);
  console.log("Wrote " + out + " (" + Math.round(xml.length / 1024) + " KB)");
}
