stty -ixon
# Environment Variables {{{
set -a # automatically export variables
# Default prompt
PS1="[$USER@$HOSTNAME]$ "
# XDG Base dirs
XDG_CONFIG_HOME="$DF_WORK_TREE/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
# source XDG User dirs
if [ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ]; then
  . "$XDG_CONFIG_HOME/user-dirs.dirs"
else
  XDG_DESKTOP_DIR="$HOME/.desktop"
  XDG_DOWNLOAD_DIR="$HOME/tmp/"
  XDG_DOCUMENTS_DIR="$HOME/files/"
  XDG_MUSIC_DIR="$HOME/media/audio/music"
  XDG_PICTURES_DIR="$HOME/media/imgs"
  XDG_VIDEOS_DIR="$HOME/media/vids"
  XDG_TEMPLATES_DIR="$HOME/.attic/public"
  XDG_PUBLICSHARE_DIR="$HOME/.attic/templates"
fi
# expose local user executables
PATH="$HOME/.local/bin:$PATH"
# Set default programs
EDITOR="nvim";alias e="$EDITOR"
OPENER="xdg-open";alias o="$OPENER"
PAGER="less"
# Set config dirs
INPUTRC="$XDG_CONFIG_HOME/inputrc"
LESSHISTFILE="$XDG_CACHE_HOME/less/history"
set +a # disable auto-export of variables
#}}}
# Directory Shortcuts {{{
set -a
cfg="$XDG_CONFIG_HOME"
dl="$XDG_DOWNLOAD_DIR"
hm="$cfg/home-manager"
alias hm="home-manager"
# media
imgs="$HOME/media/imgs"
vids="$HOME/media/vids"
audio="$HOME/media/audio"
# source code
src="$HOME/src"
# documents
files="$XDG_DOCUMENTS_DIR"
# notes
nt="$files/.notes"
alias todo="$EDITOR $nt/TODO.md"
set +a # don't forget to disable auto-export
# }}}
# Aliases {{{
alias sudoe="sudo $EDITOR"
alias ef="$EDITOR flake.nix"
alias cdtmp="cd $(mktemp -d)"
alias submake="make -f submake.mk"
alias ll="ls -hlA --color=always --group-directories-first"
alias nsh="nix-shell -p"
fn_yazi() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
alias y="fn_yazi"
alias z="zathura"
# Miniturize prompt for popup terminals
alias microprompt="PS1='> '"
alias grep="grep --color=always"
alias diff="diff --color=always"
alias info="info --vi-keys"
# }}}
# Integrations {{{
# source ~/.env
[ -f .env ] && . .env
# source all files in path .config/<dir>/init.sh
find "$XDG_CONFIG_HOME" -mindepth 2 -maxdepth 2 -type f -name 'init.sh' | while read -r script; do
    . "$script"
done
#}}}
