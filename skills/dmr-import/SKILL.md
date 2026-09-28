---
name: dmr-import
description: Import official D&D entries into a DM Realm Workspace's Reference — spells, monsters, items, feats, classes, subclasses, species, backgrounds, conditions, rules. Use when the DM asks to add or import one by name ("add the Goblin"), needs the official version of one, or pastes an official text to add.
argument-hint: <what to import, e.g. Fireball, the Goblin>
allowed-tools: Read, Glob, Grep, Write, Edit, Skill, Bash(mkdir:*), Bash(python3:*), Bash(sh:*), Bash(DMR_SOURCE_CACHE=*)
---

# Import

Bring official entries from the Trusted Source into Reference: one note per entry, translated into the Workspace Language. The rules — where each kind goes, the Edition, Off-Edition Material, the note's format, translation and names — are the `dmr-workspace` skill's structure.md; this skill is the procedure that applies them. Speak to the DM in the Workspace Language.

1. **Load the rules and the data.** Invoke `dmr-workspace` (read its structure.md in full), then `dmr-trusted-source`.
2. **Pasted official text** (from a book, a PDF, a site) is never written into the Workspace — structure.md's "Trusted Source" rule. Import the thing by name from the Trusted Source instead; when it has no such entry, say that it cannot be Reference, and offer a Homebrew version in the DM's own words.
3. **The Edition in use**, as structure.md's "Fixed after Setup" reads it: the source properties of the rules notes already in Reference, or, with none, the Workspace Config's `edition`. With none, this Import is the one that fixes it.
4. **Find each entry** the DM named — several in one request are handled one by one:
   1. Its English name: the Translation Glossary's row for the DM's words, or your translation of them.
   2. Its kind and file from `dmr-trusted-source`'s table; Grep for `"name": "<English name>"` (case-insensitive). When the DM names no kind, one name can be several kinds at once (a spell and a feat): search every kind in the table — for spells and monsters, at least the files of the Edition's books — before choosing.
   3. The version, by structure.md's "Edition" and "Off-Edition Material": the entry from a book of the Edition in use; else the Edition's reprint of it; else it is Off-Edition Material filling a gap. A reprint is recorded only on the older entry, in `reprintedAs`: a 2014 entry without it has no 2024 version, and no other file needs checking. The helper's `--meta` (step 5) gives an entry's `edition`.
   4. The special cases in structure.md's Reference section: a specific magic weapon or armor is its generic variant, a 2024 lineage is its species, a subclass is the one under the Edition's class (`--class-source`), and "the Conditions" or "the Actions" is the whole set.
5. **Render** each entry with the helper next to this file — never from memory:

   ```sh
   DMR_SOURCE_CACHE="${CLAUDE_PLUGIN_DATA}/source-cache" python3 "<this skill's base directory>/render-entry.py" <data file> "<English name>" <BOOK> --edition <Edition in use> [--key <key>] [--class-source <BOOK>]
   ```

   It prints the entry in English Markdown — for a monster, with its stat block fence under the heading, naming its own Edition's layout when it is Off-Edition (structure.md's "Stat blocks"); with the entry's description, when it has one, as its `## Description` section (structure.md's "Imported notes"); add `--meta` for JSON facts: `source_property`, `edition`, `reprinted_as`, and what placing the note needs (`level`, `class`, `race`, `title`, `option_kind` — null for a kind it has no name for, named then from the entry — `magic`, `generic_variant`). Its exits: **3** the Trusted Source is unreachable and the file is not cached; **4** no such file; **5** no such entry; **6** the entry, or its description, uses a copy modifier or a field DM Realm cannot render yet; **7** the entry is malformed or cannot be rendered; **8** several entries match (it lists them: pass `--key` or `--class-source`). On any of them, write nothing for that entry.
6. **Place it**: the folder structure.md gives its kind (named from the Edition's default name, translated), and the file name from its translated name (the helper's `title` for a subrace). When a note is already at that path, the entry is already imported: report it and leave the note as it is — replacing it is the update check, not an Import. A monster's stat block name is checked as structure.md's "Names in the bestiary" says; a clash is asked about in step 7.
7. **Ask once, then stop.** Gather everything that needs the DM into one message: each Off-Edition player option (say it is Off-Edition and which Edition it belongs to — structure.md's consent rule), each name that matches several entries (list kind and book for each), and each stat block name clash (ask for another name for this monster's stat block). Write the entries that need nothing from the DM first; write the others only after the DM answers, and only the ones approved.
8. **Translate** the rendered text into the Workspace Language, term by term as structure.md's "Translating a term" says: add every translation you choose to the Translation Glossary before writing the note, and give a fallback term its English original at its first occurrence in the note. A monster's stat block fence is translated with its text: every value, the same words as the body, while every key stays English as structure.md's "Stat blocks" lists them. An English Workspace has no translation step.
9. **Write the note** in structure.md's "Imported notes" format — frontmatter with only the source property (`source_property` from `--meta`) and, for a monster, `statblock: inline`; the `#` heading; the Edition callout for Off-Edition Material; for a monster, its stat block fence; then the text. Create its folders (`mkdir -p`) only now.
10. **Report**, item by item: the note's path and its source; each Off-Edition note; each generic variant imported in place of the item asked for; and each entry not written, with why — unreachable, no such entry, already imported, cannot be rendered, or the question you asked. When this Import fixed the Edition, say that it is now fixed, and to which.

Done when every entry the DM named is written, reported, or waiting on the one question you asked — and nothing else in the Workspace changed.
