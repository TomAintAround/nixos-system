{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  accent = "sky";
  flavor = "mocha";
in {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  gtk = {
    theme = {
      name = "catppuccin-${flavor}-${accent}-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [accent];
        variant = flavor;
      };
    };
  };

  catppuccin = {
    enable = true;
    autoEnable = false;

    alacritty = {
      enable = true;
      inherit flavor;
    };

    bat = {
      enable = true;
      inherit flavor;
    };

    brave = {
      enable = true;
      inherit flavor;
    };

    btop = {
      enable = true;
      inherit flavor;
    };

    cursors = {
      enable = false;
      inherit accent flavor;
    };

    delta = {
      enable = true;
      inherit flavor;
    };

    dunst = {
      enable = true;
      inherit flavor;
    };

    fish = {
      enable = true;
      inherit flavor;
    };

    fzf = {
      enable = true;
      inherit flavor;
    };

    gtk.icon = {
      enable = true;
      inherit accent flavor;
    };

    hyprland = {
      #TODO: turn this on when i switch hyprland's config to lua
      enable = false;
      inherit accent flavor;
    };

    hyprlock = {
      enable = true;
      useDefaultConfig = false;
      inherit accent flavor;
    };

    kitty = {
      enable = true;
      inherit flavor;
    };

    kvantum = {
      enable = true;
      apply = true;
      inherit accent flavor;
    };

    lazygit = {
      enable = true;
      inherit accent flavor;
    };

    librewolf = {
      enable = true;
      force = true;
      inherit accent flavor;
    };

    mpv = {
      enable = true;
      accent = "mauve";
      inherit flavor;
    };

    obs = {
      enable = false;
      inherit flavor;
    };

    thunderbird = {
      enable = true;
      inherit accent flavor;
    };

    tmux = {
      enable = true;
      inherit flavor;
      extraConfig = ''
        set -g @catppuccin_flavor "mocha"
        set -g @catppuccin_window_status_style "rounded"
        set -g status-left ""
        set -g status-left-length 100

        set -g status-right-length 100
        set -g status-right "#{E:@catppuccin_status_user}"
        set -ag status-right "#{E:@catppuccin_status_host}"
        set -ag status-right "#{E:@catppuccin_status_application}"
        set -ag status-right "#{E:@catppuccin_status_session}"
        set -g @catppuccin_status_left_separator  " "
        set -g @catppuccin_status_right_separator ""
        set -g @catppuccin_status_fill "icon"
        set -g @catppuccin_status_connect_separator "no"

        set -g @catppuccin_directory_text "#{pane_current_path}"
        set -g @catppuccin_user_color "#f38ba8"
        set -g @catppuccin_host_color "#eba0ac"
        set -g @catppuccin_application_color  "#fab387"
      '';
    };

    yazi = {
      enable = true;
      inherit accent flavor;
    };
  };

  programs = {
    mpv.scriptOpts = {
      modernz = {
        window_title_color = "#cdd6f4";
        window_controls_color = "#cdd6f4";
        windowcontrols_close_hover = "#f38ba8";
        windowcontrols_max_hover = "#f9e2af";
        windowcontrols_min_hover = "#a6e3a1";
        title_color = "#cdd6f4";
        cache_info_color = "#cdd6f4";
        seekbar_cache_color = "#181825";
        seekbarfg_color = "#89dceb";
        seekbarbg_color = "#11111b";
        seek_handle_color = "#89dceb";
        seek_handle_border_color = "#89dceb";
        time_color = "#cdd6f4";
        chapter_title_color = "#cdd6f4";
        side_buttons_color = "#cdd6f4";
        middle_buttons_color = "#cdd6f4";
        playpause_color = "#cdd6f4";
        held_element_color = "#6c7086";
        hover_effect_color = "#89dceb";
        thumbnail_box_color = "#11111b";
        thumbnail_box_outline = "#313244";
        nibble_color = "#cdd6f4";
        nibble_current_color = "#89dceb";
        ab_loop_color = "#a6e3a1";
      };
      pause_indicator_lite = {
        icon_color = "#cdd6f4";
        icon_border_color = "#11111b";
      };
    };

    vesktop.settings = {
      splashColor = "rgb(205, 214, 244)";
      splashBackground = "rgb(17, 17, 27)";
    };
  };

  services.flameshot.settings.General = {
    contrastUiColor = "#89dceb";
    uiColor = "#1e1e2e";
  };

  # Script to copy the GTK theme to ~/.themes/ and the icon theme
  # to ~/.icons each time home-manager is updated for flatpak support
  home.activation.copy-themes = lib.hm.dag.entryAfter ["writeBoundary"] ''
    themeDir=${config.home.homeDirectory}/.themes
    iconDir=${config.home.homeDirectory}/.icons

    run mkdir "$themeDir" 2>/dev/null & # For some reason, "&" is needed
    run mkdir "$iconDir" 2>/dev/null &
    run sleep 1

    # Because there's an override in catppuccin-gtk,
    # it's more difficult to get the path
    themePath=$(run nix-instantiate --eval --expr '
    let
    	pkgs = import <nixpkgs> {};
    	myGtk = pkgs.catppuccin-gtk.override (old: {
    		accents = [ "${accent}" ];
    		variant = "${flavor}";
    	});
    in
    	myGtk.outPath
    ' | run sed 's/\"//g')/share/themes/${config.gtk.theme.name}

    newThemePath="$themeDir"/${config.gtk.theme.name}

    copy () {
    	run cp -r "$1" "$2"
    	run chmod +w "$3"
    }

    if [ -e "$newThemePath" ]; then
    	if ! run diff "$themePath" $newThemePath &>/dev/null; then
    		${pkgs.trash-cli}/bin/trash-put "$newThemePath"
    		copy "$themePath" "$themeDir" "$newThemePath"
    	fi
    else
    	copy "$themePath" "$themeDir" "$newThemePath"
    fi

    iconPath=$(run nix-instantiate --eval --expr '
    let
    	pkgs = import <nixpkgs> {};
    	myIcon = pkgs.catppuccin-papirus-folders.override (old: {
    		accent = "${accent}";
    		flavor = "${flavor}";
    	});
    in
    	myIcon.outPath
    ' | run sed 's/\"//g')/share/icons/Papirus

    newIconPath="$iconDir"/Papirus

    for extra in "" "-Dark" "-Light"; do
    	if [ -e "$newIconPath""$extra" ]; then
    		if ! run diff "$iconPath""$extra" "$newIconPath""$extra" &>/dev/null; then
    			${pkgs.trash-cli}/bin/trash-put "$newIconPath""$extra"
    			copy "$iconPath""$extra" "$iconDir" "$newIconPath""$extra"
    		fi
    	else
    		copy "$iconPath""$extra" "$iconDir" "$newIconPath""$extra"
    	fi
    done
  '';

  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    general = {
      #TODO: turn this on when i switch hyprland's config to lua

      # "col.inactive_border" = "\$base \$overlay0 45deg";
      # "col.active_border" = "\$sky \$blue 45deg";
      "col.inactive_border" = "rgb(30,30,46) rgb(108,112,134) 45deg";
      "col.active_border" = "rgb(137,220,235) rgb(137,180,250) 45deg";
    };

    plugin.hyprbars = {
      bar_color = "\$crust";
      "col.text" = "\$text";
      hyprbars-button = [
        "\$red, 15, , hyprctl dispatch killactive"
        "\$yellow, 15, , hyprctl dispatch fullscreen 1"
      ];
    };
  };

  # FIX: for some reason, catppuccin.kvantum.apply isn't working correctly
  qt.kvantum.settings.General.theme = "catppuccin-${flavor}-${accent}";
}
