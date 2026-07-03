{
  pkgs,
  lib,
  config,
  inputs,
  system,
  userVars,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.default

    ./customOptions.nix
    ./des-wms
    ./des-wms/hyprland.nix
    ./mpv
    ./themes
    ./tmux
    ./yazi
    # ./alacritty.nix
    ./btop.nix
    # ./firefox.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./kitty.nix
    ./lazygit.nix
    # ./librewolf.nix
    ./music.nix
    ./neovim.nix
    ./scripts.nix
  ];

  nix.gc = {
    dates = "daily";
    automatic = true;
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "${userVars.username}";
    homeDirectory = "/home/${userVars.username}";
    stateVersion = "24.05";
    preferXdgDirectories = true;

    language = let
      pt = "pt_PT.UTF-8";
      # en = "en_GB.UTF-8";
      es = "es_ES.UTF-8";
    in {
      address = pt;
      base = es;
      collate = es;
      ctype = es;
      measurement = es;
      messages = es;
      monetary = pt;
      name = pt;
      numeric = es;
      paper = pt;
      telephone = pt;
      time = es;
    };

    sessionVariables = {
      # Default Apps
      OPENER = "xdg-open";
      VISUAl = "nvim";
      EDITOR = "nvim";
      PAGER = "bat --paging=always";
      TERMINAL = "kitty";
      READER = "libreoffice --draw";
      BROWSER = "helium";
      IMAGE_EDITOR = "gimp";
      AUDIO_PLAYER = "mpv";
      VIDEO_PLAYER = "mpv";
      FILE_MANAGER = "yazi";

      # Paths
      GOPATH = "${config.xdg.dataHome}/go";
      WINEPREFIX = "${config.xdg.dataHome}/wine";

      # Fixes
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    packages = with pkgs; [
      act
      bitwarden-cli
      bottles
      cpu-x
      exiftool
      eza
      ffmpeg-full
      gimp
      inputs.helium.packages.${system}.default
      imagemagick
      jq
      killall
      libnotify
      libreoffice
      libsecret
      newsflash
      nh
      nix-tree # View all package dependencies
      nix-update
      nurl # Query data from a Github repo
      obsidian
      p7zip
      parallel
      popsicle
      ripdrag # Drag-and-drop for the terminal
      ripgrep # Grep but better
      seahorse # Secrets manager
      sshfs
      stremio-linux-shell
      thunderbird
      unar
      unrar-wrapper # Extrach RAR files
      unzip
      vscode
      wget
      zip
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = ["helium.desktop"];
        "x-scheme-handler/https" = ["helium.desktop"];
      };
    };
    configFile."monitorsConfig.json".text = builtins.toJSON config.monitors;
  };

  programs = {
    home-manager.enable = true;
    man.generateCaches = lib.mkForce false;

    bat = {
      enable = true;
      config = {
        color = "always";
        italic-text = "always";
        wrap = "never";
        style = "default";
      };
      extraPackages = with pkgs.bat-extras; [
        batman
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fd = {
      enable = true;
      hidden = true;
      extraOptions = ["--color='always'"];
    };

    nix-index.enable = true;
    nix-index-database.comma.enable = true;

    vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";
        minimizeToTray = false;
        arRPC = true;
        enableSplashScreen = false;
        hardwareVideoAcceleration = true;
      };
    };

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };
  };

  services = {
    easyeffects = {
      enable = true;
      preset = "Default";
    };

    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
