source .profile
shopt -s autocd
shopt -s direxpand
# prompt
PS1HOST="\u@\h"
export PS1="\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "

# Aliases
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
