inputs@{ config, pkgs, lib, ... }:
{
  home.username = "markiep";
  home.homeDirectory = "/home/markiep";

  imports = [
    ./nvim/home.nix
  ];

  home.sessionVariables = {};
  # Note: manage plain files through "filename".text = ''contents''
  home.file = { # <dest> = <source>
    ".profile".source = lib.mkForce ./.profile;
    ".bashrc".source = lib.mkForce ./.bashrc;
    ".inputrc".source = lib.mkForce ./.inputrc;
    # Configs
    ".config/nix/".source =     ./nix;
    #".config/nvim/".source =    ./nvim;
    #".config/helix/".source =   ./helix;
    #".config/yazi/".source =    ./yazi;
    #".config/zellij/".source =    ./zellij;
    ".config/ghostty/".source = ./ghostty;
    ".config/git/".source =     ./git;
    ".config/vieb/".source =    ./vieb;
    ".config/mpv/".source =     ./mpv;
    ".config/mutt/".source =    ./mutt;
    ".config/zathura/".source = ./zathura;
    ".config/btop/".source =    ./btop;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = (with pkgs; [
    # Dev
    ghostty
    helix
    yazi
    git
    lazygit
    gh
    file
    direnv
    checkbashisms
    # Utils
    btop
    neomutt
    ytfzf
    libqalculate
    # Graphical
    brave
    #vieb
    mpv
    nsxiv
    f3d
  ]);
  programs.zsh.enable = true;
  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
  programs.zathura.enable = true;

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
