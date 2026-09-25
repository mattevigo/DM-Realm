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

The Workspace rules (folders, Scopes, link rules, Edition, official data, language and names) live in exactly one place: the agent-only `dmr-workspace` skill, in `skills/dmr-workspace/structure.md`. Every `dmr-` skill loads `dmr-workspace` before touching a Workspace; never copy its rules elsewhere. When the rules change, re-run the scenarios in `docs/structure-scenarios.md` (it lists which changes need a re-run).

## Plugin development

- **Manual loop:** make an empty folder, run `claude --plugin-dir <path to this repo>` in it, then `/dm-realm:dmr-setup`. After editing a skill or hook, run `/reload-plugins` in that session.
- **Evals:** cases live in `evals/<case>/` (`case.yaml` or `prompt.md` + `graders/`). Run the suite from the repo root with `claude plugin eval . --trust-plugin --scaffold --allow-tools Write Bash --judge-model sonnet --no-publish` (add `--runs 1 --ablation none` for a cheap pilot, `--case <glob>` for one case). Cases list `Write` and `Bash` in `allowed_tools` and the flag grants them: the runner ignores a skill's own `allowed-tools`. `file_exists` and `target: files` see created files only, never empty folders, so folder checks grade the `trace` with an `llm` grader.
- **Hooks:** `claude plugin eval` runs the plugin's SessionStart hook in its sandbox (verified 2026-09-25), so evals cover the Workspace notice end to end. `sh tests/workspace-notice.test.sh` checks the hook script alone, in a second, with no agent. Scaffold scripts only prepare a case's starting folder; they never contain Trusted Source data (ADR 0003).
