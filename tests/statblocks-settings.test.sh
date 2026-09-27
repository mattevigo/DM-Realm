#!/bin/sh
# Tests the Fantasy Statblocks settings helper: merging DM Realm's three layouts, labels
# translated, into the plugin's data.json, against temporary Workspaces.
# Usage: sh tests/statblocks-settings.test.sh   (exit 0 = all pass)
set -u
HELPER="$(cd "$(dirname "$0")/.." && pwd)/skills/dmr-setup/statblocks-settings.py"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
# json <file> <python expression over d>
json() { python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(eval(sys.argv[2]))" "$@"; }
# layout <file> <layout name> <python expression over l> — l is that layout, blocks flattened into l["all"]
layout() { python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
l = [x for x in d['layouts'] if x['name'] == sys.argv[2]][0]
def walk(bs):
    for b in bs:
        yield b
        yield from walk(b.get('nested', []))
l['all'] = list(walk(l['blocks']))
print(eval(sys.argv[3]))" "$@"; }
PLUGIN=.obsidian/plugins/obsidian-5e-statblocks

# The plugin is not installed: nothing is written, and it says so (exit 3).
W="$TMP/none"; mkdir -p "$W/.obsidian"
OUT=$(python3 "$HELPER" merge "$W" 2024 2>&1); CODE=$?
[ "$CODE" -eq 3 ] || fail "not installed: expected exit 3, got $CODE"
case "$OUT" in *"Fantasy Statblocks"*) ;; *) fail "not installed: should name the plugin: $OUT";; esac
[ ! -e "$W/.obsidian/plugins" ] || fail "not installed: created the plugins folder"

# Installed, never opened (no data.json): the three layouts and DM Realm's settings appear.
W="$TMP/fresh"; mkdir -p "$W/$PLUGIN"
python3 "$HELPER" merge "$W" 2024 >/dev/null || fail "fresh: exit $?"
D="$W/$PLUGIN/data.json"
[ "$(json "$D" 'sorted(l["name"] for l in d["layouts"])')" = "['DM Realm Character', 'DM Realm Monster 2014', 'DM Realm Monster 2024']" ] || fail "fresh: layouts: $(json "$D" '[l["name"] for l in d["layouts"]]')"
[ "$(json "$D" '[l["name"] for l in d["layouts"] if l["id"] == d["default"]]')" = "['DM Realm Monster 2024']" ] || fail "fresh: the 2024 monster layout should be the default"
[ "$(json "$D" 'd["disableSRD"], d["autoParse"], d["paths"]')" = "(True, True, ['/'])" ] || fail "fresh: settings: $(cat "$D")"
[ "$(layout "$D" 'DM Realm Monster 2014' '[b["display"] for b in l["all"] if b.get("properties") == ["ac"]]')" = "['Armor Class']" ] || fail "fresh: English labels"
[ "$(layout "$D" 'DM Realm Monster 2024' '[b["type"] for b in l["all"] if b.get("properties") == ["initiative"]]')" = "['property']" ] || fail "fresh: 2024 layout shows initiative"
[ "$(layout "$D" 'DM Realm Character' '{p for b in l["all"] for p in b.get("properties", [])} >= {"level", "player", "ac", "hp", "hit_dice", "initiative", "stats", "saves", "skillsaves", "senses", "actions", "spells", "traits"}')" = "True" ] || fail "fresh: the Character layout lacks a property"
case "$(cat "$D")" in *'t("'*) fail "fresh: an untranslated t(\"…\") label is left in a callback";; esac

# A 2014 Workspace defaults to the 2014 monster layout.
W="$TMP/old"; mkdir -p "$W/$PLUGIN"
python3 "$HELPER" merge "$W" 2014 >/dev/null || fail "2014: exit $?"
[ "$(json "$W/$PLUGIN/data.json" '[l["name"] for l in d["layouts"] if l["id"] == d["default"]]')" = "['DM Realm Monster 2014']" ] || fail "2014: default layout"
OUT=$(python3 "$HELPER" merge "$W" 2020 2>&1); CODE=$?
[ "$CODE" -eq 2 ] || fail "bad edition: expected exit 2, got $CODE"

# The DM's own settings and layouts stay; DM Realm's layouts are replaced by name.
W="$TMP/existing"; mkdir -p "$W/$PLUGIN"
cat > "$W/$PLUGIN/data.json" <<'JSON'
{"monsters": [["Zombie", {"name": "Zombie"}]], "useDice": true, "default": "basic-5e-layout",
 "paths": ["03_Bestiario"], "autoParse": false, "disableSRD": false,
 "layouts": [{"id": "my-layout", "name": "My Layout", "blocks": []},
             {"id": "old-id", "name": "DM Realm Monster 2024", "blocks": [{"type": "heading", "id": "x", "properties": ["name"]}]},
             {"id": "dm-realm-character", "name": "Renamed Character", "blocks": []}],
 "defaultLayouts": {"basic-5e-layout": {"id": "basic-5e-layout", "name": "Basic 5e Layout", "blocks": []}}}
JSON
python3 "$HELPER" merge "$W" 2024 >/dev/null || fail "existing: exit $?"
D="$W/$PLUGIN/data.json"
[ "$(json "$D" 'd["useDice"], d["monsters"][0][0], list(d["defaultLayouts"])')" = "(True, 'Zombie', ['basic-5e-layout'])" ] || fail "existing: the DM's settings changed"
# A layout with DM Realm's name, or with its id under another name, is DM Realm's: replaced,
# so no two layouts share an id.
[ "$(json "$D" '[l["name"] for l in d["layouts"]]')" = "['My Layout', 'DM Realm Monster 2024', 'DM Realm Character', 'DM Realm Monster 2014']" ] || fail "existing: layouts by name: $(json "$D" '[l["name"] for l in d["layouts"]]')"
[ "$(json "$D" 'len({l["id"] for l in d["layouts"]}) == len(d["layouts"])')" = "True" ] || fail "existing: two layouts share an id: $(json "$D" '[l["id"] for l in d["layouts"]]')"
[ "$(json "$D" 'len([l for l in d["layouts"] if l["name"] == "DM Realm Monster 2024"][0]["blocks"]) > 1')" = "True" ] || fail "existing: the stale DM Realm layout was not replaced"
[ "$(json "$D" 'd["paths"], d["autoParse"], d["disableSRD"]')" = "(['/'], True, True)" ] || fail "existing: DM Realm's settings not set"

# Already as DM Realm needs it: no rewrite, and it says so.
before=$(python3 -c "import os,sys; print(os.stat(sys.argv[1]).st_mtime_ns)" "$D"); sleep 0.1
OUT=$(python3 "$HELPER" merge "$W" 2024) || fail "no-op: exit $?"
[ "$before" = "$(python3 -c "import os,sys; print(os.stat(sys.argv[1]).st_mtime_ns)" "$D")" ] || fail "no-op: data.json was rewritten"
case "$OUT" in *"already"*) ;; *) fail "no-op: should say the settings are already right: $OUT";; esac

# Labels: listed for translation, then merged translated — displays, headings, table
# headers and the labels inside callbacks.
LABELS=$(python3 "$HELPER" labels) || fail "labels: exit $?"
for l in "Armor Class" "Hit Points" "Saving Throws" "Actions" "STR" "XP" "Initiative" "Level" "Player" "Attacks"; do
  printf '%s\n' "$LABELS" | grep -qx "$l" || fail "labels: '$l' is not listed"
done
python3 - "$TMP/it.json" <<PY
import json, sys
labels = """$LABELS""".splitlines()
it = {l: "IT " + l for l in labels}
it.update({"Armor Class": "Classe Armatura", "STR": "FOR", "XP": "PE"})
json.dump(it, open(sys.argv[1], "w"), ensure_ascii=False)
PY
W="$TMP/italian"; mkdir -p "$W/$PLUGIN"
python3 "$HELPER" merge "$W" 2024 --labels "$TMP/it.json" >/dev/null || fail "italian: exit $?"
D="$W/$PLUGIN/data.json"
[ "$(layout "$D" 'DM Realm Monster 2014' '[b["display"] for b in l["all"] if b.get("properties") == ["ac"]]')" = "['Classe Armatura']" ] || fail "italian: display not translated"
[ "$(layout "$D" 'DM Realm Monster 2014' '[b["headers"][0] for b in l["all"] if b["type"] == "table"]')" = "['FOR']" ] || fail "italian: table headers not translated"
[ "$(layout "$D" 'DM Realm Monster 2014' '[b["heading"] for b in l["all"] if b.get("properties") == ["actions"]]')" = "['IT Actions']" ] || fail "italian: heading not translated"
[ "$(layout "$D" 'DM Realm Monster 2014' '"\"PE\"" in [b for b in l["all"] if b.get("properties") == ["cr"]][0]["callback"]')" = "True" ] || fail "italian: callback label not translated"
[ "$(json "$D" '[l["name"] for l in d["layouts"] if l["id"] == d["default"]]')" = "['DM Realm Monster 2024']" ] || fail "italian: layout names are stable, not translated"
# The same labels from standard input.
W="$TMP/stdin"; mkdir -p "$W/$PLUGIN"
python3 "$HELPER" merge "$W" 2024 --labels - < "$TMP/it.json" >/dev/null || fail "stdin: exit $?"
[ "$(layout "$W/$PLUGIN/data.json" 'DM Realm Character' '[b["display"] for b in l["all"] if b.get("properties") == ["ac"]]')" = "['Classe Armatura']" ] || fail "stdin: labels not read"

# The layouts' JavaScript runs as the plugin runs it — callbacks as new Function("monster", …),
# the abilities-and-saves table as new Function("monster", "property", …) — on fences
# DM Realm writes (render-entry.py's keys), in English and translated.
if command -v node >/dev/null; then
  node - "$TMP/fresh/$PLUGIN/data.json" "$TMP/italian/$PLUGIN/data.json" <<'JS' || fail "layout JavaScript"
const fs = require("fs");
const [en, it] = process.argv.slice(2).map((p) => JSON.parse(fs.readFileSync(p, "utf8")));
// A document just big enough for the abilities table.
const node = (tag) => ({ tag, children: [], style: {}, textContent: "",
  append(...c) { this.children.push(...c); } });
global.document = { createElement: node };
const walk = (bs) => bs.flatMap((b) => [b, ...walk(b.nested || [])]);
const block = (data, name, id) => walk(data.layouts.find((l) => l.name === name).blocks).find((b) => b.id === id);
const call = (data, name, id, monster) => new Function("monster", block(data, name, id).callback)(monster);
const table = (data, monster) => {
  const t = new Function("monster", "property", block(data, "DM Realm Monster 2024", "dmr-abilities").code)(monster, monster.stats);
  return t.children.slice(1).map((row) => row.children.map((c) => c.textContent).join(" "));
};
const eq = (label, got, want) => { if (JSON.stringify(got) !== JSON.stringify(want)) {
  console.log(`FAIL ${label}: got ${JSON.stringify(got)}, want ${JSON.stringify(want)}`); process.exitCode = 1; } };
const moth = { name: "Ember Moth", ac: 12, hp: 3, hit_dice: "1d4 + 1", initiative: 4, cr: "1/4",
  stats: [2, 15, 12, 2, 10, 6], saves: [{ Dexterity: 6 }], damage_immunities: "fire", condition_immunities: "charmed" };
eq("2014 challenge", call(en, "DM Realm Monster 2014", "dmr-cr", moth), "1/4 (50 XP)");
eq("2024 challenge", call(en, "DM Realm Monster 2024", "dmr-cr", { cr: "5" }), "5 (XP 1,800; PB +3)");
eq("2024 initiative", call(en, "DM Realm Monster 2024", "dmr-initiative", moth), "+4 (14)");
eq("2024 negative initiative", call(en, "DM Realm Monster 2024", "dmr-initiative", { initiative: -1 }), "−1 (9)");
eq("no initiative", call(en, "DM Realm Monster 2024", "dmr-initiative", {}), "");
eq("armor class", call(en, "DM Realm Monster 2014", "dmr-ac", { ac: 13, ac_class: "natural armor" }), "13 (natural armor)");
eq("hit points", call(en, "DM Realm Monster 2014", "dmr-hp", moth), "3 (1d4 + 1)");
eq("immunities", call(en, "DM Realm Monster 2024", "dmr-immunities", moth), "fire; charmed");
eq("character initiative", call(en, "DM Realm Character", "dmr-initiative", { initiative: 2 }), "+2");
eq("abilities table", table(en, moth), ["STR 2 −4 −4 DEX 15 +2 +6 CON 12 +1 +1", "INT 2 −4 −4 WIS 10 +0 +0 CHA 6 −2 −2"]);
// Translated: the table's names match the save names a translated fence uses.
eq("translated challenge", call(it, "DM Realm Monster 2014", "dmr-cr", moth), "1/4 (50 PE)");
eq("translated table", table(it, { stats: [2, 15, 12, 2, 10, 6], saves: [{ "IT Dexterity": 6 }] })[0], "FOR 2 −4 −4 IT DEX 15 +2 +6 IT CON 12 +1 +1");
JS
else
  echo "statblocks-settings: node not found, layout JavaScript not run"
fi

# A label missing from the translations: nothing written, exit 2, the label named.
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); del d['Hit Points']; json.dump(d, open(sys.argv[2], 'w'))" "$TMP/it.json" "$TMP/partial.json"
W="$TMP/partial"; mkdir -p "$W/$PLUGIN"
OUT=$(python3 "$HELPER" merge "$W" 2024 --labels "$TMP/partial.json" 2>&1); CODE=$?
[ "$CODE" -eq 2 ] || fail "missing label: expected exit 2, got $CODE"
case "$OUT" in *"Hit Points"*) ;; *) fail "missing label: should name it: $OUT";; esac
[ ! -e "$W/$PLUGIN/data.json" ] || fail "missing label: wrote data.json anyway"

# A data.json that is not valid JSON: touch nothing, exit 2.
W="$TMP/broken"; mkdir -p "$W/$PLUGIN"
printf '{"useDice": true,' > "$W/$PLUGIN/data.json"
OUT=$(python3 "$HELPER" merge "$W" 2024 2>&1); CODE=$?
[ "$CODE" -eq 2 ] || fail "broken: expected exit 2, got $CODE"
[ "$(cat "$W/$PLUGIN/data.json")" = '{"useDice": true,' ] || fail "broken: data.json was rewritten"

[ "$FAILS" -eq 0 ] && echo "statblocks-settings: all pass" || { echo "statblocks-settings: $FAILS failure(s)"; exit 1; }
