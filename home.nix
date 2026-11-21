{ config, pkgs, lib, username, homeDirectory, ... }:
{
  home = {inherit username homeDirectory;};

  # Environment Variables:
  home.sessionVariables = {};

  # Config Files:
  # Note: Manage plain text through "filename".text = ''contents''
  home.file = {
    ".profile".source = ./.profile;
    ".inputrc".source = ./.inputrc;
    ".bashrc".source = ./.bashrc;
    ".config/mimeapps.list".source = ./mimeapps.list;
    ".config/nix/".source = ./nix;
    ".config/git/".source = ./git;
    ".config/zellij/".source =   ./zellij;
    ".config/ghostty/".source =  ./ghostty;
    ".config/yazi/".source =     ./yazi;
    ".config/mpv/".source =      ./mpv;
    ".config/aerc/".source =     ./aerc;
    ".config/mutt/".source =     ./mutt; # Mutt & Neomutt
    ".config/newsboat/".source = ./newsboat;
    ".config/zathura/".source =  ./zathura;
    ".config/moxide/".source =   ./moxide; # markdown-oxide, see: https://oxide.md/Configuration
    #".config/luakit/".source =   ./luakit;
    #".config/qutebrowser/".source = ./qutebrowser;
  };

  # Packages:
  home.packages = (with pkgs; [
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
    libqalculate # advanced calculator
    discordo # tui discord client

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

  # Home-manager Configs
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

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
