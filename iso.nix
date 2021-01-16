# https://nixos.wiki/wiki/Creating_a_NixOS_live_CD

{config, pkgs, ...}:
let
  # home-manager = builtins.fetchTarball {
  #   url = "https://github.com/nix-community/home-manager/archive/63f299b3347aea183fc5088e4d6c4a193b334a41.tar.gz";
  #   sha256 = "0iksjch94wfvyq0cgwv5wq52j0dc9cavm68wka3pahhdvjlxd3js";
  # };

  wallpaperImage = pkgs.fetchurl {
    urls = [
      "https://pics.niedzwiedzinski.cyou/oboz2020/photos/_MG_1480.jpg"
      "https://web.archive.org/web/20210116180606if_/https://pics.niedzwiedzinski.cyou/oboz2020/photos/_MG_1480.jpg"
    ];
    sha256 = "1jdrgf8jd2aai5ny1r0d6zw02mk3xkdh92j1ywxbd3ysbf0c35qf";
  };

  setWallpaper = pkgs.writeScriptBin "setwall" ''
    #!${pkgs.stdenv.shell}
    gsettings set org.gnome.desktop.background picture-uri ${wallpaperImage}
  '';

  # setWallpaperDesktop = pkgs.makeDesktopItem {
  #   type="Application";
  #   name="setwall";
  #   terminal="false";
  #   exec="${setWallpaper}";
  #   extraEntries="X-GNOME-Autostart-enabled=true";
  # };

  setWallpaperDesktop = pkgs.writeTextFile rec {
    name = "setwall";
    destination = "/etc/xdg/autostart/${name}.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Create GNOME Initial Setup stamp files
      Exec=${setWallpaper}/bin/setwall
      Terminal=false
      X-GNOME-Autostart-enabled=true
    '';
  };



  wallpaper = pkgs.stdenv.mkDerivation {
    name = "wallpaper";
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/etc/dconf/db/local.d
      mkdir -p $out/share/19pdh

      cat > $out/etc/dconf/db/local.d/00-backgroun <<EOF
      # Specify the dconf path
      [org/gnome/desktop/background]

      # Specify the path to the desktop background image file
      picture-uri='file://$out/share/19pdh/wallpaper.jpg'

      # Specify one of the rendering options for the background image:
      picture-options='scaled'

      # Specify the left or top color when drawing gradients, or the solid color
      primary-color='000000'

      # Specify the right or bottom color when drawing gradients
      secondary-color='FFFFFF'
      EOF

      cp ${wallpaperImage} $out/share/19pdh/wallpaper.jpg
    '';
  };
in

  {
    imports = [
      <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  environment.systemPackages = [
    setWallpaperDesktop
  ];

  programs.dconf = {
    enable = true;
    packages = [
      wallpaper
    ];
  };

  boot.loader.grub.splashImage = ./bg.png;

  isoImage.grubTheme = null;
  isoImage.splashImage = ./bg.png;
  isoImage.efiSplashImage = ./bg.png;

  boot.plymouth = {
    enable = true;
    logo = ./logo.png;
  };

}
