{pkgs, ...}: {
  home.packages = with pkgs; [
    hedgemodmanager
    (heroic.override {
      extraPkgs = pkgs: [
        gamemode
        gamescope
        egl-wayland
      ];
    })
    prismlauncher
    protonup-ng
    rpcs3
    steam
    wineWow64Packages.stable
  ];

  programs.lutris = {
    enable = true;
    runners.rpcs3.settings.runner.runner_executable = "${pkgs.rpcs3}/bin/rpcs3";
  };
}
