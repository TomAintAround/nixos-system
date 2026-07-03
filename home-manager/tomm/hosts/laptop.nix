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
      defaultSopsFile = ../modules/secrets/laptop.yaml;
    })
    # ../modules/contentCreation.nix
    # ../modules/gamedev.nix
    # ../modules/gaming.nix
  ];

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      vrr = false;
      x = 0;
      y = 0;
      scale = 1.25;
      enable = true;
      default = true;
    }
    {
      name = "Unknown-1";
      enable = false;
    }
  ];

  bluetooth.enable = true;
  brightness.enable = true;
  openrazer.enable = false;
  openrgb.enable = false;
}
