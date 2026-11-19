{ config, pkgs, lib, username, homeDirectory, ... }:
{
  home = {inherit username homeDirectory;};

  # Environment Variables:
  home.sessionVariables = {};

  # Config Files:
  # Note: Manage plain text through "filename".text = ''contents''
  home.file = {
    ".profile".source = lib.mkForce ./.profile;
    ".inputrc".source = lib.mkForce ./.inputrc;
    ".bashrc".source = lib.mkForce  ./.bashrc;
    ".config/mimeapps.list".source = lib.mkForce ./mimeapps.list;
    ".config/nix/".source = lib.mkForce ./nix;
    ".config/git/".source = lib.mkForce ./git;
    ".config/zellij/".source =   ./zellij;
    ".config/ghostty/".source =  ./ghostty;
    ".config/yazi/".source =     ./yazi;
    ".config/mpv/".source =      ./mpv;
    ".config/aerc/".source =     ./aerc;
    ".config/mutt/".source =     ./mutt; # Mutt & Neomutt
    ".config/newsboat/".source = ./newsboat;
    ".config/zathura/".source =  ./zathura;
    ".config/qutebrowser/".source =  ./qutebrowser;
    ".config/moxide/".source =  ./moxide; # markdown-oxide, see: https://oxide.md/Configuration
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
    qutebrowser
    mpv yt-dlp
    nsxiv
    f3d
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
