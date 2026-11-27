source ~/.profile
shopt -s autocd
shopt -s direxpand
export HISTFILE="$HOME/.local/state/.bash_history"
update_prompt() {
    export _prompt_shell_info=""
    if [[ ${IN_NIX_SHELL+x} ]]; then
        _prompt_shell_info="\[\033[1;33m\](nix-shell)\[\033[0m\]"
    fi
    export PS1="\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]$_prompt_shell_info\$\[\033[0m\] "
}
export PROMPT_COMMAND="update_prompt"
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
alias a="touch"
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
fn_ll() {
  ls -hlA --color=always --group-directories-first "$@"
  echo
}
bind -x '"\C-j": "fn_ll"'
alias ll="fn_ll"

# <A-z>  ->  cd -
bind '"\ez": "\C-e\C-ucd -\C-m"'
alias cdtmp="cd $(mktemp -d)"

## Rust
alias cargo-docs="cargo doc --no-deps --open"

## Nix & Home-Manager
alias nsh="fn_nsh"
fn_nsh() { # `nix shell` wrapper
    local pkgs=()
    local passthrough=false
    for i in "$@"; do
        if [[ "$i" == "--" ]]; then # all args after "--" will be ran with --command
            passthrough=true
            pkgs+=("--command")
        elif [[ "$passthrough" == true ]]; then
            pkgs+=("$i")
        else
            pkgs+=("nixpkgs#$i")
        fi
    done
    echo "nix shell --impure ${pkgs[*]}"
    nix shell --impure "${pkgs[@]}"
}
alias nr="fn_nr"
fn_nr() { # `nix run` wrapper
    echo "nix run --impure nixpkgs#$1 -- ${*:2}"
    nix run --impure "nixpkgs#$1" -- "${@:2}"
}
alias nixpkgs-desc="fn_nixpkgs_desc"
fn_nixpkgs_desc() {
    echo "nix eval \"nixpkgs#${1}.meta\" --json | jq '.description'"
    nix eval "nixpkgs#${1}.meta" --json | jq '.description'
}

alias hm="home-manager"
alias hms="fn_hms"
fn_hms() {
    # "$hm" variable is defined in ~/config/home-manager/.profile
    local hm_dir="${hm:-$HOME/.config/home-manager}"
    local flake="" # specify the flake configuration to use
    # home-manager switch to the current $USER configuration
    [[ -n "$USER" ]] && flake="--flake $hm_dir#$USER" || true
    # run `USER="" hms` to disable the automatic flake args
    # or run `USER="<username>" hms` to use a different user configuration
    echo "home-manager switch $flake $@"
    home-manager switch $flake $@
    [[ -f ~/.bashrc ]] && source ~/.bashrc || echo "Couldn't find ~/.bashrc"
}

fn_yazi() {
  YAZI_START_DIR="$(pwd)"
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
alias y="fn_yazi"
bind '"\C-o": "\C-e\C-uy\C-m"' # open yazi with <C-o> keybind

fn_opencode() {
    # run `OLLAMA_MODEL="<model_name>" opencode` to override the default model
    local model="${OLLAMA_MODEL:-$OLLAMA_DEFAULT_AGENT_MODEL}"
    if [[ -n "$model" ]]; then
        echo "ollama launch --model=$model opencode -- $*"
        ollama launch --model="$model" opencode -- "$@"
    else
        ollama launch opencode -- "$@"
    fi
}
alias opencode="fn_opencode"

alias miniprompt="PS1='> '" # Miniture prompt for popup terminals
alias grep="grep --color=always"
alias rga="rga --line-number"
alias diff="diff --color=always"
fn_nvim_info () { # open info & man pages in neovim
    nvim -R -M -c "Info $1 $2" +only
}
alias info="fn_nvim_info"
