{ config, pkgs, lib, username, homeDirectory, ... }:
{
  home = {inherit username homeDirectory;};

  # Environment Variables:
  home.sessionVariables = {};

  # Config Files:
  # Note: manage plain files through "filename".text = ''contents''
  home.file = { # <dest> = <source>
    ".profile".source = lib.mkForce ./.profile;
    ".inputrc".source = lib.mkForce ./.inputrc;
    ".bashrc".source = lib.mkForce ./.bashrc;
    ".zshenv".source = lib.mkForce ./.zshenv;
    ".zshrc".source = lib.mkForce ./.zshrc;
    #".config/zsh".source = lib.mkForce ./zsh;
    #".config/nvim/".source =   ./nvim;
    ".config/yazi/".source =   ./yazi;
    ".config/zellij/".source = ./zellij;
    ".config/nix/".source =     ./nix;
    ".config/ghostty/".source = ./ghostty;
    ".config/git/".source =     ./git;
    ".config/mpv/".source =     ./mpv;
    ".config/zathura/".source = ./zathura;
    ".config/vieb/".source =    ./vieb;
  };

  # Packages:
  home.packages = (with pkgs; [
    # Dev
    xclip
    ghostty
    qutebrowser
    zellij
    yazi
    git
    lazygit
    gh
    file
    direnv
    checkbashisms
    # Utils
    btop
    tree
    libqalculate
    # Graphical
    brave
    #vieb
    mpv
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
