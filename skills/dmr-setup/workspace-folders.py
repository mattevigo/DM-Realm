#!/usr/bin/env python3
"""Rename a top-level folder of a DM Realm Workspace.

  workspace-folders.py rename <workspace> <key> <new-name> [--from <folder-on-disk>]

Validates the new name as the Workspace rules require (a single folder name, not
empty after the name rules, not a duplicate), moves the folder, rewrites every
link in the Workspace's notes whose path starts with the old name, updates the
key's line in the Workspace Config and, for the templates key, Obsidian's
template folder. The folder on disk is the Config's current name, or --from when
the DM already edited the Config to the new name.

Exit 2: invalid name or key (nothing changed). Exit 3: the folder is not on disk.
"""
import json
import os
import re
import sys

KEYS = ["reference", "adventures", "homebrew", "characters", "campaigns", "dm_tools", "templates"]
BREAKS_LINKS = '#^[]|\\:*?"<>'


def fail(code, message):
    print(f"workspace-folders: {message}", file=sys.stderr)
    return code


def config_names(config_text):
    names = {}
    for key in KEYS:
        m = re.search(rf"^[ \t]*{key}:[ \t]*(.*)$", config_text, re.M)
        value = re.sub(r"(^|\s)#.*$", "", m.group(1)).strip().strip("\"'") if m else ""
        names[key] = value
    return names


def apply_name_rules(name):
    name = re.sub(r"[\s']+", "_", name.strip())
    return "".join(c for c in name if c not in BREAKS_LINKS).strip("_")


def rewrite_links(text, old, new):
    old_re = re.escape(old)
    # Wikilinks and embeds ([[Old/…]], ![[Old/…]]) and Markdown links ([…](Old/…), ](./Old/…), ](<Old/…>)).
    text = re.sub(rf"(!?\[\[)(\./)?{old_re}/", lambda m: f"{m.group(1)}{m.group(2) or ''}{new}/", text)
    text = re.sub(rf"(\]\(<?)(\./)?{old_re}/", lambda m: f"{m.group(1)}{m.group(2) or ''}{new}/", text)
    return text


def rename(workspace, key, requested, old=None):
    if key not in KEYS:
        return fail(2, f"unknown key '{key}'; keys are {', '.join(KEYS)}.")
    config_path = os.path.join(workspace, "workspace-config.yml")
    with open(config_path, encoding="utf-8") as f:
        config_text = f.read()
    names = config_names(config_text)
    old = old or names[key]

    if "/" in requested or "\\" in requested or ".." in requested:
        return fail(2, f"'{requested}' is a path; a top-level folder name is a single folder name.")
    new = apply_name_rules(requested)
    if not new:
        return fail(2, f"'{requested}' is empty once the name rules are applied.")
    others = {names[k].casefold() for k in KEYS if k != key and names[k]}
    on_disk = {e.casefold() for e in os.listdir(workspace) if e != old}
    if new.casefold() in others or (new != old and new.casefold() in on_disk):
        return fail(2, f"'{new}' is already the name of another folder in this Workspace.")
    if not os.path.isdir(os.path.join(workspace, old)):
        return fail(3, f"the folder '{old}' is not in the Workspace.")
    if new == old:
        print(f"'{old}' already has that name; nothing changed.")
        return 0

    os.rename(os.path.join(workspace, old), os.path.join(workspace, new))

    rewritten = 0
    for root, dirs, files in os.walk(workspace):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(root, name)
            with open(path, encoding="utf-8") as f:
                text = f.read()
            updated = rewrite_links(text, old, new)
            if updated != text:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(updated)
                rewritten += 1

    config_text = re.sub(
        rf"^([ \t]*{key}:[ \t]*)(\"[^\"]*\"|'[^']*'|[^#\n]*?)([ \t]*(#.*)?)$",
        lambda m: f"{m.group(1)}{new}{m.group(3)}", config_text, count=1, flags=re.M)
    with open(config_path, "w", encoding="utf-8") as f:
        f.write(config_text)

    done = [f"moved the folder", f"rewrote links in {rewritten} note(s)", "updated the Workspace Config"]
    templates_json = os.path.join(workspace, ".obsidian", "templates.json")
    if key == "templates" and os.path.exists(templates_json):
        with open(templates_json, encoding="utf-8") as f:
            settings = json.load(f)
        settings["folder"] = new
        with open(templates_json, "w", encoding="utf-8") as f:
            json.dump(settings, f, indent=2)
            f.write("\n")
        done.append("pointed Obsidian's template folder at it")
    print(f"Renamed '{old}' to '{new}': {', '.join(done)}.")
    return 0


def main(argv):
    args = argv[1:]
    old = None
    if "--from" in args:
        i = args.index("--from")
        if i + 1 >= len(args):
            return fail(2, "--from needs a folder name.")
        old = args[i + 1]
        del args[i:i + 2]
    if len(args) == 4 and args[0] == "rename":
        return rename(args[1], args[2], args[3], old)
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
