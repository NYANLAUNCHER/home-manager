#!/bin/sh
# Wrapper around vieb. Loads the settings in .env, then adds:
#   --session=<name|path>  Use a separate datafolder. A bare <name> lives in
#                          $VIEB_SESSIONS_DIR; anything starting with "/", "./"
#                          or "../" is used as a path.
#   -t | --temp            Use a temporary datafolder, deleted when vieb exits.
# All other arguments are passed to vieb unchanged (so an explicit
# --datafolder=... still wins).
#
# The nix package installs this as `vieb`, with VIEB_BIN pointing at the real binary.

[ -n "$VIEB_CONFIG_DIR" ] || VIEB_CONFIG_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
export VIEB_CONFIG_DIR
# shellcheck source=.env
[ -f "$VIEB_CONFIG_DIR/.env" ] && . "$VIEB_CONFIG_DIR/.env"
vieb_bin="${VIEB_BIN:-vieb}"

session=""
temp=""
# Rebuild "$@" without our own flags.
n=$#
while [ "$n" -gt 0 ]; do
  arg=$1
  shift
  n=$((n - 1))
  case $arg in
    --session=*) session=${arg#--session=} ;;
    --session)
      if [ "$n" -eq 0 ]; then
        echo "vieb: --session needs a value" >&2
        exit 1
      fi
      session=$1
      shift
      n=$((n - 1))
      ;;
    -t | --temp) temp=1 ;;
    *) set -- "$@" "$arg" ;;
  esac
done

if [ -n "$temp" ]; then
  VIEB_DATAFOLDER=$(mktemp -d "${TMPDIR:-/tmp}/vieb-session.XXXXXX") || exit 1
  export VIEB_DATAFOLDER
  "$vieb_bin" "$@"
  status=$?
  rm -rf "$VIEB_DATAFOLDER"
  exit "$status"
fi

if [ -n "$session" ]; then
  case $session in
    /* | ./* | ../*) VIEB_DATAFOLDER=$session ;;
    *) VIEB_DATAFOLDER="$VIEB_SESSIONS_DIR/$session" ;;
  esac
  export VIEB_DATAFOLDER
fi

exec "$vieb_bin" "$@"
