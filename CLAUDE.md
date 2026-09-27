# DM-Realm

## Agent skills

### Issue tracker

Issues are cards on the Trello board `DM Realm` (https://trello.com/b/LsoFRUO2/dm-realm), accessed via the `trello` MCP server. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) as Trello labels. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Workspace

This repository is the `dm-realm` Claude Code plugin and its own marketplace (ADR 0002). It is not a Workspace: Workspaces are other folders that `/dm-realm:dmr-setup` sets up.

The Workspace rules (folders, Scopes, link rules, Edition, official data, language and names) live in exactly one place: the agent-only `dmr-workspace` skill, in `skills/dmr-workspace/structure.md`. Every `dmr-` skill loads `dmr-workspace` before touching a Workspace; never copy its rules elsewhere. When the rules change, run the plugin evals (below); the few scenarios in `docs/structure-scenarios.md` that have no eval yet are still checked by hand, as that file says.

## Plugin development

- **Manual loop:** make an empty folder, run `claude --plugin-dir <path to this repo>` in it, then `/dm-realm:dmr-setup`. After editing a skill or hook, run `/reload-plugins` in that session.
- **Evals:** cases live in `evals/<case>/` (`case.yaml` or `prompt.md` + `graders/`). Run the suite from the repo root with `claude plugin eval . --trust-plugin --scaffold --allow-tools Write Edit Bash WebFetch WebSearch --judge-model sonnet --no-publish` (add `--runs 1 --ablation none` for a cheap pilot, `--case <glob>` for one case or `--tag scenario` for the structure scenarios; keep `-j` at 3 or less, since more concurrent runs hit rate limits and time out). Cases list the tools they need (`Write`, `Edit`, `Bash`…) in `allowed_tools` and the flag grants them: the runner ignores a skill's own `allowed-tools`. `file_exists` and `target: files` see created files only, never empty folders, so folder checks grade the `trace` with an `llm` grader. A `{source: file, path}` target reads a file even when it existed before the run (so it can check a merge), but takes one exact path, no glob. Prefer `regex` graders: an `llm` judge over a long `trace` is noisy (it may not see the end of the trace), so use one only where no regex can express the check, and pilot such cases with `--runs 3`.
- **Hooks:** `claude plugin eval` runs the plugin's SessionStart hook in its sandbox (verified 2026-09-25), so evals cover the Workspace notice end to end. `for t in tests/*.test.sh; do sh "$t"; done` runs the fast script tests (hook, Source Cache, Import rendering and its stat block fences, Obsidian settings, Fantasy Statblocks layouts and how the 2024 abilities table renders, folder rename) with no agent; they check fence YAML with PyYAML or Ruby, run the layouts' JavaScript with Node, and render that table in headless Chrome with the stylesheet of the Obsidian installed on the machine, when those are installed, and say so when they are not.
- **Source Cache location:** `${CLAUDE_PLUGIN_DATA}/source-cache`, i.e. `~/.claude/plugins/data/<plugin id>/source-cache`: per machine, shared by every Workspace, kept across plugin updates, removed when the plugin is uninstalled. Skill markdown gets `${CLAUDE_PLUGIN_DATA}` substituted (verified); the Bash tool's environment does not have it, so `dmr-trusted-source` passes it to the helper as `DMR_SOURCE_CACHE`.
- **No network in evals:** the eval sandbox blocks outbound network (verified 2026-09-25) and cannot write plugin data. Research cases therefore set `EVAL_DMR_SOURCE_CACHE` (the helper's eval-only override; `case.yaml` passes only `EVAL_*` variables) and their scaffold seeds that cache in the sandbox home with INVENTED entries — invented text and pages also prove the answer came from the cache, not from memory. `sh tests/source-cache.test.sh` tests the helper against a fake `file://` mirror. Scaffold scripts only prepare a case's starting folder; they never contain Trusted Source data (ADR 0003).
