# Obsidian: pre-writing a fresh vault's `.obsidian/` config

Research date: 2026-09-25. Question: a skill creates a new Obsidian vault folder and writes `<vault>/.obsidian/` before Obsidian has ever opened it. It must (1) make internal links wikilinks using "Shortest path when possible", and (2) turn on the core Templates plugin with a given template folder.

## How to read this

- **Help pages**: Obsidian's official help at `obsidian.md/help/...`. Its Markdown source is the `obsidianmd/obsidian-help` GitHub repo. Raw links are given where they quote more exactly.
- **App code**: behaviour read from Obsidian's own shipped JavaScript. The public app package is `obsidian-1.13.7.asar`, downloadable from the official release at <https://github.com/obsidianmd/obsidian-releases/releases/download/v1.13.7/obsidian-1.13.7.asar.gz>. I read the identical local copy at `~/Library/Application Support/obsidian/obsidian-1.13.7.asar`. The code is minified, so identifiers like `ME` or `E4` are the bundler's names. These facts come from the vendor's shipped code, but no Obsidian documentation describes them, so they may change without notice.
- **Loader code**: the installer's own `main.js`, found in `/Applications/Obsidian.app/Contents/Resources/app.asar` (installer 1.12.7, <https://github.com/obsidianmd/obsidian-releases/releases/tag/v1.12.7>).
- **UNVERIFIED**: my own inference, or a claim with only community (non-staff) sources.

---

## A. Latest stable desktop version

**The latest stable (Public) desktop version is Obsidian 1.13.7, released 2026-08-12.**

- The changelog lists "1.13.7 Desktop, Public, August 12, 2026" (<https://obsidian.md/changelog/2026-08-12-desktop-v1.13.7/>). The newer desktop entries are 1.14.0 (2026-09-02), 1.14.1 (2026-09-08) and 1.14.2 (2026-09-15). All three are on the **Catalyst** channel, which is early access and not public (<https://obsidian.md/changelog/>, <https://obsidian.md/help/early-access>).
- The file the updater reads agrees: `"latestVersion": "1.13.7"` for the public channel and `"beta": {"latestVersion": "1.14.2"}` for early access (<https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/desktop-releases.json>, fetched 2026-09-25).
- The GitHub release `v1.13.7`, published 2026-08-12, ships installers for every desktop platform: `.dmg`, `.exe`, `.AppImage`, `.deb` and `.tar.gz` (<https://github.com/obsidianmd/obsidian-releases/releases/tag/v1.13.7>). There is a newer release, `v1.13.8` (2026-08-21), but it contains only an Android `.apk`. It is a mobile-only public release (<https://github.com/obsidianmd/obsidian-releases/releases/tag/v1.13.8>, <https://obsidian.md/changelog/2026-08-20-mobile-v1.13.8/>).

---

## B. Files and keys for (1) and (2)

### Recommended minimal config

```
<vault>/.obsidian/app.json
{
  "useMarkdownLinks": false,
  "newLinkFormat": "shortest"
}

<vault>/.obsidian/core-plugins.json
{
  "templates": true
}

<vault>/.obsidian/templates.json
{
  "folder": "Modelli"
}
```

`core-plugins.json` may list only `templates`, as shown, or the full map. Both work; see below.

### (1) Links: `app.json`

| UI setting (Settings → Files and links) | Key in `app.json` | Value you want | Built-in default |
|---|---|---|---|
| **Use [[Wikilinks]]** (toggle) | `useMarkdownLinks` (the inverse of the toggle) | `false` | `false` |
| **New link format** | `newLinkFormat` | `"shortest"` | `"shortest"` |

- The UI names and options come from the Settings help page. "New link format" offers "Shortest path when possible / Relative path to file / Absolute path in vault". "Use Wikilinks" means "Auto-generate Wikilinks for `[[links]]` … Disable this option to generate Markdown links instead" (<https://raw.githubusercontent.com/obsidianmd/obsidian-help/master/en/User%20interface/Settings.md>, <https://obsidian.md/help/settings>).
- Wikilinks are the documented default: "By default, due to its more compact format, Obsidian generates links using the Wikilink format." (<https://obsidian.md/help/links>)
- The keys and values come from the app code (see "How to read this"):
  - The defaults object contains `useMarkdownLinks:!1` (false) and `newLinkFormat:"shortest"`.
  - The dropdown's option values are `"shortest"`, `"relative"` and `"absolute"`.
  - The Wikilinks toggle is written as `setConfig("useMarkdownLinks", !toggle)`.
- **Both values you want are already Obsidian's defaults.** Writing them explicitly is harmless. It also pins them, so a future change to the defaults won't affect this vault.

### (2) Templates: `core-plugins.json` and `templates.json`

**The Templates settings are stored in `templates.json`.**
- Every core plugin saves its settings in `<configDir>/<plugin-id>.json`. The app code's core-plugin `loadData()` is `vault.readConfigJson(this.instance.id)`, and the Templates plugin's id is `"templates"`.
- The settings tab stores the "Template folder location" field under key `folder`. It also has `dateFormat` and `timeFormat`, which default to `YYYY-MM-DD` and `HH:mm` (<https://obsidian.md/help/plugins/templates>). All three are optional.
- The value is a folder path relative to the vault root, for example `"Templates"` or `"Modelli"`. The code passes it through `normalizePath` and then looks it up with `vault.getFolderByPath`.
- If the folder does not exist, inserting a template fails with `Template folder "<x>" not found.` The code also has the message `No template folder configured.` for when no folder is set. **So create the folder itself as well as writing the setting.**
- There is **no default template folder**. The plugin loads `options = (await loadData()) || {}`. The help page tells users to set the folder before inserting a template (<https://obsidian.md/help/plugins/templates>).

**Templates is already on by default.**
- In the app code the Templates plugin has `defaultOn = true`. The other default-on plugins are:
  - backlink, bases, bookmarks, canvas
  - command-palette, daily-notes, editor-status
  - file-explorer, file-recovery, global-search, graph
  - note-composer, outgoing-link, outline, page-preview
  - properties, switcher, sync, tag-pane, word-count
- The help page confirms only that "Some core plugins are disabled by default" (<https://obsidian.md/help/plugins>).
- So a fresh vault needs no `core-plugins.json` for Templates to be on. Writing `"templates": true` makes it explicit and survives any future change to the default.

### `core-plugins.json` format: object map now, array before

- **The current format is a JSON object** mapping each plugin id to a boolean. Real files written by 1.13.7 on this machine look like this (31 keys):

  `{"file-explorer": true, …, "templates": true, …, "bases": true, "webviewer": false}`
- **The older format was an array** of enabled ids. The app still reads it. From the 1.13.7 `CorePlugins.enable()`:
  - **Object map:** a key set to `true` enables the plugin, and a key set to `false` disables it. For **any id missing from the map, the plugin's `defaultOn` applies**, then the app calls `requestSaveConfig()`. That call rewrites the file as the full map (`saveConfig()` always writes the object form).
  - **Array (legacy):** the app reads `core-plugins-migration.json`, an object map, as the base. Then, for each id in a hard-coded list of the 26 older plugins, it sets the value to `true` if the id is in the array and `false` otherwise:

    `E4 = [file-explorer, global-search, switcher, graph, backlink, outgoing-link, tag-pane, page-preview, daily-notes, templates, note-composer, command-palette, slash-command, editor-status, starred, markdown-importer, zk-prefixer, random-note, outline, word-count, slides, audio-recorder, workspaces, file-recovery, publish, sync]`

    Newer plugins that are not in that list fall back to `defaultOn`. Examples are canvas, bookmarks, properties, bases and webviewer.
- **Answer to "does a partial file disable other core plugins?"**
  - **Partial object map** (`{"templates": true}`): **No.** Every other plugin gets its default, and Obsidian then fills in the full map.
  - **Partial array** (`["templates"]`): **Yes.** Every *older* core plugin not in the array is turned off: file explorer, search, quick switcher, graph, backlinks, command palette and more. **Never write the array form.**
- **When the format changed:** an Obsidian team member (joethei, relayed by moderator ariehen, 2024-11-07) explained that both `core-plugins.json` and `core-plugins-migration.json` are kept because "an old version of Obsidian still needs to be able to read it. And be able to modify it" (<https://forum.obsidian.md/t/what-is-plugins-migration-json-file/91180>). So by late 2024 there were two files: an array kept for old versions and an object map. Today the app writes only the object map to `core-plugins.json`. None of the 1.13.7-era vaults on this machine has a `core-plugins-migration.json`. **UNVERIFIED:** the exact version that switched `core-plugins.json` itself to the object map. I found no changelog entry for it.

### Does Obsidian accept a `.obsidian/` holding only these files?

**Yes.** The evidence:

- **`app.json` may hold only some keys.** In the app code:
  - `getConfig(key)` returns `config[key]`, or the built-in default when that is `undefined`.
  - `config` is `Object.assign({}, appearance.json, app.json)`.
  - A missing file reads as `null`: `readJson` returns `null` on `ENOENT`.
- Obsidian itself writes very small files. On this machine, vaults created by recent versions have `app.json` containing `{}` or `{"alwaysUpdateLinks": true}`. The app saves only keys that were explicitly set, and never saves the defaults.
- **Missing files are fine.**
  - A missing `core-plugins.json` means every plugin uses its `defaultOn`.
  - A missing `templates.json` gives options `{}`.
  - A missing `.obsidian/` directory is created: the vault config loader runs `mkdir(configDir)` when it does not exist.
- Obsidian's own team-deployment guide says: "We recommend creating a standardized template of the configuration folder to be deployed across your team's devices." It also says you can lock settings by blocking write access to `.obsidian` (<https://obsidian.md/help/teams/deploy>). Copying a `.obsidian` folder into another vault is also documented (<https://obsidian.md/help/manage-vaults>, "Transfer settings to another vault").
- **Invalid JSON is a problem.** `readJson` logs "failed to read JSON" and returns `undefined`, so the settings in that file are silently ignored. Write valid JSON, preferably pretty-printed with 2 spaces the way Obsidian writes it (`JSON.stringify(t, undefined, 2)`).

---

## C. Finding the installed version from a shell without opening Obsidian

### Installer version and app version are different numbers

- The desktop app has **two** versions, both shown at the top of Settings → General (<https://obsidian.md/help/updates>):
  - The **installer version** is the Electron shell. The help page says: "This is the version of Electron, the framework on which Obsidian is built, and it cannot be updated by the automatic update process." Updating it means downloading and running a new installer.
  - The **app version** is what auto-update changes.
  - On mobile, "The installer version is the same as the app version."
- How auto-update works, from the installer's loader `main.js` (see "How to read this"):
  1. It downloads `obsidian-<latestVersion>.asar` into Electron's `userData` directory.
  2. At startup it scans that directory for files named `obsidian-*.asar` and picks the highest version.
  3. It loads that file only if it is newer than the installer's `app.getVersion()`. Otherwise it loads the bundled `Resources/obsidian.asar`, whose `package.json` version is the installer version.
  4. If `minimumVersion` from `desktop-releases.json` is higher than the installer version, it refuses to update and requires a manual reinstall. The current minimum is `1.1.9`.
- The About panel shows `"<app version> (installer <installer version>)"` (1.13.7 `main.js`).
- **Rule: effective app version = max(installer version, highest `obsidian-X.Y.Z.asar` in the user config dir).**
  - Caveat 1: a newly downloaded asar is loaded only after a restart.
  - Caveat 2: an early-access (Catalyst) asar also lands there when early access is on. **UNVERIFIED:** that it keeps the same file-name pattern.
  - Caveat 3: stale asars can remain after a downgrade. Community reports describe deleting them to downgrade (<https://forum.obsidian.md/t/downgrade-version-on-windows/90147>).
- The app log `<userData>/obsidian.log` records lines such as `Loaded updated app package …/obsidian-1.13.7.asar` and `Latest version is 1.13.7`. These strings are in the loader code, and I observed them in the log on this machine.
- **`obsidian.json` holds no version.** It stores the vault list plus global flags. On this machine it contains only `{"vaults": {...}}`.

### User config directory ("global settings")

From <https://obsidian.md/help/data-storage>:

| OS | Global settings directory |
|---|---|
| macOS | `~/Library/Application Support/obsidian` |
| Windows | `%APPDATA%\Obsidian\` |
| Linux | `$XDG_CONFIG_HOME/obsidian/` or `~/.config/obsidian/` |

**UNVERIFIED:** Flatpak and Snap sandbox the config dir. By convention it is `~/.var/app/md.obsidian.Obsidian/config/obsidian/` for Flatpak and under `~/snap/obsidian/` for Snap.

### Per-OS commands

**macOS**
```sh
# Installer version
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' /Applications/Obsidian.app/Contents/Info.plist
# App version (highest downloaded asar, if newer than the installer)
ls ~/Library/Application\ Support/obsidian/obsidian-*.asar
```
- The installer is dragged into `/Applications` (<https://obsidian.md/help/install>).
- `CFBundleShortVersionString` equals the installer version. On this machine it reads 1.12.7, which matches the bundled `obsidian.asar` `package.json` `"version": "1.12.7"`.
- `CFBundleVersion` reads `0.14.8`. It is not the Obsidian version, so do not use it. **UNVERIFIED:** what it represents.

**Windows (UNVERIFIED paths)**
- Community reports put the per-user install in `%LOCALAPPDATA%\Obsidian\` (with `resources\obsidian.asar`) and the updater in `%LOCALAPPDATA%\obsidian-updater`. Downloaded asars go to `%APPDATA%\obsidian\` (<https://forum.obsidian.md/t/downgrade-version-on-windows/90147>, <https://forum.obsidian.md/t/make-the-installation-process-more-transparent-on-windows/13148>).
- The universal `.exe` can also install for all users (<https://obsidian.md/help/teams/deploy>), so also check `%ProgramFiles%\Obsidian`.
- Installer version: `(Get-Item "$env:LOCALAPPDATA\Obsidian\Obsidian.exe").VersionInfo.ProductVersion`. **UNVERIFIED:** that it matches the installer version.
- App version: `Get-ChildItem "$env:APPDATA\obsidian\obsidian-*.asar"`.

**Linux**
- Official packages are Snap, AppImage and Flatpak (`md.obsidian.Obsidian`) (<https://obsidian.md/help/install>). GitHub releases also ship `.deb` and `.tar.gz` (<https://github.com/obsidianmd/obsidian-releases/releases/tag/v1.13.7>).
- Installer version, by package type:
  - `flatpak info md.obsidian.Obsidian`
  - `snap list obsidian`
  - `dpkg-query -W obsidian` (**UNVERIFIED** package name)
  - AppImage: the version is in the file name `Obsidian-<version>.AppImage`
- App version: `ls "${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"/obsidian-*.asar`.

### Official Obsidian CLI (not suitable for this)

- Docs: <https://obsidian.md/help/cli> (source: <https://raw.githubusercontent.com/obsidianmd/obsidian-help/master/en/Extending%20Obsidian/Obsidian%20CLI.md>).
- It requires the **1.12 installer (1.12.7+)** and must be turned on under Settings → General → Command line interface. `obsidian version` shows the Obsidian version.
- **Why it doesn't fit:** "Obsidian CLI requires the Obsidian app to be running. If Obsidian is not running, the first command you run launches Obsidian." So `obsidian version` fails the "without opening the app" requirement.
- Registration by platform:
  - macOS: a symlink `/usr/local/bin/obsidian → /Applications/Obsidian.app/Contents/MacOS/obsidian-cli`.
  - Windows: an `Obsidian.com` redirector next to `Obsidian.exe`, plus a PATH entry.
  - Linux: a copy at `~/.local/bin/obsidian`.
- The 1.13.7 `main.js` also refuses CLI use with "Command line interface is not enabled…" when the setting is off. It warns "Your Obsidian installer is out of date" for installers older than 1.11.7.
- **Obsidian Headless** (`npm i -g obsidian-headless`, command `ob`, open beta) is a separate client for Sync and Publish that runs without the desktop app (<https://obsidian.md/help/headless>). It does not configure vault settings.

---

## D. Other things a tool writing a fresh vault should know

### Registering the vault

**"Open folder as vault" is enough. The tool does not need to edit `obsidian.json`.**
- The documented flow is Manage vaults → **Open folder as vault** → pick the folder (<https://obsidian.md/help/vault>, <https://obsidian.md/help/manage-vaults>).
- In the 1.13.7 `main.js`, the `vault-open` handler `p(path)` does the rest:
  1. Checks that the folder exists and is accessible.
  2. Reuses the entry in the in-memory vault list if the path is already there.
  3. Otherwise adds `{path, ts: Date.now()}` under a new random 16-hex-char id, then opens the window.
- The vault list is persisted to `<userData>/obsidian.json` as `{"vaults": {"<id>": {"path": "...", "ts": <ms>, "open": true?}}}` (observed on this machine).
- **Don't write `obsidian.json` from the tool.**
  - The main process keeps this object in memory and rewrites the whole file on changes (`writeFileSync(obsidian.json, JSON.stringify(D))`). Edits made while Obsidian is running are likely to be lost (**inference**).
  - No Obsidian page documents this file's format.
  - There is no supported headless "register vault" command.
- **URIs and file opens don't register new folders.**
  - `obsidian://open?path=<abs path>` only searches **already-registered** vaults: "look for any vault that contains the path" (<https://obsidian.md/help/uri>). In code, an unmatched path shows a "vault not found" error box.
  - The macOS `open-file` event also only opens registered vaults.
  - **So the skill should tell the user to use "Open folder as vault" once.** After that, `obsidian://open?vault=<folder name>` works.
- Vault name = folder name (<https://obsidian.md/help/manage-vaults>, "Rename vault").
- Don't create vaults inside other vaults: links may not update correctly (<https://obsidian.md/help/data-storage>).

### Files not to pre-write

- **`workspace.json` / `workspace-mobile.json`** store the current layout "and update whenever you open a new file". Obsidian's own advice is to git-ignore them (<https://obsidian.md/help/data-storage>). Leave them out and Obsidian creates them.
- **`core-plugins-migration.json`**: don't write it. It is only for compatibility with old versions, as described above.
- **`appearance.json`**: only needed for theme and font settings. Link settings belong in `app.json`.
  - Obsidian loads `appearance.json` and `app.json` together, with `app.json` winning on conflicts.
  - On save, appearance keys are split back out to `appearance.json` and everything else goes to `app.json`.
- **Community plugins:** don't write `community-plugins.json` or `plugins/` unless community plugins are really needed. In a new vault they stay in Restricted mode until the user turns it off (<https://obsidian.md/help/manage-vaults>, "turn restricted mode off").
- **Don't create a vault inside the global settings folder** (<https://obsidian.md/help/data-storage>).

### Settings that changed format, or can surprise you

- **`core-plugins.json`** changed from an array to an object map, as described in section B. Always write the object form.
- **Obsidian rewrites config files on startup.** It rewrites `app.json`, `appearance.json`, `core-plugins.json` and `community-plugins.json` even when nothing changed, which a user reported in a forum feature request dated 2026-02-23 (<https://forum.obsidian.md/t/dont-update-app-json-appearance-json-community-plugins-json-core-plugins-json-on-app-start-for-no-reason/111529>). A partial `core-plugins.json` will also be expanded to the full map. **The skill must not treat these rewrites as drift or conflicts.**
- **Obsidian renames one old key on load.** The app code migrates `editorFontFamily` → `textFontFamily` in `app.json`/`appearance.json`. Use current key names.
- **The config folder name can be changed.** It is `.obsidian` by default. Users can set **Override config folder** (Settings → Files and links, "Must start with a dot"), and settings in the old folder do not carry over (<https://obsidian.md/help/configuration-folder>). The app code stores this override in the app's `localStorage`, not in the vault. So a brand-new vault always uses `.obsidian` unless that user has set an override on that device (**inference from code**).
- **Template folders are excluded from nothing by default.** Template notes appear in search and graph like any note. Users can add the folder under Settings → Files and links → Excluded files (<https://obsidian.md/help/settings>). **UNVERIFIED:** whether you want this. It is stored as `userIgnoreFilters` in `app.json`, default `null` (app code).
- **Properties can overwrite template variables.** When editing templates in Live Preview, the "Properties in document" panel can overwrite template variables that are not in quotes. Keep `{{date}}` quoted in frontmatter (<https://obsidian.md/help/plugins/templates>).

---

## This machine (read-only check, 2026-09-25)

- **Is Obsidian installed at `/Applications/Obsidian.app`?** Yes.
  - `Info.plist` `CFBundleShortVersionString` = **1.12.7**. This is the installer version; `CFBundleVersion` = 0.14.8.
  - Bundled `Resources/obsidian.asar` `package.json` version = 1.12.7.
  - `Contents/MacOS/obsidian-cli` exists (universal x86_64/arm64 binary).
  - `/usr/local/bin/obsidian` is not on PATH (`which obsidian` finds nothing), so the CLI is not registered.
- **Running app version is 1.13.7**, from `~/Library/Application Support/obsidian/obsidian-1.13.7.asar` (downloaded 2026-08-12). `obsidian.log` shows `Loaded updated app package …obsidian-1.13.7.asar` most recently at 2026-09-24. This is the current public release.
- **Does `~/Library/Application Support/obsidian/obsidian.json` exist?** Yes. It is `{"vaults": {...}}` with 3 vaults, including `/Users/mvigoni/DM Workspace` (marked `"open": true`). There is no version field.
- Existing vaults, for reference:
  - `core-plugins.json` is the 31-key object map, with `"templates": true`.
  - No vault has `templates.json`, so Templates is on but no folder is configured.
  - `app.json` is sparse (e.g. `{}`).
