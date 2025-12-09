export HM_SESSION_VARS_SH="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
[ -f "$HM_SESSION_VARS_SH" ] && . "$HM_SESSION_VARS_SH"
# Secrets:
[ -f "$HOME/.secrets/expose.sh" ] && \
. "$HOME/.secrets/expose.sh" &>/dev/null || true

# Environment Variables:
stty -ixon
# Default prompt
export PS1="[$USER@$HOSTNAME]$ "
export HISTFILE="$HOME/.local/state/.sh_history"
# XDG Base dirs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
# source XDG User dirs
[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ] && . "$XDG_CONFIG_HOME/user-dirs.dirs"
# add paths in the user home dir
export PATH="$HOME/.local/bin:$PATH"
# Set default programs
export EDITOR="hx"
export OPENER="xdg-open"
export PAGER="less"
# Set config dirs
export INPUTRC="$HOME/.inputrc"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Directory Shortcuts:
set -a
cfg="$XDG_CONFIG_HOME"
dl="$XDG_DOWNLOAD_DIR"
hm="$XDG_CONFIG_HOME/home-manager"
# media
imgs="$HOME/media/imgs"
vids="$HOME/media/vids"
audio="$HOME/media/audio"
# source code
src="$HOME/src"
# documents
files="$XDG_DOCUMENTS_DIR"
# notes
nt="$HOME/notes"
todo="$nt/TODO.md"
set +a
