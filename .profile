# Posix compliant? ~/.profile
# Home-Manager
export HM_SESSION_VARS="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
[ -f "$HM_SESSION_VARS" ] && . "$HM_SESSION_VARS"
# Environment Variables {{{
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
EDITOR="nvim"
OPENER="xdg-open"
PAGER="less"
# Set config dirs
INPUTRC="$HOME/.inputrc"
LESSHISTFILE="$XDG_CACHE_HOME/less/history"
set +a
#}}}
# Directory Shortcuts {{{
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
# Bash Config
if [ -n "$BASH_VERSION" ]; then
  # Initialization {{{
  shopt -s autocd
  shopt -s direxpand
  # prompt
  PS1HOST="\u@\h"
  [ ! -s "$IN_NIX_SHELL" ] && PS1HOST="nix-shell"
  export PS1="\n\[\033[1;32m\][\[\e]0;$PS1HOST: \w\a\]\u@\h:\w]\$\[\033[0m\] "
  #}}}
  # Aliases {{{
  alias o="$OPENER"
  fn_edit() {
    case $EDITOR in
      "nvim")
        # search for Session.vim if no args are given
        if [ -f "Session.vim" ] && [ -z "$@" ]; then
          $EDITOR -S "Session.vim"; return 0
        fi
      ;;
    esac
    $EDITOR "$@"
  }
  alias e="fn_edit"
  alias sudoe="sudo $EDITOR"
  fn_edit_flake() { # search upwards for flake.nix
    [[ -f "flake.nix" ]] && $EDITOR "$@" -- "flake.nix" && return 0
    local dir="$PWD"
    while [[ ! -d "$(realpath -s $dir/.git)" ]] && [[ "$(realpath -s $dir)" != "/" ]]; do
      dir="$dir/.." # continue upwards
      if [[ -f "$dir/flake.nix" ]]; then
        [[ ! -z "$@" ]] && echo "$EDITOR "$(realpath -s $dir)/flake.nix" -- "$@""
        $EDITOR "$@" -- "$dir/flake.nix"
        return 0 # exit function
      fi
    done
    echo "Abandoned search for flake.nix @ $(realpath -s $dir)"
    return 1
  }
  alias ef="fn_edit_flake"
  alias todo="$EDITOR $todo"
  alias ll="ls -hlA --color=always --group-directories-first"
  alias cdtmp="cd $(mktemp -d)"
  ## home-manager
  alias hm="home-manager"
  alias hms="home-manager switch"
  ##
  alias nsh="nix-shell -p"
  alias submake="make -f submake.mk"
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
  # Miniture prompt for popup terminals
  alias microprompt="PS1='> '"
  alias grep="grep --color=always"
  alias diff="diff --color=always"
  alias info="info --vi-keys"
  # }}}
fi
# Integrations {{{
# export secrets
[ -f "$HOME/.secrets/expose.sh" ] && \
. "$HOME/.secrets/expose.sh" &>/dev/null || true

# source all files in path .config/<dir>/init.sh
find "$XDG_CONFIG_HOME" -mindepth 2 -maxdepth 2 -type f -name 'init.sh' | while read -r script; do
  . "$script"
done
