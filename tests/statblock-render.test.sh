#!/bin/sh
# Renders DM Realm's Monster 2024 abilities-and-saves table (a JavaScript block) in headless
# Chrome with Obsidian's own stylesheet, in a column as wide as Fantasy Statblocks' (400px),
# and checks that it fits. Needs Google Chrome and an Obsidian install on this machine: the
# stylesheet is read from Obsidian's app package, never copied into the repository.
# Usage: sh tests/statblock-render.test.sh   (exit 0 = all pass, or skipped)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || CHROME=$(command -v google-chrome || command -v chromium || true)
ASAR=$(ls -t "$HOME/Library/Application Support/obsidian"/obsidian-*.asar "${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"/obsidian-*.asar 2>/dev/null | head -n 1)
[ -n "$ASAR" ] || ASAR=/Applications/Obsidian.app/Contents/Resources/obsidian.asar
if [ -z "$CHROME" ] || [ ! -f "$ASAR" ] || ! command -v node >/dev/null; then
  echo "statblock-render: skipped (needs Chrome, Obsidian and node)"; exit 0
fi

# Obsidian's app.css, out of its app package (an asar archive: a JSON index, then the files).
python3 - "$ASAR" "$TMP/app.css" <<'PY' || { echo "statblock-render: skipped (no app.css in $ASAR)"; exit 0; }
import json, struct, sys
data = open(sys.argv[1], "rb").read()
index = json.loads(data[16:16 + struct.unpack("<I", data[12:16])[0]])
base = 8 + struct.unpack("<I", data[4:8])[0]
entry = index["files"]["app.css"]
open(sys.argv[2], "wb").write(data[base + int(entry["offset"]):base + int(entry["offset"]) + entry["size"]])
PY

# DM Realm's layouts as Setup installs them: in English, in Italian (the words the Italian
# books use), and with labels far longer than any real one.
layouts() { # <name> <python dict of labels>
  mkdir -p "$TMP/$1/.obsidian/plugins/obsidian-5e-statblocks"
  python3 "$ROOT/skills/dmr-setup/statblocks-settings.py" labels |
    python3 -c "import json, sys; w = $2; print(json.dumps({l: w.get(l, l) for l in sys.stdin.read().splitlines()}))" > "$TMP/$1.json"
  python3 "$ROOT/skills/dmr-setup/statblocks-settings.py" merge "$TMP/$1" 2024 --labels "$TMP/$1.json" >/dev/null
}
layouts en '{}'
layouts it '{"MOD": "MOD", "SAVE": "TS", "STR": "FOR", "DEX": "DES", "CON": "COS", "INT": "INT", "WIS": "SAG", "CHA": "CAR", "Dexterity": "Destrezza", "Wisdom": "Saggezza"}'
layouts long '{"MOD": "MODIF", "SAVE": "TIRO SALV", "STR": "FORZ", "DEX": "DEST", "CON": "COST", "INT": "INTE", "WIS": "SAGG", "CHA": "CARI"}'

node - "$TMP" "$TMP/app.css" "$CHROME" <<'JS'
const fs = require("fs");
const { execFileSync } = require("child_process");
const [dir, appCss, chrome] = process.argv.slice(2);
const walk = (bs) => bs.flatMap((b) => [b, ...walk(b.nested || [])]);
const codeOf = (ws) => {
  const data = JSON.parse(fs.readFileSync(`${dir}/${ws}/.obsidian/plugins/obsidian-5e-statblocks/data.json`, "utf8"));
  return walk(data.layouts.find((l) => l.name === "DM Realm Monster 2024").blocks).find((b) => b.id === "dmr-abilities").code;
};
const plain = { stats: [14, 13, 16, 1, 12, 5], saves: [] };
const big = (dex, wis) => ({ stats: [30, 28, 30, 25, 27, 30], saves: [{ [dex]: 16 }, { [wis]: -12 }] });
let fails = 0;
// label, Workspace, monster, the cells it must show, whether the three pairs keep one line
for (const [label, ws, monster, want, oneLine] of [
  ["English", "en", plain, ["STR 14 +2 +2", "CHA 5 −3 −3", "MOD", "SAVE"], true],
  ["English, big numbers", "en", big("Dexterity", "Wisdom"), ["DEX 28 +9 +16", "WIS 27 +8 −12"], true],
  ["Italian", "it", big("Destrezza", "Saggezza"), ["DES 28 +9 +16", "SAG 27 +8 −12", "TS"], true],
  ["long labels", "long", plain, ["FORZ 14 +2 +2", "TIRO SALV"], false],
]) {
  const code = codeOf(ws);
  fs.writeFileSync(`${dir}/page.html`, `<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="file://${appCss}"></head>
<body class="theme-light"><div class="markdown-rendered markdown-preview-view">
<div class="block-language-statblock"><div class="statblock"><div class="statblock-content">
<div class="column" id="column" style="width: 400px"><div class="statblock-javascript" id="host"></div></div>
</div></div></div></div><pre id="result"></pre>
<script>
const el = new Function("monster", "property", ${JSON.stringify(code)})(${JSON.stringify(monster)}, null);
document.getElementById("host").appendChild(el);
const column = document.getElementById("column").getBoundingClientRect();
const right = Math.max(...[el, ...el.querySelectorAll("*")].map((n) => n.getBoundingClientRect().right));
const cells = [...el.querySelectorAll("td, th")].map((c) => c.textContent);
const lines = new Set([...el.querySelectorAll("table")].map((t) => Math.round(t.getBoundingClientRect().top))).size;
document.getElementById("result").textContent = "RESULT " + JSON.stringify({ overflow: Math.ceil(right - column.right), cells, lines });
</script></body></html>`);
  const dom = execFileSync(chrome, ["--headless=new", "--disable-gpu", "--allow-file-access-from-files",
    "--window-size=700,400", "--dump-dom", `file://${dir}/page.html`], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });
  const m = dom.match(/RESULT (\{.*\})/);
  if (!m) { console.log(`FAIL ${label}: the block did not render`); fails++; continue; }
  const { overflow, cells, lines } = JSON.parse(m[1].replace(/&quot;/g, '"').replace(/&amp;/g, "&"));
  if (overflow > 0) { console.log(`FAIL ${label}: ${overflow}px wider than the 400px column`); fails++; }
  // The three pairs sit on one line, as in the book, at the plugin's column width.
  if (oneLine && lines !== 1) { console.log(`FAIL ${label}: the three pairs take ${lines} lines, not 1`); fails++; }
  for (const w of want) {
    if (!cells.join(" ").includes(w)) { console.log(`FAIL ${label}: '${w}' not shown in: ${cells.join(" ")}`); fails++; }
  }
}
process.exit(fails ? 1 : 0);
JS
[ $? -eq 0 ] && echo "statblock-render: all pass" || { echo "statblock-render: failure(s)"; exit 1; }
