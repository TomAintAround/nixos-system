{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ../modules
    (import ../modules/secrets/default.nix {
      inherit pkgs config inputs;
      defaultSopsFile = ../modules/secrets/desktop.yaml;
    })
    # ../modules/contentCreation.nix
    # ../modules/gamedev.nix
    ../modules/gaming.nix
  ];

  monitors = [
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      refreshRate = 74;
      vrr = false;
      x = 0;
      y = 0;
      scale = 1.0;
      enable = false;
      default = false;
    }
    {
      name = "DVI-D-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      vrr = false;
      x = 1920;
      y = 0;
      scale = 1.0;
      enable = true;
      default = true;
    }
    {
      name = "Unknown-1";
      enable = false;
    }
  ];

  bluetooth.enable = false;
  brightness.enable = false;
  openrazer.enable = true;
  openrgb.enable = true;
}
