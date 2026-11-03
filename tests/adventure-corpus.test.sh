#!/bin/sh
# Renders every Part of every Adventure in this machine's Source Cache with the Adventure
# helper's --check, so a Part it cannot render is found before a DM imports it. It ships
# no Trusted Source data (ADR 0003): it reads the Source Cache the plugin already keeps,
# with the Trusted Source unreachable, so it fetches and writes nothing.
# Each Part is split at its top-level headings, so links within a Part are rendered too.
# Usage: sh tests/adventure-corpus.test.sh [<adventure id> …]   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$ROOT/skills/dmr-import/render-adventure.py"

CACHE=${DMR_SOURCE_CACHE:-}
if [ -z "$CACHE" ]; then
  for c in "$HOME"/.claude/plugins/data/dm-realm*/source-cache; do
    [ -s "$c/release" ] && CACHE=$c && break
  done
fi
if [ -z "$CACHE" ] || [ ! -s "$CACHE/release" ]; then
  echo "adventure-corpus: no Source Cache on this machine, skipped"
  exit 0
fi
RELEASE=$(head -n 1 "$CACHE/release")
if [ ! -f "$CACHE/$RELEASE/data/adventures.json" ]; then
  echo "adventure-corpus: the Source Cache ($RELEASE) holds no Adventures, skipped"
  exit 0
fi

export DMR_SOURCE_CACHE="$CACHE"
export DMR_SOURCE_API="http://127.0.0.1:9/latest"   # never online: only what is cached
export DMR_SOURCE_RAW="http://127.0.0.1:9/raw"
export DMR_SOURCE_IMG="http://127.0.0.1:9/img"
unset EVAL_DMR_SOURCE_CACHE EVAL_DMR_SOURCE_API EVAL_DMR_SOURCE_RAW EVAL_DMR_SOURCE_IMG
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

find "$CACHE" -type f | sort > "$TMP/before"
python3 - "$HELPER" "$CACHE/$RELEASE/data" "$TMP" "$@" <<'PY'
import importlib.util, json, os, sys
helper, data, tmp, wanted = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
spec = importlib.util.spec_from_file_location("render_adventure", helper)
adv = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adv)

def run(argv):
    try:
        return 0, adv.main(argv)
    except (adv.Failure, adv.entry.statblock.Failure) as e:
        return e.code, str(e)
    except (KeyError, IndexError, TypeError, ValueError, AttributeError) as e:
        return 7, f"cannot render the Adventure ({type(e).__name__}: {e})"

ids = [a["id"] for a in json.load(open(f"{data}/adventures.json"))["adventure"]
       if os.path.exists(f"{data}/adventure/adventure-{a['id'].lower()}.json")]
ids = [i for i in ids if not wanted or i in wanted]
checked, notes, targets, failures = 0, 0, 0, []
for aid in ids:
    code, out = run([aid])
    if code:
        failures.append(f"{aid}: {out}")
        continue
    for part in json.loads(out)["parts"]:
        n = str(part["index"])
        code, out = run([aid, "--part", n, "--list"])
        if code:
            failures.append(f"{aid} Part {n}: {out}")
            continue
        listing = json.loads(out)
        top = [h["id"] for h in listing["headings"] if h["depth"] == 0 and h["type"] in ("entries", "section")]
        plan = {"part_note": f"A/Parts/Part_{n}",
                "sections": [{"id": i, "note": f"A/Sections/Note_{i}"} for i in top]}
        links = {t["key"]: f"R/{t['folder']}/{t['key'].replace('|', '_')}" for t in listing["links"]}
        for name, value in (("plan", plan), ("links", links)):
            json.dump(value, open(f"{tmp}/{name}.json", "w"))
        code, out = run([aid, "--part", n, "--plan", f"{tmp}/plan.json", "--links", f"{tmp}/links.json", "--check"])
        checked, notes, targets = checked + 1, notes + 1 + len(top), targets + len(links)
        if code:
            failures.append(f"{aid} Part {n}: exit {code}: {out}")
for f in failures:
    print(f"FAIL {f}")
print(f"adventure-corpus: {len(ids)} Adventures, {checked} Parts checked "
      f"({notes} notes, {targets} link targets), {len(failures)} failed")
sys.exit(1 if failures else 0)
PY
CODE=$?
find "$CACHE" -type f | sort > "$TMP/after"
if ! cmp -s "$TMP/before" "$TMP/after"; then
  echo "FAIL adventure-corpus: the Source Cache changed"
  CODE=1
fi
exit $CODE
