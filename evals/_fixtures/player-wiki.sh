# Shared starting state for the Player Wiki cases: workspace-en.sh's Workspace with a
# Chronicle for Heroes (one Chapter linking its Session and an NPC), a World place and a
# House Rule each with a DM-only section, and the NPC and Place Templates as Setup writes
# them (with their Secrets heading). Every note here is INVENTED test content. Set before
# sourcing:
#   PW_KEY  yes: the Workspace Config already has its player_wiki key, writing to
#           $HOME/Player_Wiki (outside the Workspace); no (default): none yet
PW_KEY=${PW_KEY:-no}
. "$(dirname "$0")/../_fixtures/workspace-en.sh"

for t in NPC Place; do
  printf '## Description\n\n—\n\n## Secrets\n\n—\n' > "Templates/$t.md"
done
mkdir -p Campaigns/Heroes/Chronicle Homebrew/House_Rules
cat > Campaigns/Heroes/Chronicle/Chapter_03_Into_the_Keep.md <<'MD'
# Chapter 3: Into the Keep

[[Session_03_Into_the_Keep|Session 3: Into the Keep]]

The road climbed out of the fog, and at the gate of the keep [[Campaigns/Heroes/NPCs/Mira_Vell|Mira Vell]] was waiting with a lantern.
MD
printf '# Voice\n\nTell it as a weary soldier would.\n' > Campaigns/Heroes/Chronicle/Voice.md
cat > World/Orsenna/Places/Porto_Ladro.md <<'MD'
# Porto Ladro

## Description

A harbour town of smugglers on the Orsenna coast.

## Secrets

The harbourmaster sells every cargo twice; the Tide Court pays him.
MD
cat > Homebrew/House_Rules/Potions_as_Bonus_Actions.md <<'MD'
# Potions as Bonus Actions

## Rule

Drinking a potion is a Bonus Action.

## DM Notes

Drop it if fights get too easy.
MD

if [ "$PW_KEY" = yes ]; then
  cat >> workspace-config.yml <<YML

player_wiki:
  output: $HOME/Player_Wiki
  include: [reference, homebrew, world, characters]
  chronicles: [Heroes]
  dm_only_headings: [Secrets, DM Notes]
YML
fi
