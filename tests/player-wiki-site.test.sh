#!/bin/sh
# Runs the Player Wiki site helper. With no network and no Quartz: a fake Node too old, and a
# fake Quartz install (a stand-in for its CLI) for the configuration, the swap and a failed
# build. With a real Quartz install (PW_SITE_QUARTZ=<folder holding v<version>/>, or one in
# ~/.claude/plugins/data/*/quartz): a real build of a small wiki. Skips what it cannot run,
# saying so.
# Usage: sh tests/player-wiki-site.test.sh   (exit 0 = all pass)
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$ROOT/skills/dmr-workspace/player-wiki.py"
SITE="$ROOT/skills/dmr-workspace/player-wiki-site.py"
command -v python3 >/dev/null 2>&1 || { echo "player-wiki-site: skipped (no python3)"; exit 0; }
TMP=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$TMP"' EXIT
FAILS=0
fail() { echo "FAIL $1"; FAILS=$((FAILS+1)); }
VERSION=$(sed -n 's/^QUARTZ = "\(.*\)"$/\1/p' "$SITE")

# A small Workspace whose Player Wiki is written to $TMP/Wiki, its site to $TMP/Wiki_Site.
W="$TMP/Mio_Mondo"; mkdir -p "$W/Riferimento/Regole" "$W/Personaggi/Durga"
cat > "$W/workspace-config.yml" <<YML
language: Italiano
folders:
  reference: Riferimento
  characters: Personaggi
player_wiki:
  output: $TMP/Wiki
  site: $TMP/Wiki_Site
  include: [reference, characters]
YML
printf '# Accecato\n\nNon vedi. Vedi [[Durga]].\n' > "$W/Riferimento/Regole/Accecato.md"
printf '# Durga\n\n## Identità\n\nCieca, a volte: [[Accecato]].\n' > "$W/Personaggi/Durga/Durga.md"
python3 "$WIKI" write "$W" >/dev/null || fail "the Markdown wiki: exit $?"

# Node missing or too old: exit 7, with how to install it, and no site.
printf '#!/bin/sh\necho v18.19.0\n' > "$TMP/old-node"; chmod +x "$TMP/old-node"
OUT=$(EVAL_DMR_NODE="$TMP/old-node" python3 "$SITE" node); [ $? -eq 7 ] || fail "an old Node should exit 7"
case "$OUT" in *'"ok": false'*'"node": "v18.19.0"'*|*'"node": "v18.19.0"'*'"ok": false'*) ;; *) fail "node status: $OUT";; esac
EVAL_DMR_NODE="$TMP/old-node" DMR_QUARTZ="$TMP/q" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>"$TMP/err"
[ $? -eq 7 ] || fail "a build with an old Node should exit 7"
grep -q "brew install node" "$TMP/err" || fail "the message should say how to install Node: $(cat "$TMP/err")"
[ -e "$TMP/Wiki_Site" ] && fail "no site should be built without Node"
[ -e "$TMP/q" ] && fail "nothing should be downloaded without Node"

NODE_OK=$(python3 "$SITE" node >/dev/null 2>&1 && echo yes || echo no)
if [ "$NODE_OK" = no ]; then
  echo "player-wiki-site: the fake-Quartz and real builds skipped (no Node 22 or later)"
else
  # A fake Quartz install: its default config holds the lines DM Realm sets; its CLI writes a page,
  # or fails when FAKE_QUARTZ_FAIL is set.
  Q="$TMP/quartz/v$VERSION"; mkdir -p "$Q/quartz/i18n/locales"
  touch "$Q/.dm-realm-installed" "$Q/quartz/i18n/locales/it-IT.ts" "$Q/quartz/i18n/locales/en-US.ts"
  cat > "$Q/quartz.config.default.yaml" <<'YML'
configuration:
  pageTitle: Quartz 5
  enableSPA: true
  analytics:
    provider: plausible
  locale: en-US
  baseUrl: quartz.jzhao.xyz
  ignorePatterns:
    - private
    - templates
    - .obsidian
  theme:
    fontOrigin: googleFonts
plugins:
  - source: "@quartz-community/latex"
    enabled: true
    options:
      renderEngine: katex
  - source: "@quartz-community/quartz-fonts"
    enabled: true
  - source: "@quartz-community/og-image"
    enabled: true
  - source: "@quartz-community/cname"
    enabled: true
  - source: "@quartz-community/footer"
    enabled: true
    options:
      links:
        GitHub: https://github.com/jackyzha0/quartz
        Discord Community: https://discord.gg/x
    layout:
      position: footer
YML
  cat > "$Q/quartz/bootstrap-cli.mjs" <<'JS'
import fs from "node:fs"; import path from "node:path"
const a = process.argv.slice(2)
if (process.env.FAKE_QUARTZ_FAIL) { console.error("broken build"); process.exit(1) }
const out = a[a.indexOf("-o") + 1], dir = a[a.indexOf("-d") + 1]
fs.mkdirSync(out, { recursive: true })
fs.writeFileSync(path.join(out, "index.html"), `<html>${fs.readdirSync(dir).join(",")}</html>`)
JS
  OUT=$(DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT) || fail "fake build: exit $?"
  C="$Q/quartz.config.yaml"
  for line in '  pageTitle: "Mio Mondo"' '  analytics: null' '  locale: it-IT' '  publishAssets: referenced' \
              '    - .dm-realm-player-wiki' '    fontOrigin: selfHosted' '      fontOrigin: selfHosted' '      links: {}'; do
    grep -qxF -- "$line" "$C" || fail "config lacks: $line"
  done
  grep -q 'Discord\|plausible\|    - private' "$C" && fail "config keeps a default DM Realm removes"
  for plugin in og-image cname latex; do
    grep -A1 "@quartz-community/$plugin\"" "$C" | grep -q 'enabled: false' || fail "the $plugin plugin should be off"
  done
  [ -f "$TMP/Wiki_Site/index.html" ] || fail "the site was not built"
  [ -f "$TMP/Wiki_Site/.dm-realm-player-wiki-site" ] || fail "the site has no marker"
  grep -q "Riferimento" "$TMP/Wiki_Site/index.html" || fail "the site was not built from the Markdown wiki"
  case "$OUT" in *"Preview: python3 -m http.server --directory \"$TMP/Wiki_Site\" 8080"*) ;; *) fail "report: $OUT";; esac

  # A second build keeps the site folder's dot-entries; a failed one leaves the site as it was.
  mkdir -p "$TMP/Wiki_Site/.git"; printf 'x' > "$TMP/Wiki_Site/.git/HEAD"
  DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT >/dev/null || fail "second build: exit $?"
  [ -f "$TMP/Wiki_Site/.git/HEAD" ] || fail "a dot-entry of the site was lost"
  printf 'previous' > "$TMP/Wiki_Site/index.html"
  FAKE_QUARTZ_FAIL=1 DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>"$TMP/err"
  [ $? -eq 9 ] || fail "a failed build should exit 9"
  grep -q "broken build" "$TMP/err" || fail "the build's error should be reported: $(cat "$TMP/err")"
  [ "$(cat "$TMP/Wiki_Site/index.html")" = previous ] || fail "a failed build changed the previous site"
  ls "$TMP" | grep -q 'dmr-' && fail "a temporary build folder was left behind: $(ls "$TMP")"

  # A locale Quartz lacks falls back to en-US, and says so.
  OUT=$(DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale xx-XX) || fail "fallback build: exit $?"
  grep -qx '  locale: en-US' "$C" || fail "an unknown locale should fall back to en-US"
  case "$OUT" in *"no locale 'xx-XX'"*) ;; *) fail "the fallback should be noted: $OUT";; esac

  # Refusals, building nothing.
  set_site() { sed -i.bak "s|^  site: .*|  site: $1|" "$W/workspace-config.yml" && rm -f "$W/workspace-config.yml.bak"; }
  mkdir -p "$TMP/Altro"; printf 'mine' > "$TMP/Altro/a.txt"
  set_site "$TMP/Altro"
  DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>&1; [ $? -eq 5 ] || fail "a foreign site folder should exit 5"
  [ -f "$TMP/Altro/a.txt" ] || fail "a foreign site folder was emptied"
  set_site "$W/Sito"
  DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>&1; [ $? -eq 3 ] || fail "a site inside the Workspace should exit 3"
  set_site "$TMP/Wiki/Sito"
  DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>&1; [ $? -eq 3 ] || fail "a site inside the Markdown wiki should exit 3"
  set_site "$TMP/Wiki_Site"
  python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>&1; [ $? -eq 2 ] || fail "no DMR_QUARTZ should exit 2"
  sed -i.bak 's|^  fontOrigin.*||; s|^    fontOrigin: googleFonts||' "$Q/quartz.config.default.yaml" && rm -f "$Q/quartz.config.default.yaml.bak"
  DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>&1; [ $? -eq 6 ] || fail "a default config without a line DM Realm sets should exit 6"
  rm -rf "$TMP/Wiki"
  DMR_QUARTZ="$TMP/quartz" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>&1; [ $? -eq 2 ] || fail "no Markdown wiki should exit 2"

  # A real build, when a Quartz install of the pinned version is on this machine.
  REAL=${PW_SITE_QUARTZ:-}
  [ -n "$REAL" ] || for d in "$HOME"/.claude/plugins/data/*/quartz; do [ -f "$d/v$VERSION/.dm-realm-installed" ] && REAL=$d && break; done
  if [ -z "$REAL" ] || [ ! -f "$REAL/v$VERSION/.dm-realm-installed" ]; then
    echo "player-wiki-site: the real build skipped (no Quartz $VERSION installed; set PW_SITE_QUARTZ)"
  else
    python3 "$WIKI" write "$W" >/dev/null || fail "real: the Markdown wiki"
    DMR_QUARTZ="$REAL" python3 "$SITE" build "$W" --locale it-IT >/dev/null 2>"$TMP/err" || fail "real build: $(tail -5 "$TMP/err")"
    S="$TMP/Wiki_Site"
    grep -q '<html lang="it"' "$S/index.html" || fail "real: the site is not in Italian"
    [ -e "$S/CNAME" ] && fail "real: a CNAME was written"
    [ -n "$(find "$S" -name '*-og-image.*' | head -1)" ] && fail "real: social images were generated"
    grep -q 'fonts.googleapis\|cdn.jsdelivr' "$S/index.html" && fail "real: a page loads fonts or scripts from a CDN"
    python3 -I - "$S" <<'PY' || fail "real: a link in the site does not resolve"
import html, os, re, sys, urllib.parse
root, bad = sys.argv[1], []
for d, _, fs in os.walk(root):
    for f in fs:
        if f.endswith(".html"):
            a = re.search(r"<article.*?</article>", open(os.path.join(d, f), encoding="utf-8").read(), re.S)
            for m in re.finditer(r'(?:href|src)="([^"#?]+)', a.group(0) if a else ""):
                u = html.unescape(m.group(1))
                t = os.path.normpath(os.path.join(d, urllib.parse.unquote(u)))
                if not re.match(r"[a-z]+:", u) and not any(os.path.exists(x) for x in (t, t + ".html", os.path.join(t, "index.html"))):
                    bad.append((f, u))
sys.exit(1 if bad else 0)
PY
  fi
fi

[ "$FAILS" -eq 0 ] && echo "player-wiki-site: all pass" || { echo "player-wiki-site: $FAILS failed"; exit 1; }
