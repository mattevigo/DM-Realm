#!/bin/sh
# Source Cache: the local copy of the Trusted Source (the 5etools data in its public
# source mirror), one per machine, outside every Workspace, pinned to one release.
#
#   source-cache.sh release            print the pinned release (pins the latest if none)
#   source-cache.sh file data/<path>   print the local path of that file, fetched from
#                                      the pinned release the first time it is needed
#   source-cache.sh refresh            move the pin to the latest release and fetch every
#                                      cached file again from it (only when the DM asks)
#
# Exit 3: the Trusted Source is unreachable (and the file is not cached, or a refresh
#         could not complete: the old release stays pinned and intact).
# Exit 2: bad usage (a path outside data/, a cache inside a Workspace).
#
# DMR_SOURCE_CACHE  cache directory (default: $CLAUDE_PLUGIN_DATA/source-cache);
#   EVAL_DMR_SOURCE_CACHE overrides it in evals, whose sandbox cannot write plugin data.
# DMR_SOURCE_API / DMR_SOURCE_RAW  mirror endpoints, overridden only by tests
#   (EVAL_-prefixed too: `claude plugin eval` passes only EVAL_* variables from case.yaml).

API=${DMR_SOURCE_API:-${EVAL_DMR_SOURCE_API:-https://api.github.com/repos/5etools-mirror-3/5etools-src/releases/latest}}
RAW=${DMR_SOURCE_RAW:-${EVAL_DMR_SOURCE_RAW:-https://raw.githubusercontent.com/5etools-mirror-3/5etools-src}}
CACHE=${EVAL_DMR_SOURCE_CACHE:-${DMR_SOURCE_CACHE:-${CLAUDE_PLUGIN_DATA:+$CLAUDE_PLUGIN_DATA/source-cache}}}
CACHE=${CACHE:-$HOME/.local/share/dm-realm/source-cache}
case "$CACHE" in
  \~/*) CACHE="$HOME/${CACHE#\~/}" ;;
  /*) ;;
  *) CACHE="$PWD/$CACHE" ;;
esac

# file://~/… endpoints mean the home folder (evals pass them from case.yaml).
case "$API" in "file://~/"*) API="file://$HOME/${API#file://\~/}" ;; esac
case "$RAW" in "file://~/"*) RAW="file://$HOME/${RAW#file://\~/}" ;; esac

die() { echo "source-cache: $2" >&2; exit "$1"; }
unreachable() { die 3 "the Trusted Source (5etools mirror) cannot be reached, and $1."; }

# The Source Cache never lives inside a Workspace.
dir=$CACHE
while [ "$dir" != "/" ] && [ -n "$dir" ]; do
  [ -f "$dir/workspace-config.yml" ] && die 2 "refusing a Source Cache inside the Workspace at $dir."
  dir=$(dirname "$dir")
done

fetch() { # url dest: download atomically; fail without leaving a partial file
  mkdir -p "$(dirname "$2")" || return 1
  curl -fsSL --max-time 60 "$1" -o "$2.part" 2>/dev/null && mv "$2.part" "$2" || { rm -f "$2.part"; return 1; }
}

latest_release() {
  curl -fsSL --max-time 30 "$API" 2>/dev/null |
    sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1
}

pinned_release() {
  if [ ! -s "$CACHE/release" ]; then
    mkdir -p "$CACHE" || die 2 "cannot create $CACHE."
    tag=$(latest_release)
    [ -n "$tag" ] || unreachable "no release is pinned in the Source Cache yet"
    printf '%s\n' "$tag" > "$CACHE/release"
  fi
  head -n 1 "$CACHE/release"
}

case "${1:-}" in
  release)
    pinned_release
    ;;
  file)
    path=${2:-}
    case "$path" in
      data/*) ;;
      *) die 2 "only paths under data/ are in the Trusted Source: '$path'." ;;
    esac
    case "$path" in *..*) die 2 "'..' is not allowed in '$path'." ;; esac
    tag=$(pinned_release) || exit $?
    local_file="$CACHE/$tag/$path"
    if [ ! -f "$local_file" ]; then
      fetch "$RAW/$tag/$path" "$local_file" || unreachable "$path is not in the Source Cache"
    fi
    printf '%s\n' "$local_file"
    ;;
  refresh)
    old=$(pinned_release) || exit $?
    new=$(latest_release)
    [ -n "$new" ] || unreachable "the Source Cache stays on $old"
    if [ "$new" = "$old" ]; then
      echo "Source Cache up to date: $old is the latest release."
      exit 0
    fi
    count=0
    list="$CACHE/.refresh-list"
    (cd "$CACHE/$old" 2>/dev/null && find data -type f ! -name '*.part') > "$list"
    while IFS= read -r f; do
      fetch "$RAW/$new/$f" "$CACHE/$new/$f" || { rm -rf "$CACHE/$new" "$list"; unreachable "the refresh to $new could not fetch $f; the Source Cache stays on $old"; }
      count=$((count+1))
    done < "$list"
    rm -f "$list"
    printf '%s\n' "$new" > "$CACHE/release"
    rm -rf "$CACHE/$old"
    echo "Source Cache refreshed: $old -> $new ($count file(s) fetched again)."
    ;;
  *)
    die 2 "usage: source-cache.sh release | file data/<path> | refresh"
    ;;
esac
