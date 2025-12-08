export HM_SESSION_VARS="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
[ -f "$HM_SESSION_VARS" ] && . "$HM_SESSION_VARS"
# Environment Variables: {{{
stty -ixon
set -a
HISTFILE="$HOME/.local/state/.sh_history"
# Default prompt
PS1="[$USER@$HOSTNAME]$ "
# XDG Base dirs
XDG_CONFIG_HOME="$HOME/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
# source XDG User dirs
[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ] && . "$XDG_CONFIG_HOME/user-dirs.dirs"
# paths in the user home dir
PATH="$HOME/.local/bin:$XDG_CONFIG_HOME/shell/cmds:$PATH"
# Set default programs
EDITOR="hx"
OPENER="xdg-open"
PAGER="less"
# Set config dirs
INPUTRC="$HOME/.inputrc"
LESSHISTFILE="$XDG_CACHE_HOME/less/history"
set +a
#}}}
# Directory Shortcuts: {{{
set -a # let programs like nvim access shortcuts
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
set +a # don't forget to disable auto-export
# }}}
# Integrations:
# export secrets
[ -f "$HOME/.secrets/expose.sh" ] && \
. "$HOME/.secrets/expose.sh" &>/dev/null || true
