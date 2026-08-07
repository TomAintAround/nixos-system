{
  pkgs,
  lib,
  config,
  inputs,
  system,
  ...
}: {
  displayServer.wayland.enable = true;
  wm.enable = true;

  xdg.configFile = {
    "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    "uwsm/env-hyprland".text = ''
      export HYPRLAND_TRACE=1
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";

    settings = {
      env = [
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland,x11"
        "SDL_VIDEO_DRIVER,wayland,x11"
        "CLUTTER_BACKEND,wayland"
      ];

      monitorv2 = map (m: let
        mode = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
        position = "${toString m.x}x${toString m.y}";
      in
        {
          output = m.name;
        }
        // (
          if m.enable
          then {
            inherit mode position;
            inherit (m) scale;
            transform = 0;
          }
          else {
            disabled = true;
          }
        ))
      config.monitors;

      general = {
        border_size = 2;
        gaps_in = 2;
        gaps_out = 5;
        layout = "master";
        resize_on_border = true;
        allow_tearing = true;
        snap.enabled = true;
      };

      decoration = {
        rounding = 15;
        rounding_power = 4.0;
        dim_inactive = true;
        dim_strength = 0.1;
        blur = {
          size = 7;
          passes = 2;
        };
        shadow = {
          color = "rgba(00000080)";
          range = 15;
          render_power = 2;
          offset = "7 7";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "win, 0.3, 0.9, 0.5, 1.1"
          "winIn, 0.7, 1.1, 0.1, 1.1"
          "winOut, 0.35, -0.3, 0.25, 1"
          "linear, 1, 1, 0, 0"
        ];
        animation = [
          "windowsIn, 1, 3, winIn, gnomed"
          "windowsOut, 1, 5, winOut, gnomed"
          "windowsMove, 1, 5, win, gnomed"
          "layersIn, 1, 3, winIn, slide"
          "layersOut, 1, 5, linear, fade"
          "border, 1, 4, linear"
          "borderangle, 1, 30, linear, loop"
          "workspaces, 1, 5, win, slidevert"
        ];
      };

      input = {
        kb_model = "QWERTY";
        kb_layout = "pt,es";
        kb_options = "grp:alt_shift_toggle";
        numlock_by_default = true;
        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.50;
        };
      };

      gestures.workspace_swipe_distance = 200;

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };

      binds = {
        workspace_back_and_forth = false;
      };

      xwayland.force_zero_scaling = true;

      cursor = {
        no_hardware_cursors = false;
        default_monitor = let
          monitor = builtins.elemAt (builtins.filter (m: m.default) config.monitors) 0;
        in
          monitor.name;
      };

      ecosystem.no_donation_nag = true;

      master.mfact = 0.5;

      bind =
        [
          # Hyprland keybinds
          "SUPER SHIFT, Q, killactive,"
          "SUPER SHIFT, BackSpace, exit,"
          "SUPER SHIFT, D, exec, ${pkgs.hyprlock}/bin/hyprlock"
          "SUPER, V, togglefloating,"
          "SUPER, G, layoutmsg, addmaster"
          "SUPER SHIFT, G, layoutmsg, removemaster"
          "SUPER, F, fullscreen, 0"
          "SUPER SHIFT, F, fullscreen, 1"
          (let
            changeLayout = pkgs.writeShellScriptBin "changeLayout.bash" ''
              ###################################################################################################################
              # https://github.com/arcolinux/arcolinux-hyprland/blob/main/etc/skel/.config/hypr/scripts/changeLayout (modified) #
              ###################################################################################################################

              LAYOUT=$(${pkgs.hyprland}/bin/hyprctl -j getoption general:layout | ${pkgs.jq}/bin/jq '.str' | sed 's/"//g')

              case "$LAYOUT" in
              "master")
              	${pkgs.hyprland}/bin/hyprctl keyword general:layout dwindle
              	${pkgs.libnotify}/bin/notify-send --app-name="Layout change" "Dwindle Layout"
              ;;
              "dwindle")
              	${pkgs.hyprland}/bin/hyprctl keyword general:layout master
              	${pkgs.libnotify}/bin/notify-send --app-name="Layout change" "Master Layout"
              ;;
              *) ;;
              esac
            '';
          in "SUPER, S, exec, ${lib.getExe changeLayout}")

          # Apps keybinds
          "${
            if config.programs.alacritty.enable
            then "SUPER, Return, exec, ${pkgs.alacritty}/bin/alacritty"
            else "SUPER, F14, exec,"
          }"
          "${
            if config.programs.kitty.enable
            then "SUPER, Return, exec, ${pkgs.kitty}/bin/kitty"
            else "SUPER, F14, exec,"
          }"
          "SUPER, C, exec, ${pkgs.clipman}/bin/clipman pick -t rofi -T'-theme ${config.xdg.configHome}/rofi/clipboard.rasi'"
          "SUPER, Space, exec, ${pkgs.rofi}/bin/rofi -show drun -modi drun,window -theme ~/.config/rofi/launcher.rasi -show-icons -icon-theme Papirus-Dark"
          "SUPER, F1, exec, ${inputs.helium.packages.${system}.default}/bin/helium"
          "SUPER, F2, exec, ${pkgs.vesktop}/bin/vesktop"
          "SUPER, F3, exec, ${pkgs.obsidian}/bin/obsidian"
          "SUPER, F4, exec, ${pkgs.thunderbird}/bin/thunderbird"
          "SUPER, F5, exec, ${pkgs.newsflash}/bin/io.gitlab.news_flash.NewsFlash"
          "${
            if config.programs.lutris.enable
            then "SUPER, F6, exec, ${pkgs.lutris}/bin/lutris"
            else "SUPER, F14, exec,"
          }"
          "SUPER, F10, exec, ${pkgs.hyprpicker}/bin/hyprpicker -a"
          "${
            if config.programs.alacritty.enable
            then "SUPER, F11, exec, ${pkgs.alacritty}/bin/alacritty --class music -e ncmpcpp"
            else "SUPER, F14, exec,"
          }"
          "${
            if config.programs.alacritty.enable
            then "SUPER, F12, exec, ${pkgs.alacritty}/bin/alacritty --class btop -e btop"
            else "SUPER, F14, exec,"
          }"
          "${
            if config.programs.kitty.enable
            then "SUPER, F11, exec, ${pkgs.kitty}/bin/kitty --app-id music ncmpcpp"
            else "SUPER, F14, exec,"
          }"
          "${
            if config.programs.kitty.enable
            then "SUPER, F12, exec, ${pkgs.kitty}/bin/kitty --app-id btop btop"
            else "SUPER, F14, exec,"
          }"
          ",Print, exec, ${pkgs.flameshot.override {enableWlrSupport = true;}}/bin/flameshot gui"

          # Move focus
          "SUPER, H, movefocus, l"
          "SUPER, L, movefocus, r"
          "SUPER, K, movefocus, u"
          "SUPER, J, movefocus, d"

          # Move windows
          "SUPER SHIFT, H, movewindow, l"
          "SUPER SHIFT, L, movewindow, r"
          "SUPER SHIFT, K, movewindow, u"
          "SUPER SHIFT, J, movewindow, d"

          # Zoom
          "SUPER, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
          "SUPER, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"
          "SUPER SHIFT, minus, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "SUPER SHIFT, plus, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "SUPER SHIFT, KEYPAD_ADD, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "SUPER SHIFT, KEYPAD_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor 1"

          # OBS
          "CTRL SHIFT, Home, pass, class:^(com\.obsproject\.Studio)$"
          "CTRL SHIFT, End, pass, class:^(com\.obsproject\.Studio)$"
          "CTRL SHIFT, Insert, pass, class:^(com\.obsproject\.Studio)$"
          "CTRL SHIFT, Delete, pass, class:^(com\.obsproject\.Studio)$"
        ]
        ++ (
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "SUPER, code:1${toString i}, workspace, ${toString ws}"
                "SUPER SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            10)
        )
        ++
        # I know what you're thinking: "What the hell am I reading? What kind of spaguetti mess is this?".
        # You think this sucks? THEN MAKE IT BETTER YOURSELF AND MAKE A PULL REQUEST. Let's see if you can
        # (please do it I beg you).
        # Update: I've managed to make it better. I was very inexperienced the first time I did this.
        (let
          inherit (builtins) filter genList sort lessThan elemAt length;

          enabledMonitors = filter (m: m.enable) config.monitors;

          size = length enabledMonitors;

          sameXCoord = (map (m: m.x) enabledMonitors) == (genList (_: (elemAt enabledMonitors 0).x) size);
          coordinates_x = sort lessThan (map (m: m.x) enabledMonitors);
          coordinates_y = sort lessThan (map (m: m.y) enabledMonitors);
          coordinates =
            if sameXCoord
            then coordinates_y
            else coordinates_x;

          monSelector = n: (elemAt coordinates (n - 1)).name;
        in
          if coordinates != (lib.lists.unique coordinates)
          then throw "If your monitors are vertically distributed, each one must have a unique ordinate. If not, each one must have a unique abscissa"
          else if size == 1
          then []
          else if size == 2
          then [
            "SUPER ALT, H, focusmonitor, ${monSelector 1}"
            "SUPER ALT, L, focusmonitor, ${monSelector 2}"
            "SUPER ALT SHIFT, H, movewindow, mon:${monSelector 1}"
            "SUPER ALT SHIFT, L, movewindow, mon:${monSelector 2}"
          ]
          else if size == 3
          then [
            "SUPER ALT, H, focusmonitor, ${monSelector 1}"
            "SUPER ALT, K, focusmonitor, ${monSelector 2}"
            "SUPER ALT, L, focusmonitor, ${monSelector 3}"
            "SUPER ALT SHIFT, H, movewindow, mon:${monSelector 1}"
            "SUPER ALT SHIFT, K, movewindow, mon:${monSelector 2}"
            "SUPER ALT SHIFT, L, movewindow, mon:${monSelector 3}"
          ]
          else if size == 4
          then [
            "SUPER ALT, H, focusmonitor, ${monSelector 1}"
            "SUPER ALT, J, focusmonitor, ${monSelector 2}"
            "SUPER ALT, K, focusmonitor, ${monSelector 3}"
            "SUPER ALT, L, focusmonitor, ${monSelector 4}"
            "SUPER ALT SHIFT, H, movewindow, mon:${monSelector 1}"
            "SUPER ALT SHIFT, J, movewindow, mon:${monSelector 2}"
            "SUPER ALT SHIFT, K, movewindow, mon:${monSelector 3}"
            "SUPER ALT SHIFT, L, movewindow, mon:${monSelector 4}"
          ]
          else throw "WHAT THE HELL ARE YOU DOING WITH 5+ MONITORS???????");

      # Audio keybinds
      bindel = [
        ",XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "${
          if config.brightness.enable
          then ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 2%+"
          else ",XF86MonBrightnessUp, exec, hyprctl hyprsunset gamma +2"
        }"
        "${
          if config.brightness.enable
          then ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 2%-"
          else ",XF86MonBrightnessDown, exec, hyprctl hyprsunset gamma -2"
        }"
      ];
      bindl = [
        ",XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ",XF86AudioNext, exec, ${pkgs.wireplumber}/bin/playerctl next"
        ",XF86AudioPrev, exec, ${pkgs.wireplumber}/bin/playerctl previous"
        ",XF86AudioStop, exec, ${pkgs.wireplumber}/bin/playerctl stop"
      ];

      binde = [
        # Resize windows
        "SUPER CTRL, H, resizeactive, -10 0"
        "SUPER CTRL, L, resizeactive, 10 0"
        "SUPER CTRL, K, resizeactive, 0 -10"
        "SUPER CTRL, J, resizeactive, 0 10"

        # Zoom
        "SUPER, minus, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"
        "SUPER, plus, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
        "SUPER, KP_ADD, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
        "SUPER, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"
      ];

      # Move/resize windows
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      gesture = [
        "3, vertical, mod: SUPER, workspace"
        "3, swipe, resize"
      ];

      "\$scriptsDir" = "${config.xdg.dataHome}/scripts";
      exec-once = [
        # Set wallpaper
        "${pkgs.awww}/bin/awww-daemon"
        "wallpaper-change random"

        # Exporting important variables
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

        # Polkit
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

        # Generate Album Arts
        "\$scriptsDir/albumart.bash"

        # Clipboard Manager
        "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch clipman store --no-persist"

        # Software for Peripherals
        "${
          if config.openrazer.enable
          then "${pkgs.polychromatic}/bin/polychromatic-tray-applet}"
          else "echo no"
        }"
        "${
          if config.openrgb.enable
          then "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized"
          else "echo no"
        }"
      ];

      windowrule = let
        popup = {
          class,
          width,
          height,
          x,
          y,
        }: [
          "match:class ^${class}$, float 1"
          "match:class ^${class}$, size ${width} ${height}"
          "match:class ^${class}$, move ${x} ${y}"
          "match:class ^${class}$, animation slide windows"
          "match:class ^${class}$, pin 1"
          "match:class ^${class}$, suppress_event fullscreen"
        ];
      in [
        "match:class ^ueberzugpp.*, no_anim 1"
        "match:class ^ueberzugpp.*, no_shadow 1"
        "match:class ^ueberzugpp.*, border_size 0"
        "match:class ^ueberzugpp.*, float 1"
        "match:class ^ueberzugpp.*, no_initial_focus 1"
        "match:class ^ueberzugpp.*, suppress_event fullscreen"

        "match:title ^flameshot$, no_anim 1"
        "match:title ^flameshot$, float 1"
        "match:title ^flameshot$, move 0 0"
        "match:title ^flameshot$, pin 1"
        "match:title ^flameshot$, border_size 0"
        "match:title ^flameshot$, suppress_event fullscreen"

        (popup {
          class = "music";
          width = "(monitor_w*0.86)";
          height = "660";
          x = "(monitor_w*0.07)";
          y = "35";
        })

        (popup {
          class = "btop";
          width = "(monitor_w*0.8)";
          height = "(monitor_h*0.95)";
          x = "(monitor_w*0.1)";
          y = "35";
        })
      ];

      layerrule = [
        "match:namespace ^hyprpicker$, no_anim 1"
        "match:namespace ^awww-daemon$, no_anim 1"
      ];
    };
  };
}
