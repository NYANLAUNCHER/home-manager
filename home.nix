inputs@{ config, pkgs, ... }:
{
  home.username = "markiep";
  home.homeDirectory = "/home/markiep";

  # Note: manage plain files through "filename".text = ''contents''
  home.file = { # <dest> = <source>
    ".profile".source = lib.mkForce ./.profile;
    ".env".source = ./.env;
    ".config/git/".source = ./git;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = (with pkgs; [
    (pkgs.writeShellScriptBin "my-hello" ''
      echo "Hello, ${config.home.username}!"
    '')
    # Dev
    neovim
    yazi
    git
    gh
    lazygit
    direnv
    # Utils
    ytfzf
    neomutt
    libqalculate
    # Graphical
    ghostty
    brave
    #vieb
    mpv
    nsxiv
    zathura
    f3d
  ]);

  # XDG Stuffs {{{
  xdg.userDirs = {
    enable = true;
    desktop = "$HOME/.desktop";
    download = "$HOME/tmp";
    documents = "$HOME/files";
    music = "$HOME/media/audio/music";
    pictures = "$HOME/media/imgs";
    videos = "$HOME/media/vids";
    templates = "$HOME/.attic/templates";
    publicShare = "$HOME/.attic/public";
  };
  #}}}
  # Readline (.inputrc) {{{
  programs.readline = {
    enable = true;
    extraConfig = ''
      set show-all-if-ambiguous on
      set completion-ignore-case on
      set menu-complete-display-prefix on

      "\C-i": menu-complete
      "\e[Z": menu-complete-backward

      "\C-o": '"\C-k"\C-uy\C-m'
      "\C-j": '"\C-k"\C-ull\C-m'
      "\ez": 'cd -\015'

      "\C-l": clear-screen
      "\C-p": history-search-backward
      "\C-n": history-search-forward
      "\C-b": backward-word
    '';
  };
  #}}}
  # Bash {{{
  programs.bash = {
    enable = true;

    shellOptions = [
      "autocd"
      "direxpand"
    ];

    initExtra = ''
      # Default Prompt
      export PS1="\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "

      # Fancy prompt (ignore errors)
      if [ -f "$XDG_CONFIG_HOME/bash/prompt.sh" ]; then
        source "$XDG_CONFIG_HOME/bash/prompt.sh" &> /dev/null
      fi
    '';
  };
  #}}}
  # GnuPG {{{
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
  #}}}

  home.sessionVariables = {};

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
