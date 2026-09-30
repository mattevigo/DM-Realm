#!/bin/sh
# Source Cache: the local copy of the Trusted Source (the 5etools data in its public
# source mirror, and its images in the image mirror tagged in step with it), one per
# machine, outside every Workspace, pinned to one release.
#
#   source-cache.sh release            print the pinned release (pins the latest if none)
#   source-cache.sh file data/<path>   print the local path of that file, fetched from
#                                      the pinned release the first time it is needed
#   source-cache.sh image <path>       the same for an image, by the path an entry gives
#                                      it (`bestiary/MM/Goblin.webp`), from the image
#                                      mirror at the pinned release's tag (ADR 0008)
#   source-cache.sh refresh            move the pin to the latest release and fetch every
#                                      cached file and image again from it (only when
#                                      the DM asks)
#
# Exit 4: the pinned release has no such file.
# Exit 3: the Trusted Source is unreachable (and the file is not cached, or a refresh
#         could not complete: the old release stays pinned and intact).
# Exit 2: bad usage (a path outside data/, no cache directory, a cache inside a Workspace).
#
# DMR_SOURCE_CACHE  cache directory (default: $CLAUDE_PLUGIN_DATA/source-cache).
# DMR_SOURCE_API / DMR_SOURCE_RAW / DMR_SOURCE_IMG  mirror endpoints, overridden only by
#   tests.
# EVAL_DMR_SOURCE_*  win over all of the above: `claude plugin eval` passes only EVAL_*
#   variables from case.yaml, and its sandbox can neither write plugin data nor go online.

API=${EVAL_DMR_SOURCE_API:-${DMR_SOURCE_API:-https://api.github.com/repos/5etools-mirror-3/5etools-src/releases/latest}}
RAW=${EVAL_DMR_SOURCE_RAW:-${DMR_SOURCE_RAW:-https://raw.githubusercontent.com/5etools-mirror-3/5etools-src}}
IMG=${EVAL_DMR_SOURCE_IMG:-${DMR_SOURCE_IMG:-https://raw.githubusercontent.com/5etools-mirror-3/5etools-img}}
CACHE=${EVAL_DMR_SOURCE_CACHE:-${DMR_SOURCE_CACHE:-${CLAUDE_PLUGIN_DATA:+$CLAUDE_PLUGIN_DATA/source-cache}}}
[ -n "$CACHE" ] || { echo "source-cache: no Source Cache directory: set DMR_SOURCE_CACHE." >&2; exit 2; }
case "$CACHE" in
  \~/*) CACHE="$HOME/${CACHE#\~/}" ;;
  /*) ;;
  *) CACHE="$PWD/$CACHE" ;;
esac

# file://~/… endpoints mean the home folder (evals pass them from case.yaml).
case "$API" in "file://~/"*) API="file://$HOME/${API#file://\~/}" ;; esac
case "$RAW" in "file://~/"*) RAW="file://$HOME/${RAW#file://\~/}" ;; esac
case "$IMG" in "file://~/"*) IMG="file://$HOME/${IMG#file://\~/}" ;; esac

die() { echo "source-cache: $2" >&2; exit "$1"; }
unreachable() { die 3 "the Trusted Source (5etools mirror) cannot be reached, and $1."; }

# The Source Cache never lives inside a Workspace.
dir=$CACHE
while [ "$dir" != "/" ] && [ -n "$dir" ]; do
  [ -f "$dir/workspace-config.yml" ] && die 2 "refusing a Source Cache inside the Workspace at $dir."
  dir=$(dirname "$dir")
done

fetch() { # url dest: download atomically. Returns 0 done, 4 no such file, 3 unreachable.
  mkdir -p "$(dirname "$2")" || return 3
  code=$(curl -sSL --max-time 60 -w '%{http_code}' "$1" -o "$2.part" 2>/dev/null); rc=$?
  if [ "$rc" -eq 0 ] && { [ "$code" = 200 ] || [ "$code" = 000 ]; }; then
    mv "$2.part" "$2" && return 0
  fi
  rm -f "$2.part"
  { [ "$code" = 404 ] || [ "$rc" -eq 37 ]; } && return 4   # 37: file:// path missing
  return 3
}

# The mirror URL of a cached path at a tag: data/… is in the source mirror; img/<path> is
# <path> in the image mirror, whose names may hold spaces and other characters a URL escapes.
url() { # tag cached-path
  case "$2" in
    img/*) printf '%s/%s/%s' "$IMG" "$1" "$(printf '%s' "${2#img/}" |
             sed 's/%/%25/g; s/ /%20/g; s/#/%23/g; s/?/%3F/g')" ;;
    *) printf '%s/%s/%s' "$RAW" "$1" "$2" ;;
  esac
}

# Print the local copy of a cached path (data/… or img/…), fetching it the first time.
cached() { # cached-path what
  tag=$(pinned_release) || exit $?
  local_file="$CACHE/$tag/$1"
  if [ ! -f "$local_file" ]; then
    fetch "$(url "$tag" "$1")" "$local_file"
    case $? in
      0) ;;
      4) die 4 "$2 is not in the Trusted Source release $tag." ;;
      *) unreachable "$2 is not in the Source Cache" ;;
    esac
  fi
  printf '%s\n' "$local_file"
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
    cached "$path" "$path"
    ;;
  image)
    path=${2:-}
    case "$path" in
      ""|/*|*://*) die 2 "an image is named by its path in the image mirror: '$path'." ;;
      *..*) die 2 "'..' is not allowed in '$path'." ;;
    esac
    cached "img/$path" "the image $path"
    ;;
  refresh)
    old=$(pinned_release) || exit $?
    new=$(latest_release)
    [ -n "$new" ] || unreachable "the Source Cache stays on $old"
    if [ "$new" = "$old" ]; then
      echo "Source Cache up to date: $old is the latest release."
      exit 0
    fi
    count=0 dropped=""
    list="$CACHE/.refresh-list"
    (cd "$CACHE/$old" 2>/dev/null && find data img -type f ! -name '*.part' 2>/dev/null) > "$list"
    while IFS= read -r f; do
      fetch "$(url "$new" "$f")" "$CACHE/$new/$f"
      case $? in
        0) count=$((count+1)) ;;
        4) dropped="$dropped $f" ;;
        *) rm -rf "$CACHE/$new" "$list"; unreachable "the refresh to $new could not fetch $f; the Source Cache stays on $old" ;;
      esac
    done < "$list"
    rm -f "$list"
    printf '%s\n' "$new" > "$CACHE/release"
    rm -rf "$CACHE/$old"
    echo "Source Cache refreshed: $old -> $new ($count file(s) fetched again)."
    [ -z "$dropped" ] || echo "No longer in $new, dropped:$dropped"
    ;;
  *)
    die 2 "usage: source-cache.sh release | file data/<path> | image <path> | refresh"
    ;;
esac
