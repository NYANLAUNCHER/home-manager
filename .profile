# home-manager session variables
export HM_SESSION_VARS_SH="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
unset __HM_SESS_VARS_SOURCED
[ -f "$HM_SESSION_VARS_SH" ] && . "$HM_SESSION_VARS_SH"

# Secrets:
[ -f "$HOME/.secrets/expose.sh" ] && \
    . "$HOME/.secrets/expose.sh" &>/dev/null || true

# Environment Variables:
stty -ixon
# Default prompt
export PS1="[$USER@$HOSTNAME]$ "
export HISTFILE="$HOME/.local/state/.sh_history"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
# source XDG User dirs
[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ] && . "$XDG_CONFIG_HOME/user-dirs.dirs" \
  || echo "Couldn't source $XDG_CONFIG_HOME/user-dirs.dirs"
# add paths in the user home dir
export PATH="$HOME/.local/bin:$PATH"

# Default Programs
export EDITOR="vi" # fallback to vi if preferred editor doesnt exist
if command -v vis >/dev/null 2>&1; then
    export EDITOR="vis" # use preferred editor if exists
fi
export OPENER="xdg-open"
export PAGER="less"
export INPUTRC="$HOME/.inputrc"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Integrations
# NOTE: left these here for systems not using home-manager
# lua
export LUA_PATH="$LUA_PATH;./?.lua;./?/init.lua"
export LUAROCKS_CONFIG="$XDG_CONFIG_HOME/luarocks/config.lua"
mkdir -p $(dirname $LUAROCKS_CONFIG) && touch $LUAROCKS_CONFIG
# rust
export CARGO_HOME="$XDG_CONFIG_HOME/cargo"
PATH="$PATH:$CARGO_HOME/bin"
# ollama
export OLLAMA_DEFAULT_AGENT_MODEL="gemma4:12b" # see: 'alias opencode' in .bashrc

# Directory Shortcuts:
# config
export cfg="$XDG_CONFIG_HOME"
export hm="$XDG_CONFIG_HOME/home-manager"
# downloads
export dl="$XDG_DOWNLOAD_DIR" # ~/tmp
# media
export media="$HOME/media"
export imgs="$media/imgs" #
export vids="$media/vids"
export audio="$media/audio"
export music="$XDG_MUSIC_DIR" # ~/media/audio/music
# source code
export src="${XDG_PROJECTS_DIR:-$HOME/src}"
# documents
export files="$XDG_DOCUMENTS_DIR"
# notes
export nt="$HOME/notes" # links to $XDG_DOCUMENTS_DIR_DIR/.notes
export todo="$nt/TODO.md"
