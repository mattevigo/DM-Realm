# Sourced after designed-adventure.sh by adventure-review: The Drowned Bell grows to three
# Parts, with three flaws for Review to find — the Sunken Temple's one conclusion has a
# single clue, the Sunken Temple (not the last Part) has no way out, and the Drowned Choir
# fields six CR 5 Bell Wraiths against a level 3–5 Adventure. Every note is INVENTED.
mkdir -p Adventures/The_Drowned_Bell/Encounters Homebrew/Monsters
cat > Adventures/The_Drowned_Bell/README.md <<'MD'
# The Drowned Bell

## Pitch

A temple bell sunk in a harbour tolls at night, and the drowned answer it.

## Level Range

3–5

## Length

Three or four sessions.

## World

Orsenna — World › Orsenna

## Tone

Damp dread, salt and candle smoke.

## Hook

A fisherman's daughter walked into the sea when the bell rang.

## Parts

1. [[Adventures/The_Drowned_Bell/Parts/The_Harbour|The Harbour]] — the party hears the bell and finds the pier.
2. [[Adventures/The_Drowned_Bell/Parts/The_Sunken_Temple|The Sunken Temple]] — under the water, the drowned choir sings.
3. [[Adventures/The_Drowned_Bell/Parts/The_Bell_Tower|The Bell Tower]] — the bell is silenced, or rung for good.
MD
cat > Adventures/The_Drowned_Bell/Parts/The_Sunken_Temple.md <<'MD'
# The Sunken Temple

## Summary

The temple lies beneath the pier, half flooded; its choir never stopped singing.

## Structure

- The flooded nave, then the choir loft, where the [[Adventures/The_Drowned_Bell/Encounters/The_Drowned_Choir|Drowned Choir]] waits.

## Clues

- **The bell-ringer is the high priest**: the choir loft's hymnal.

## Ways out
MD
cat > Adventures/The_Drowned_Bell/Parts/The_Bell_Tower.md <<'MD'
# The Bell Tower

## Summary

The party climbs the drowned tower and silences the bell, or rings it once more.

## Structure

- The stair, then the belfry.

## Clues

- **The bell can be silenced with the priest's name**: the belfry's carving, the hymnal's last page, the ghost of the bell-ringer.

## Ways out
MD
cat > Adventures/The_Drowned_Bell/Encounters/The_Drowned_Choir.md <<'MD'
# The Drowned Choir

In the choir loft of [[Adventures/The_Drowned_Bell/Parts/The_Sunken_Temple|the Sunken Temple]].

## Situation

The choir sings on, and turns on whoever interrupts the hymn.

## Creatures

- 6 [[Bell_Wraith|Bell Wraiths]]
MD
cat > Homebrew/Monsters/Bell_Wraith.md <<'MD'
---
statblock: inline
---

# Bell Wraith

## Stat Block

```statblock
name: Bell Wraith
size: Medium
type: undead
alignment: neutral evil
ac: 13
hp: 67
hit_dice: 9d8 + 27
speed: 0 ft., fly 40 ft. (hover)
stats: [6, 16, 16, 10, 12, 15]
cr: "5"
```
MD
