export ZSH_CUSTOM="$XDG_CONFIG_HOME/zsh"
export ZSH="$ZSH_CUSTOM/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
  git
  zsh-helix-mode
  globalias
)
source $ZSH/oh-my-zsh.sh

typeset -U path cdpath fpath manpath
for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

HELPDIR="/nix/store/bk68yr5826s9gxvljz03ch4jlz863x05-zsh-5.9/share/zsh/$ZSH_VERSION/help"

autoload -U compinit && compinit
# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="5000"
SAVEHIST="5000"

HISTFILE="/home/markiep/.local/state/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK

# Enabled history options
enabled_opts=(
  HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
)
for opt in "${enabled_opts[@]}"; do
  setopt "$opt"
done
unset opt enabled_opts

# Disabled history options
disabled_opts=(
  APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
  HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
)
for opt in "${disabled_opts[@]}"; do
  unsetopt "$opt"
done
unset opt disabled_opts

# Keybinds
ll_widget() {
  BUFFER="ll" # ls alias, defined below
  zle accept-line
}
y_widget() {
  BUFFER="y" # yazi alias, defined below
  zle accept-line
}
zle -N ll_widget
bindkey '^J' ll_widget
zle -N y_widget
bindkey "^M" accept-line
bindkey '^O' y_widget
bindkey '^B' backward-word
bindkey '^F' forward-word

# Aliases
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
alias ll="ls -hlA --color=always --group-directories-first"
alias cdtmp="cd $(mktemp -d)"
alias hm="home-manager"
alias hms="home-manager switch"
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
alias z="zellij"
alias h="head"
alias t="tail"
# Miniture prompt for popup terminals
alias microprompt="PS1='> '"
alias grep="grep --color=always"
alias diff="diff --color=always"
alias info="info --vi-keys"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
