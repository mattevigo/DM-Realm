#!/usr/bin/env python3
"""A Session's Table Record: what MapForge recorded of an evening (ADR 0012).

  table-record.py find <workspace> <campaign folder> [<YYYY-MM-DD>]
  table-record.py read <workspace> <session log file>

MapForge, the DM's table tool, owns `.mapforge/` and the files beside a Map; this
helper only reads them (ADR 0011). MapForge writes one Session Log per evening,
`.mapforge/sessions/<UTC start>.jsonl`, and one Combat Log per fight beside its Map,
`<map without extension>.combat/<UTC start>.jsonl`, both append-only JSON Lines; a
line that will not decode (a truncated last line) is dropped and an unknown line
skipped. Times are given in the machine's local time, the clock the DM played by.

find prints a JSON list of the Session Logs, in start order — only those starting on
that local date when one is given:
  file        the log's file name
  started     its start, UTC; date and time: the same, local (YYYY-MM-DD, HH:MM)
  running     true when it has no sessionEnded: an evening MapForge has not closed
  maps        the Maps it names, relative to the Workspace root, first seen first
  campaigns   the Campaign folders those Maps lie under
  belongs     this: a Map lies under the Campaign folder; other: every Map lies under
              other Campaigns; none: no Map in any Campaign (no Map, an Adventure's…)
  written_in  the notes whose Live Notes already hold it, by structure.md's marker
              `%% mapforge <file> %%` (hidden folders such as .trash are not read)
Exit 2: not a Workspace (no workspace-config.yml), or a malformed date.
Exit 3: no such Campaign folder.

read prints one JSON object — file, started, date, time, running, and events, in
the order they happened:
  map      {time, map, name}: the first Map, and each change of Map (a comment with
           no Map changes nothing)
  comment  {time, text}: the DM's own words, as typed
  roll     {time, name, roll, ability, skill, d20, modifier, total, dc}: a saving
           throw (roll: save, with its ability) or an ability check (roll: check,
           with its skill) outside a fight, by the Pawn's label; ability and skill
           named as the rules write them (Wisdom, Sleight of Hand); total is d20 plus
           modifier, dc null when none was set. MapForge records a Roll and never
           resolves it, and neither does this.
  fight    {time, end_time, map, log, found, ended, rounds, combatants, notes, rolls}: the
           Combat Log the Session Log points at, on the Map in use, folded as MapForge
           folds it (Corrections applied at the Turn they target, a later Turn's number
           winning). rounds: the highest Round a Turn was played in. combatants:
           everyone who fought, in the order they joined — name (the Pawn's label),
           kind, monster (a Creature's Monster, from the Map's fog file as it is now,
           or null), hp, max_hp, temp_hp (null when untyped), conditions, exhaustion,
           concentrating, dropped (a Turn left it at 0 hit points or fewer, its
           Corrections applied), benched (out of the Order at the end). notes: each
           noteAdded, {name, text}. rolls: each Roll made in the fight, as above with
           the round it was made in instead of the time. found is false when the
           Combat Log is not there; ended is false for a fight not closed.
Moves are left out.
Exit 2: not a Workspace, or a file name that is not a log's. Exit 3: no such log.
"""
import datetime
import importlib.util
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
LOG_NAME = re.compile(r"^[^./\\][^/\\]*\.jsonl$")
MARKER = re.compile(r"%% mapforge (\S+\.jsonl) %%")
STAMP = re.compile(r"^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(?:\.\d+)?Z$")
SESSION_LINES = ("comment", "pawnMoved", "savingThrow", "abilityCheck", "encounterStarted", "encounterEnded")


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    loaded = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loaded)
    return loaded


folders = module("workspace_folders", os.path.join(HERE, "..", "dmr-setup", "workspace-folders.py"))


def fail(code, message):
    print(f"table-record: {message}", file=sys.stderr)
    return code


def entries(path):
    """The JSON objects of a JSON Lines file: a line that will not decode is dropped, and
    anything but an object skipped."""
    out = []
    with open(path, encoding="utf-8") as f:
        for raw in f:
            try:
                entry = json.loads(raw)
            except ValueError:
                continue
            if isinstance(entry, dict):
                out.append(entry)
    return out


def local(stamp):
    """(date, HH:MM) in local time of a UTC stamp (fractional seconds allowed), or (None, None)."""
    found = STAMP.match(stamp) if isinstance(stamp, str) else None
    if not found:
        return None, None
    moment = datetime.datetime.strptime(found.group(1), "%Y-%m-%dT%H:%M:%S").replace(tzinfo=datetime.timezone.utc)
    moment = moment.astimezone()
    return moment.strftime("%Y-%m-%d"), moment.strftime("%H:%M")


def sessions_dir(workspace):
    return os.path.join(workspace, ".mapforge", "sessions")


def evening(workspace, name):
    """The log's entries and its header: file, started, date, time, running."""
    log = entries(os.path.join(sessions_dir(workspace), name))
    started = next((e.get("startedAt") for e in log if e.get("line") == "sessionStarted"), None)
    date, time = local(started)
    running = not any(e.get("line") == "sessionEnded" for e in log)
    return log, {"file": name, "started": started, "date": date, "time": time, "running": running}


def campaign_folders(workspace):
    with open(os.path.join(workspace, "workspace-config.yml"), encoding="utf-8") as f:
        top = folders.config_names(f.read())["campaigns"]
    root = os.path.join(workspace, top)
    if not top or not os.path.isdir(root):
        return []
    return sorted(f"{top}/{d}" for d in os.listdir(root) if os.path.isdir(os.path.join(root, d)))


def under(path, folder):
    return path.startswith(folder + "/")


def written_in(workspace):
    """{log file: [notes holding its marker]}, over the Workspace's notes (hidden folders —
    .mapforge, .obsidian, .trash — are not notes)."""
    notes = {}
    for dirpath, dirnames, filenames in os.walk(workspace):
        dirnames[:] = [d for d in dirnames if not d.startswith(".")]
        for filename in filenames:
            if not filename.lower().endswith(".md"):
                continue
            path = os.path.join(dirpath, filename)
            try:
                with open(path, encoding="utf-8") as f:
                    text = f.read()
            except (UnicodeDecodeError, OSError):
                continue
            rel = os.path.relpath(path, workspace).replace(os.sep, "/")
            for name in set(MARKER.findall(text)):
                notes.setdefault(name, []).append(rel)
    return {name: sorted(paths) for name, paths in notes.items()}


def find(workspace, campaign, date):
    folder = os.path.normpath(campaign).replace(os.sep, "/")
    if not os.path.isdir(os.path.join(workspace, folder)):
        return fail(3, f"no Campaign folder '{campaign}' in the Workspace")
    others = [c for c in campaign_folders(workspace) if c != folder]
    marks = written_in(workspace)
    out = []
    directory = sessions_dir(workspace)
    names = sorted(n for n in os.listdir(directory) if n.endswith(".jsonl")) if os.path.isdir(directory) else []
    for name in names:
        log, head = evening(workspace, name)
        if date and head["date"] != date:
            continue
        maps = []
        for entry in log:
            m = entry.get("map")
            if isinstance(m, str) and m not in maps:
                maps.append(m)
        campaigns = sorted({c for m in maps for c in [folder] + others if under(m, c)})
        if folder in campaigns:
            belongs = "this"
        elif maps and all(any(under(m, c) for c in others) for m in maps):
            belongs = "other"
        else:
            belongs = "none"
        head.update(maps=maps, campaigns=campaigns, belongs=belongs, written_in=marks.get(name, []))
        out.append(head)
    out.sort(key=lambda h: (h["started"] or "", h["file"]))
    print(json.dumps(out, ensure_ascii=False))
    return 0


def monsters(workspace, map_path):
    """{Pawn id: Monster name} from the Map's fog file, when it says."""
    path = os.path.join(workspace, os.path.splitext(map_path)[0] + ".fog.json")
    try:
        with open(path, encoding="utf-8") as f:
            fog = json.load(f)
        return {p["id"]: p["monsterName"] for p in fog.get("pawns", [])
                if isinstance(p, dict) and isinstance(p.get("monsterName"), str) and "id" in p}
    except (OSError, ValueError, AttributeError):
        return {}


ROLLS = {"savingThrow": "save", "abilityCheck": "check"}


def rule_name(key):
    """MapForge's key for an ability or skill as the rules write it: sleightOfHand → Sleight of Hand."""
    if not isinstance(key, str):
        return None
    words = re.sub(r"(?<!^)([A-Z])", r" \1", key).split()
    return " ".join(w if w.lower() == "of" and i else w.capitalize() for i, w in enumerate(w.lower() for w in words))


def roll(entry, name):
    """A saving throw or ability check, from a Session Log line or a Combat Log Change."""
    d20, modifier = entry.get("d20"), entry.get("modifier")
    total = d20 + modifier if isinstance(d20, int) and isinstance(modifier, int) else None
    kind = entry.get("line") or entry.get("type")
    return {"name": name, "roll": ROLLS[kind],
            "ability": rule_name(entry.get("ability")) if kind == "savingThrow" else None,
            "skill": rule_name(entry.get("skill")) if kind == "abilityCheck" else None,
            "d20": d20, "modifier": modifier, "total": total, "dc": entry.get("difficultyClass")}


# A Change's type → the Stat Block number it sets to its `to` (absent `to`: untyped).
NUMBERS = {"hpChanged": "hp", "maxHPChanged": "max_hp", "tempHPChanged": "temp_hp", "exhaustionChanged": "exhaustion"}


def combatant(snapshot):
    """A Combatant as it joins: its name, kind and Stat Block."""
    block = snapshot.get("block") or {}
    return {"name": snapshot.get("name"), "kind": snapshot.get("kind"),
            "hp": block.get("currentHP"), "max_hp": block.get("maxHP"), "temp_hp": block.get("temporaryHP"),
            "conditions": set(block.get("conditions") or []), "exhaustion": block.get("exhaustion", 0),
            "concentrating": bool(block.get("isConcentrating")), "dropped": False, "benched": False}


def down(c):
    return isinstance(c["hp"], int) and c["hp"] <= 0


def fold(log):
    """{Combatant id: Combatant}, in the order they joined, the fight's notes and Rolls, the
    highest Round, and whether it ended — as MapForge's CombatLogFold reads the log."""
    fighters, notes, rolls, rounds, ended = {}, [], [], 0, False
    corrections = {}
    for entry in log:
        if entry.get("line") == "correction":
            key = (entry.get("targetRound"), entry.get("targetCombatantID"))
            corrections.setdefault(key, []).extend(entry.get("changes") or [])

    def apply(change, round_):
        kind, cid = change.get("type"), change.get("combatantID")
        if kind == "combatantJoined":
            # Also how a Benched Pawn returns: its snapshot carries the numbers it has now.
            fighters[cid] = combatant(change)
            return
        c = fighters.get(cid)
        if c is None:
            return
        if kind in NUMBERS:
            c[NUMBERS[kind]] = change.get("to")
        elif kind in ("conditionAdded", "conditionRemoved"):
            (c["conditions"].add if kind == "conditionAdded" else c["conditions"].discard)(change.get("condition"))
        elif kind == "concentrationChanged":
            c["concentrating"] = bool(change.get("isConcentrating"))
        elif kind == "combatantRemoved":
            c["benched"] = True
        elif kind == "noteAdded":
            notes.append({"name": c["name"], "text": change.get("text")})
        elif kind in ROLLS:
            rolls.append({"round": round_, **roll(change, change.get("name") or c["name"])})

    for entry in log:
        kind = entry.get("line")
        if kind == "encounterStarted":
            for snapshot in entry.get("combatants") or []:
                fighters[snapshot.get("id")] = combatant(snapshot)
        elif kind == "turn":
            rounds = max(rounds, entry.get("round") or 0)
            fixes = corrections.get((entry.get("round"), entry.get("combatantID")), [])
            fixed = {f.get("combatantID") for f in fixes if f.get("type") == "hpChanged"}
            # A drop inside the Turn counts, unless a Correction to the Turn rewrites those hit points.
            for change in entry.get("changes") or []:
                apply(change, entry.get("round"))
                c = fighters.get(change.get("combatantID"))
                if change.get("type") == "hpChanged" and c and down(c) and change.get("combatantID") not in fixed:
                    c["dropped"] = True
            for change in fixes:
                apply(change, entry.get("round"))
                c = fighters.get(change.get("combatantID"))
                if change.get("type") == "hpChanged" and c and down(c):
                    c["dropped"] = True
        elif kind == "encounterEnded":
            ended = True
    return fighters, notes, rolls, rounds, ended


def fight(workspace, start, end, map_path):
    _, time = local(start.get("at"))
    _, end_time = local(end.get("at")) if end else (None, None)
    log = f"{os.path.splitext(map_path)[0]}.combat/{start.get('logFile')}" if map_path else None
    path = os.path.join(workspace, log) if log else None
    event = {"kind": "fight", "time": time, "end_time": end_time, "map": map_path, "log": log,
             "found": bool(path and os.path.isfile(path)), "ended": end is not None, "rounds": 0,
             "combatants": [], "notes": [], "rolls": []}
    if not event["found"]:
        return event
    fighters, notes, rolls, rounds, ended = fold(entries(path))
    named = monsters(workspace, map_path)
    event.update(ended=ended, rounds=rounds, notes=notes, rolls=rolls, combatants=[
        {"name": c["name"], "kind": c["kind"], "monster": named.get(cid) if c["kind"] == "creature" else None,
         "hp": c["hp"], "max_hp": c["max_hp"], "temp_hp": c["temp_hp"], "conditions": sorted(c["conditions"]),
         "exhaustion": c["exhaustion"], "concentrating": c["concentrating"],
         "dropped": c["dropped"], "benched": c["benched"]}
        for cid, c in fighters.items()])
    return event


def read(workspace, name):
    if not LOG_NAME.match(name):
        return fail(2, f"'{name}' is not the file name of a Session Log")
    if not os.path.isfile(os.path.join(sessions_dir(workspace), name)):
        return fail(3, f"no Session Log '{name}' in .mapforge/sessions")
    log, head = evening(workspace, name)
    events, current = [], None
    for i, entry in enumerate(log):
        kind = entry.get("line")
        if kind not in SESSION_LINES:
            continue
        _, time = local(entry.get("at"))
        m = entry.get("map")
        if isinstance(m, str) and m != current:
            current = m
            events.append({"kind": "map", "time": time, "map": m, "name": os.path.splitext(os.path.basename(m))[0]})
        if kind == "comment":
            events.append({"kind": "comment", "time": time, "text": entry.get("text")})
        elif kind in ROLLS:
            events.append({"kind": "roll", "time": time, **roll(entry, entry.get("label"))})
        elif kind == "encounterStarted":
            end = next((e for e in log[i + 1:] if e.get("line") in ("encounterEnded", "encounterStarted")), None)
            end = end if end and end.get("line") == "encounterEnded" else None
            events.append(fight(workspace, entry, end, current))
    head["events"] = events
    print(json.dumps(head, ensure_ascii=False))
    return 0


def main(argv):
    if len(argv) < 4 or argv[1] not in ("find", "read") or len(argv) > (5 if argv[1] == "find" else 4):
        print(__doc__, file=sys.stderr)
        return 2
    workspace = argv[2]
    if not os.path.isfile(os.path.join(workspace, "workspace-config.yml")):
        return fail(2, f"{workspace} is not a Workspace (no workspace-config.yml)")
    if argv[1] == "read":
        return read(workspace, argv[3])
    date = argv[4] if len(argv) == 5 else None
    if date is not None and not DATE.match(date):
        return fail(2, f"'{date}' is not a date (YYYY-MM-DD)")
    return find(workspace, argv[3], date)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
