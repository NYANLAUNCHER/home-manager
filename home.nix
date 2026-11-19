{ config, pkgs, lib, username, homeDirectory, ... }:
{
  home = {inherit username homeDirectory;};

  # Environment Variables:
  home.sessionVariables = {};

  # Config Files:
  # Note: Manage plain files through "filename".text = ''contents''
  home.file = {
    # Note: Using sym links instead of the commented lines for quick iteration
    ".profile".source = lib.mkForce ./.profile;
    ".inputrc".source = lib.mkForce ./.inputrc;
    ".bashrc".source = lib.mkForce ./.bashrc;
    ".config/nix/".source = lib.mkForce ./nix;
    #".config/nvim/".source =   ./nvim;
    ".config/git/".source =     ./git;
    ".config/zellij/".source =  ./zellij;
    ".config/ghostty/".source = ./ghostty;
    #".config/aerc/".source =   ./aerc/;
    #".config/newsboat/".source = ./newsboat/;
    ".config/mpv/".source =     ./mpv;
    ".config/zathura/".source = ./zathura;
    #".config/mimeapps.list".source = lib.mkForce ./mimeapps.list;

    # Archive
    #".zshenv".source = lib.mkForce ./.zshenv;
    #".zshrc".source = lib.mkForce ./.zshrc;
    #".config/zsh".source = lib.mkForce ./zsh;
    #".config/qutebrowser/".source = ./qutebrowser/;
    #".config/mutt/".source = ./mutt; # Mutt & Neomutt
  };

  # nvim/, yazi/ and vieb/ (modules are imported in flake.nix, options in */module.nix)
  nyan.nvim = {
    enable = true; # neovim, gcc, xxd, LSPs, ...
    # ~/.config/nvim is a manual symlink to ./nvim for quick iteration. To have
    # home-manager manage that link instead, delete it and replace this line with:
    #   configPath = "${homeDirectory}/.local/home-manager/nvim";
    linkConfig = false;
  };
  nyan.yazi.enable = true; # also links ~/.config/yazi
  nyan.vieb.enable = true; # also links ~/.config/vieb

  # Packages:
  nixpkgs.config.allowUnfree = true;
  home.packages = (with pkgs; [
    # Development
    tree-sitter
    ghostty
    zellij
    just
    git lazygit gh
    newsboat # rss/atom feed reader
    aerc # email client
    direnv
    devenv

    # Utils
    btop
    tree
    file
    xclip
    libqalculate
    checkbashisms

    # Graphical
    #brave
    #vieb
    #qutebrowser
    discord discordo
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
