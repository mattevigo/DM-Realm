# The Player Wiki is a copy written outside the Workspace, by a script

A Player Wiki is written by a script, `player-wiki.py`, never by the agent. It goes into a folder outside the Workspace, and the folder is rewritten from scratch at every update. The script decides from a key in the Workspace Config, `player_wiki`, what goes in:
- whole parts, namely Reference, Homebrew, World, Characters, and the Chronicle of each Campaign named;
- the folder it writes;
- the headings, in the Workspace Language, that mark a World or Homebrew section as the DM's only.

The Workspace is read, never changed. The Config stays the only DM Realm file in a Workspace, now with one more key.

## Why

- **It is a copy that leaks nothing.** Leaking is the one failure that matters.
- **A script gives the same output for the same notes.** It cannot drop or reword a line of official text, a Chapter or a Build, and a test can prove what it leaves out.
- **The parts were chosen with the link rules in mind:**
  - "Knowledge follows links" already keeps Reference, Homebrew and World free of any table's story.
  - A Character note holds no DM-only section.
  - A Chronicle is written for the players.
  - Only the DM's own World and Homebrew notes can hold a secret, which is why only they are filtered, by heading.

## Considered Options

- **The agent copies and cleans each note.** Rejected:
  - it is slow on hundreds of notes;
  - it may reword them;
  - no test can say what it would leave out.
- **The wiki inside the Workspace.** Rejected:
  - Obsidian would index every note twice;
  - every bare link would turn ambiguous;
  - a top-level folder cannot be added.
- **The selection asked every time, or a frontmatter flag on each note.** Rejected:
  - asking every time makes each update a questionnaire;
  - a flag is too fine for a choice made by whole parts, and it scatters DM Realm keys through the DM's notes.
- **Every Campaign note the Chronicle links to (NPCs, Places, Campaign homebrew).** Left for later:
  - those notes hold the DM's secrets under headings no rule fixes;
  - for now their links become plain text.
- **One Player Wiki per Campaign.** Rejected for now: the DM shares one wiki with all the players.

## Consequences

- **A note removed from the Workspace leaves the wiki** at the next update, because the folder is rewritten.
- **The script refuses to empty an unmarked folder.** It writes a marker file, and refuses to empty a folder that holds files but no marker. It keeps the folder's dot-entries (a `.git`, a generator's settings).
- **Links:**
  - a link to a note left out becomes plain text;
  - an embed of a note left out is dropped;
  - a file a note links to or embeds is copied, wherever it lives.
- **Stat blocks:**
  - a monster's or an NPC's fence is written as DM Realm's Markdown, with the Glossary's labels;
  - a Character's fence is dropped, because its Build is already Markdown.
- **Titles:** the `#` heading moves into a `title:` frontmatter key, so a generator does not show the title twice.
- **The filter is by heading only.** A secret under any other heading goes out. The script's report lists every section it removed, so the DM can see what the filter did and add a heading to `dm_only_headings`.
- **Publishing the folder is the DM's.** [ADR 0018](0018-the-player-wiki-site-is-built-with-a-pinned-quartz.md) builds it as a website when the DM asks for one; where it goes is the DM's.
