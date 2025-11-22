inputs@{ config, pkgs, lib, ... }:
{
  home.username = "markiep";
  home.homeDirectory = "/home/markiep";

  home.sessionVariables = {};
  # Note: manage plain files through "filename".text = ''contents''
  home.file = { # <dest> = <source>
    ".profile".source = lib.mkForce ./.profile;
    ".bashrc".source = lib.mkForce ./.profile;
    ".inputrc".source = lib.mkForce ./.inputrc;
    # Configs
    ".config/nix/".source =     ./nix;
    ".config/git/".source =     ./git;
    ".config/nvim/".source =    ./nvim;
    ".config/yazi/".source =    ./yazi;
    ".config/vieb/".source =    ./vieb;
    ".config/ghostty/".source = ./ghostty;
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
    neovim
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
    zathura
    f3d
  ]);

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

  programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
