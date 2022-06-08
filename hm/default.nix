{ lib, ... }: {
  imports = [
    ./fcitx
    ./firefox
    ./git
    ./i3
    ./neovim
  ];

  options.slaier.isDesktop = lib.mkEnableOption "desktop";
}

