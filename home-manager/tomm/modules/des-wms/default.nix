{
  pkgs,
  lib,
  config,
  ...
}: {
  home = {
    packages = with pkgs;
      lib.optionals config.displayServer.wayland.enable [
        hyprpicker # Color picker
      ]
      ++ lib.optionals (config.displayServer.wayland.enable && config.wm.enable) [
        awww # Wallpaper manager
        clipman # Clipboard manager
        wl-clipboard # Copy/Paste
      ]
      ++ lib.optionals config.wm.enable [
        gnome-disk-utility
        networkmanagerapplet
        pavucontrol
        polkit_gnome
        rofi
        trash-cli
      ]
      ++ lib.optionals config.brightness.enable [
        brightnessctl
      ];
    sessionVariables.NIXOS_OZONE_WL = lib.mkIf config.displayServer.wayland.enable 1;
  };

  services = {
    blueman-applet.enable = lib.mkDefault (config.bluetooth.enable && config.wm.enable);

    dunst = {
      enable = lib.mkDefault config.wm.enable;
      settings = {
        global = {
          monitor = 1;
          follow = "none";
          indicate_hidden = true;
          notification_limit = 20;
          sort = true;
          show_age_threshold = 60;
          show_indicators = true;
          dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst";
          browser = "/run/current-system/sw/bin/xdg-open";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          ignore_dbusclose = false;

          stack_duplicates = true;
          hide_duplicate_count = false;

          width = "(100, 400)";
          height = "(0, 300)";
          origin = "top-right";
          offset = "40x10";
          scale = 0;
          transparency = 0;
          padding = 15;
          horizontal_padding = 15;
          text_icon_padding = 20;
          frame_width = 0;
          separator_height = 2;
          gap_size = 30;
          line_height = 0;

          corner_radius = 10;
          corners = "all";

          progress_bar = true;
          progress_bar_height = 15;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 290;
          progress_bar_corner_radius = 5;
          progress_bar_corners = "all";

          icon_corner_radius = 10;
          icon_corners = "all";
          enable_recursive_icon_lookup = true;
          icon_theme = "Papirus-Dark";
          icon_position = "left";
          min_icon_size = 32;
          max_icon_size = 128;

          font = "Inter 13";
          markup = "full";
          format = "<b>%a</b>\\n%s\\n%b";
          alignment = "left";
          vertical_alignment = "center";
          ignore_newline = false;
          ellipsize = "middle";

          sticky_history = true;
          history_length = 20;

          force_xwayland = false;
          force_xinerama = false;

          mouse_left_click = "close_current";
          mouse_right_click = "do_action, close_current";
          mouse_middle_click = "close_all";

          per_monitor_dpi = false;
        };

        urgency_low = {
          #background = "#222222";
          #foreground = "#888888";
          timeout = 10;
          #default_icon = "/path/to/icon";
        };

        urgency_normal = {
          #background = "#285577";
          #foreground = "#ffffff";
          timeout = 10;
          override_pause_level = 30;
          #default_icon = "/path/to/icon";
        };

        urgency_critical = {
          #background = "#900000";
          #foreground = "#ffffff";
          #frame_color = "#ff0000";
          timeout = 0;
          override_pause_level = 60;
          #default_icon = "/path/to/icon";
        };
      };
    };

    flameshot = {
      enable = lib.mkDefault (config.wm.enable && config.displayServer.wayland.enable);
      settings.General = {
        drawColor = "#ff0000";
        showDesktopNotification = false;
        showStartupLaunchMessage = false;
      };
    };

    hypridle = {
      enable = lib.mkDefault (config.displayServer.wayland.enable && config.wm.enable);
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          (
            lib.mkIf config.brightness.enable {
              timeout = 150;
              on-timeout = "brightnessctl -s set 10";
              on-resume = "brightnessctl -r";
            }
          )

          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }

          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
          }
        ];
      };
    };

    hyprsunset = {
      enable = lib.mkDefault (config.displayServer.wayland.enable && config.wm.enable);
      settings = {
        max-gamma = 100;
        profile = [
          {
            time = "7:30";
            gamma = 1.0;
            identity = true;
          }
          {
            time = "22:00";
            temperature = 4000;
            gamma = 0.8;
          }
        ];
      };
    };

    network-manager-applet.enable = lib.mkDefault config.wm.enable;

    udiskie = {
      enable = lib.mkDefault config.wm.enable;
      tray = "auto";
    };
  };

  systemd.user = let
    checkWM = lib.getExe (pkgs.writeShellScriptBin "checkWM" ''
      case "$XDG_CURRENT_DESKTOP" in
        none+awesome|Hyprland) exit 0 ;;
        *) echo "XDG_CURRENT_DESKTOP not allowed: $XDG_CURRENT_DESKTOP" >&2; exit 1 ;;
      esac
    '');
    checkWayland = "WAYLAND_DISPLAY";
  in {
    services = {
      blueman-applet = lib.mkIf config.services.blueman-applet.enable {
        Service.ExecCondition = checkWM;
      };
      dunst = lib.mkIf config.services.dunst.enable {
        Service = {
          ExecStart = lib.mkForce "${pkgs.dunst}/bin/dunst --config ~/.config/dunst/dunstrc";
          ExecCondition = checkWM;
        };
      };
      flameshot = lib.mkIf config.services.flameshot.enable {
        Unit.ConditionEnvironment = lib.mkDefault checkWayland;
        Service.ExecCondition = checkWM;
      };
      hypridle = lib.mkIf config.services.flameshot.enable {
        Unit.ConditionEnvironment = lib.mkDefault checkWayland;
        Service.ExecCondition = checkWM;
      };
      hyprsunset = lib.mkIf config.services.flameshot.enable {
        Unit.ConditionEnvironment = lib.mkDefault checkWayland;
        Service.ExecCondition = checkWM;
      };
      network-manager-applet = lib.mkIf config.services.network-manager-applet.enable {
        Service.ExecCondition = checkWM;
      };
      udiskie = lib.mkIf config.services.udiskie.enable {
        Service.ExecCondition = checkWM;
      };
      trash-cli = {
        Unit = {
          Description = "Deletes 14+ day old trash";
          ExecCondition = checkWM;
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.trash-cli}/bin/trash-empty 14";
        };
      };
    };

    timers.trash-cli = {
      Unit.Description = "Automatically deletes 14+ day old trash";

      Timer = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "trash-cli.service";
      };
    };
  };

  programs.hyprlock = {
    enable = lib.mkDefault (config.displayServer.wayland.enable && config.wm.enable);
    settings = {
      general.hide_cursor = true;

      auth.fingerprint.enabled = true;

      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = ["fade, 1, 3, linear" "inputField, 1, 1, linear"];
      };

      background = {
        path = "${config.xdg.cacheHome}/wallpaper";
        blur_passes = 2;
        blur_size = 7;
      };

      input-field = {
        size = "450, 50";
        font_family = "${config.gtk.font.name} Italic";
        fade_on_empty = false;
        placeholder_text = "Password";
        swap_font_color = true;
        position = "0, -200";
        shadow_color = "rgba(00000080)";
        shadow_passes = 2;
        shadow_size = 5;
        outer_color = "$accent";
        inner_color = "$base";
        font_color = "$text";
        check_color = "$yellow";
        fail_color = "$red";
        capslock = "$red";
      };

      label = [
        {
          text = "$TIME";
          font_size = 128;
          font_family = config.gtk.font.name;
          position = "0, 100";
          shadow_color = "rgba(00000080)";
          shadow_passes = 2;
          shadow_size = 5;
          color = "$text";
        }
        {
          text = let
            script = pkgs.writeShellScriptBin "getBattery.bash" ''
              #!/usr/bin/env bash

              command -v upower >/dev/null || exit 1

              batteryInfo=$(upower -b)
              percentage=$(grep percentage <<<"$batteryInfo" | awk '{print $2}' | tr -d '%')
              state=$(grep state <<<"$batteryInfo" | awk '{print $2}')

              isCharging() {
              	[[ "$state" == "charging" ]]
              }

              iconsDischarging=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
              iconsCharging=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
              index=$(( percentage / 10 ))
              (( index > 9 )) && index=9
              if isCharging; then
              	icon=''${iconsCharging[index]}
              else
              	icon=''${iconsDischarging[index]}
              fi

              echo "$icon $percentage%"
            '';
          in "cmd[update:1000] echo \"$(${lib.getExe script})\"";
          font_size = 16;
          font_family = config.gtk.font.name;
          halign = "right";
          valign = "bottom";
          position = "-10, 10";
          shadow_color = "rgba(00000080)";
          shadow_passes = 2;
          shadow_size = 5;
          color = "$text";
        }
      ];
    };
  };
}
