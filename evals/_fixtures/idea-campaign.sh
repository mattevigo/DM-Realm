# Shared starting state for the Idea cases: session-campaign.sh's Ashfall, played and
# consolidated through Session 04, with three facts an Idea for the next Session must not
# contradict — Vex, the cult's high priestess, died in Session 04; Kell, the party's
# wizard, has every spell slot spent in the Party State and no rest before the next
# Session; and Hollis Crane, the innkeeper the party trusts, is secretly the cult's
# leader, as the Campaign's NPCs note says. English only. Every note here is INVENTED test content.
. "$(dirname "$0")/../_fixtures/session-campaign.sh"

mkdir -p Characters/Kell
printf '# Kell\n\nHuman wizard, level 4. Spells prepared: Magic Missile, Shield, Sleep, Misty Step, Web. Cantrips: Fire Bolt, Light, Mage Hand.\n' > Characters/Kell/Kell.md
sed 's/^- \[\[Durga\]\]$/&\
- [[Kell]]/' $SC/README.md > $SC/README.tmp && mv $SC/README.tmp $SC/README.md
sed 's/^## Party treasure$/## Kell\
\
[[Kell]]: 19 of 22 hit points; every spell slot spent (four 1st-level, three 2nd-level).\
\
&/' $SC/Party_State.md > $SC/Party_State.tmp && mv $SC/Party_State.tmp $SC/Party_State.md

session Session_04_The_Flooded_Vault 4 2026-09-26 "Session 4: The Flooded Vault" '[[Ayla]], [[Brom]], [[Durga]], [[Kell]]' \
  "- down into the flooded vault under the gatehouse; Vex, the cinder cult's high priestess, waiting with six acolytes
- Durga cut Vex down; the acolytes threw her body on the brazier, it burned to ash
- Kell spent every spell slot he had holding the acolytes on the stairs
- no time to rest: back in the gatehouse, barricaded, the cult's drums beating outside — we stop there" \
  "In the flooded vault the party killed Vex, the high priestess of the cinder cult, and her body burned to ash. They fell back to the gatehouse with no time to rest, the cult's drums beating outside." \
  "- The cult knows its high priestess is dead.
- The party is barricaded in the gatehouse, unrested.
- The brass key to the flooded vault is still missing."
echo '- **Session 04** — 2026-09-26 — [[Session_04_The_Flooded_Vault]]. Vex dies; the party holds out in the gatehouse.' >> $SC/Diary.md

cat > $SC/NPCs/Hollis_Crane.md <<'MD'
# Hollis Crane

Innkeeper of the Drowned Lantern in Ashfall village, where the party lodges. Warm, generous, sells the party supplies at cost and passes on rumours about the keep.

## Secret

Hollis is the true leader of the cinder cult: Vex only ever spoke for him. The party does not know, and he means to keep it that way while they are useful to him.
MD
