{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./.
    ./hardware/graphics.nix
    ./hardware/sound.nix
    # ./sddm
    ./gdm.nix
  ];

  environment.systemPackages = with pkgs; [home-manager];

  programs = {
    gamemode.enable = true;
    gamescope.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  services = {
    flatpak.enable = true;
    xserver = {
      enable = true;
      xkb.layout = "pt";
    };
  };

  xdg.portal = {
    enable = lib.mkIf config.services.flatpak.enable (lib.mkForce true);
    extraPortals = lib.mkIf config.services.flatpak.enable (lib.mkForce [pkgs.xdg-desktop-portal-gtk]);
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      source-han-sans
      source-han-serif
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font"];
        serif = ["Noto Serif" "Source Han Serif"];
        sansSerif = ["Noto Sans" "Source Han Sans"];
        emoji = ["Noto Color Emoji"];
      };
    };
    fontDir.enable = true;
  };

  security.polkit.enable = true;

  networking = {
    useDHCP = lib.mkDefault true;
    firewall = let
      kdeConnectPorts = {
        from = 1714;
        to = 1764;
      };
      cs2Port = 27015;
    in {
      allowedTCPPorts = [cs2Port];
      allowedUDPPorts = [cs2Port];
      allowedTCPPortRanges = [kdeConnectPorts];
      allowedUDPPortRanges = [kdeConnectPorts];
    };
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };
}
