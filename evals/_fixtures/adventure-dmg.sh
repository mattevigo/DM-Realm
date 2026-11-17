# Sourced after workspace-en.sh by dmr-adventure cases: a Source Cache seeded with an
# INVENTED 2024 Dungeon Master's Guide (ADR 0003: no real Trusted Source data in the
# repository; the eval sandbox has no network). Its chapter, pages, budgets and XP are
# made up — the pages (210–216) and numbers differ from the real book's, so an answer
# that cites them proves it came from the cache. EVAL_DMR_SOURCE_CACHE points here.
CACHE="$HOME/.dm-realm/source-cache"
D="$CACHE/v3.0.0/data"
mkdir -p "$D/book"
echo v3.0.0 > "$CACHE/release"
cat > "$D/books.json" <<'JSON'
{"book": [
  {"name": "Player's Handbook (2024)", "id": "XPHB", "source": "XPHB", "published": "2024-09-17", "group": "core"},
  {"name": "Dungeon Master's Guide (2024)", "id": "XDMG", "source": "XDMG", "published": "2024-11-12", "group": "core"}
]}
JSON
cat > "$D/book/book-xdmg.json" <<'JSON'
{"data": [
 {"type": "section", "name": "Chapter 4: Creating Adventures", "page": 210, "entries": [
   "An adventure is a story the players finish in a few sessions.",
   {"type": "entries", "name": "Lay Out the Premise", "page": 211, "entries": [
     "Begin from a want and an obstacle: someone wants something, and something stands in the way. Write the premise in two sentences."]},
   {"type": "entries", "name": "Draw In the Players", "page": 212, "entries": [
     "A hook works best when it touches what a character already cares about: a debt, a relative, a rival."]},
   {"type": "entries", "name": "Plan Encounters", "page": 213, "entries": [
     {"type": "entries", "name": "Combat Encounters", "page": 214, "entries": [
       "Choose a difficulty, then multiply the XP Budget per Character below by the number of characters. Add up the XP of every creature: the total must not exceed the budget.",
       {"type": "table", "caption": "XP Budget per Character", "colLabels": ["Level", "Low", "Moderate", "High"],
        "rows": [["3", "140", "270", "410"], ["4", "160", "320", "480"], ["5", "290", "580", "870"]]},
       {"type": "table", "caption": "Creature XP", "colLabels": ["CR", "XP"],
        "rows": [["1", "210"], ["2", "470"], ["5", "1,950"]]}]}]},
   {"type": "entries", "name": "Bring It to an End", "page": 216, "entries": [
     "End on a choice the players make, then show what it changed."]}]}
]}
JSON
