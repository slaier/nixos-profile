{ pkgs, ... }: {
  imports = [
    ./firefox
    ./fcitx.nix
    ./vscode.nix
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
    };
    theme = {
      package = pkgs.orchis-theme;
      name = "Orchis-Light";
    };
  };
}
