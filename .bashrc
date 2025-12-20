source ~/.profile
shopt -s autocd
shopt -s direxpand
export PS1="\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "
export HISTFILE="$HOME/.local/state/.bash_history"
# Aliases:
alias o="$OPENER"
fn_edit() {
if [ -z "$@" ]; then # insert default arguments
  if [ "$EDITOR" = "nvim" ] && [ -f "Session.vim" ]; then
    $EDITOR -S "Session.vim"
  else
    $EDITOR ./
  fi
else
  $EDITOR "$@"
fi
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
fn_ll() { # GNU readline integration for ll
  local saved_line=$READLINE_LINE
  local saved_point=$READLINE_POINT
  ls -hlA --color=always --group-directories-first "$@"
  echo
  READLINE_LINE=$saved_line
  READLINE_POINT=$saved_point
}
bind -x '"\C-j": "fn_ll"'
alias ll="fn_ll"
alias cdtmp="cd $(mktemp -d)"
## Nix & Home-Manager
alias nsh="nix-shell -p"
alias hm="home-manager"
fn_hms() {
  home-manager switch "$@"
  source "$BASH_SOURCE"
}
alias hms="fn_hms"
##
fn_yazi() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
fn_yazi_readline() { # GNU readline integration for yazi
  local saved_line=$READLINE_LINE
  local saved_point=$READLINE_POINT
  fn_yazi
  READLINE_LINE=$saved_line
  READLINE_POINT=$saved_point
}
bind -x '"\C-o": "fn_yazi_readline"'
alias y="fn_yazi"
alias z="zellij"
# Miniture prompt for popup terminals
alias microprompt="PS1='> '"
alias grep="grep --color=always"
alias diff="diff --color=always"
fn_nvim_info () { # open info & man pages in neovim
    nvim -R -M -c "Info $1 $2" +only
}
alias info="fn_nvim_info"
