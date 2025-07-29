{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.meenzen.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      systemd = {
        enable = true;
        variables = ["--all"];
        extraCommands = [
          "systemctl --user stop hyprland-session.target"
          "systemctl --user start hyprland-session.target"
          "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
        ];
      };

      settings = {
        "$mod" = "SUPER";
        "$terminal" = "wezterm";
        "$fileManager" = "dolphin";
        "$menu" = "rofi -show drun";

        general = {
          gaps_in = 5;
          gaps_out = 5;
        };

        decoration = {
          rounding = 5;
          rounding_power = 2;
        };

        input = {
          kb_layout = "de";
          touchpad.natural_scroll = true;
        };

        gestures.workspace_swipe = true;

        monitor = [
          # todo: framework specific
          "eDP-1, 2256x1504@60, 0x0, 1"
        ];

        bindm = [
          # resize and move windows using mouse
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
          "$mod ALT, mouse:272, resizewindow"
        ];

        bind =
          [
            # programs
            "$mod, B, exec, brave"
            "$mod, D, exec, discord"
            "$mod, E, exec, $fileManager"
            "$mod, F, exec, firefox"
            "$mod, G, exec, google-chrome-stable"
            "$mod, Q, exec, $terminal"

            # misc
            "$mod, C, killactive,"
            "$mod, M, exit,"
            "$mod, V, togglefloating,"
            "ALT, SPACE, exec, $menu"

            # window focus
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            # special workspace (scratchpad)
            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"

            # scroll through workspaces
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );

        # Laptop multimedia keys
        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
          ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ];

        windowrule = [
          # Ignore maximize requests from apps. You'll probably like this.
          "suppressevent maximize, class:.*"

          # Fix some dragging issues with XWayland
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];
      };
    };

    # set environment variables from home manager
    xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

    programs.hyprpanel = {
      enable = false;
      settings = {
        bar.battery.label = true;
        bar.bluetooth.label = false;
        bar.clock.format = "%H:%M:%S";
        bar.layouts = {
          "*" = {
            left = [
              "clock"
              "battery"
              "workspaces"
            ];
            middle = ["windowtitle"];
            right = [
              "systray"
              "volume"
              "network"
              "bluetooth"
              "notifications"
            ];
          };
        };
        theme.bar.transparent = true;
      };
    };
    programs.rofi.enable = true;
  };
}
