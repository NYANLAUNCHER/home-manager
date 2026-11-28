{ config, pkgs, lib, username, homeDirectory, inputs, ... }:
{
  home = {inherit username homeDirectory;};

  # Environment Variables:
  home.sessionVariables = {};

  # Config Files:
  # Note: Manage plain text through "filename".text = ''contents''
  home.file = {
    # Directories:
    ".config/git/".source =      ./git;
    ".config/zellij/".source =   ./zellij;
    ".config/ghostty/".source =  ./ghostty;
    ".config/yazi/".source =     ./yazi;
    ".config/mpv/".source =      ./mpv;
    ".config/aerc/".source =     ./aerc;
    ".config/newsboat/".source = ./newsboat;
    ".config/zathura/".source =  ./zathura;
    ".config/moxide/".source =   ./moxide; # markdown-oxide, see: https://oxide.md/Configuration
    ".config/vivify".source =    ./vivify;
    ".config/qutebrowser/".source = ./qutebrowser;
    ".config/nix/" = {
      source = ./nix;
      recursive = true;
      force = true;
    };
    # Files:
    ".config/mimeapps/".source = ./mimeapps.list;
    ".profile".source = ./.profile;
    ".inputrc".source = ./.inputrc;
    ".bashrc".source =  ./.bashrc;
    # Unused:
    #".config/luakit/".source = ./luakit;
    #".config/mutt/".source = ./mutt; # Mutt & Neomutt
    #".config/vieb/".source = ./vieb;
  };

  # Packages:
  home.packages = [
    inputs.vis.packages.${pkgs.system}.default # see: ./vis/flake.nix
  ] ++
  (with pkgs; [
    # Development
    ghostty
    zellij
    yazi
    just
    git lazygit gh
    aerc # email client
    newsboat # rss/atom feed reader
    devenv

    # Utils
    btop
    tree
    file
    xclip
    ripgrep-all
    multitail # like GNU `tail` but for multiple files
    libqalculate # advanced calculator
    jq

    # Graphical
    luakit
    qutebrowser
    mpv yt-dlp
    nsxiv
    f3d
    vivify # live md viewer, see: https://github.com/jannis-baum/Vivify
  ]);
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
  programs.zathura.enable = true;

  xdg.enable = true;
  xdg.systemDirs.data = [
    "${config.home.profileDirectory}/share"
  ];
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    projects    = "$HOME/src";
    download    = "$HOME/tmp";
    documents   = "$HOME/files";
    music       = "$HOME/media/audio/music";
    pictures    = "$HOME/media/imgs";
    videos      = "$HOME/media/vids";
    desktop     = "$HOME/.desktop";
    templates   = "$HOME/.attic/templates";
    publicShare = "$HOME/.attic/public";
  };

  # Home-manager Configs:
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
