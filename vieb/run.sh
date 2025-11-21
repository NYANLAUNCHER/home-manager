#!/bin/sh
# Wrapper around vieb adds:
# --session="<path>" sets --datafolder=<dir>
# If <path> doesn't start with "./" or "/" it is a path in $VIEB_SESSIONS_DIR
# "-t"|"--temp" creates a temporary session 

# if passed a directory it'll create a session folder inside it
# if passed a file it'll try to open it

. "$XDG_CONFIG_HOME/vieb/init.sh" # must be sourced
args="$*" # gets parsed into vieb compatible args
session_dir="$VIEB_DATAFOLDER" # the default session directory

# if --session exists
session="$(echo "$args" | grep -oP '(?<=--session(=|\s))[^\s]+' | tail -n 1)" # grep the last instance of --session
args="$(echo "$args" | sed 's/--session(=|\s)[^\s]+/hello/g')"
echo "$session"

# if "-t"|"--temp" exists
#(echo "$args" | sed -E '/\b(-t|--temp)\b/!q1; s/\b(-t|--temp)\b/ /g') && temp_session="$(mktemp -d)"
args="$args --datafolder=\"${temp_session:-$session_dir}\""


# vieb uses the original vieb cmd since it is in a sh script
echo "vieb $args"
eval "vieb $args"
[ -d "$temp_session" ] && rm -rf "$temp_session" # remove the temporary session once vieb is closed
