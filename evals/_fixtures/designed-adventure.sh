# Sourced after workspace-en.sh: a designed Adventure, The Drowned Bell, set in the DM's
# world Orsenna — its notes have no source property (ADR 0020). A Heroes Campaign plot,
# the Flooded Crypt, written for that table. Every note here is INVENTED test content.
mkdir -p Adventures/The_Drowned_Bell/Parts Adventures/The_Drowned_Bell/Places
cat > Adventures/The_Drowned_Bell/README.md <<'MD'
# The Drowned Bell

## Pitch

A temple bell sunk in a harbour tolls at night, and the drowned answer it.

## Level Range

3–5

## World

Orsenna — World › Orsenna

## Parts

1. [[Adventures/The_Drowned_Bell/Parts/The_Harbour|The Harbour]] — the party hears the bell and finds the pier.
MD
cat > Adventures/The_Drowned_Bell/Parts/The_Harbour.md <<'MD'
# The Harbour

## Summary

The bell tolls at midnight; the party traces it to the old pier.

## Structure

- The tolling, then [[Adventures/The_Drowned_Bell/Places/The_Old_Pier|The Old Pier]].

## Clues

- **The bell is under the pier**: the tolling, the wet footprints, the fisherman's tale.

## Ways out

- Down into the water, to the sunken temple.
MD
printf '# The Old Pier\n\nRotting planks over black water, where the bell went under.\n' > Adventures/The_Drowned_Bell/Places/The_Old_Pier.md

printf '# Flooded Crypt\n\nA drowned shrine below a ruined chapel. [[Ayla]] found its altar in Session 5.\n' > Campaigns/Heroes/Places/Flooded_Crypt.md
