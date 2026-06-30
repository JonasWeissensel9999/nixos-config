{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs; # IMPORTANT
        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.myNoctalia)
          ];
          prefer-no-csd = true;
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
          input = {
            keyboard.xkb = {
              layout = "us,de";
              variant = ",neo_qwertz";
              options = "grp:win_space_toggle";
            };
          };
          outputs = {
            "Dell Inc. DELL U4025QW 412BB34" = {
              transform = "normal";
              variable-refresh-rate = _: { };
            };
            "LG Electronics LG Ultra HD 0x000CD725" = {
              transform = "270";
            };
          };
          layout.gaps = 5;
          # layout.always-center-single-output = true;
          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
            "Mod+Shift+Q".quit = _: { };
            "Mod+Q".close-window = _: { };
            "Mod+F".maximize-column = _: { };
            "Mod+Shift+F".fullscreen-window = _: { };

            "Super+Alt+t".consume-window-into-column = _: { };
            "Super+Alt+Shift+T".expel-window-from-column = _: { };

            "Mod+Left".focus-column-or-monitor-left = _: { };
            "Mod+Right".focus-column-or-monitor-right = _: { };
            "Alt+Left".focus-column-or-monitor-left = _: { };
            "Alt+Right".focus-column-or-monitor-right = _: { };
            "Mod+Up".focus-window-up-or-column-left = _: { };
            "Mod+Down".focus-window-down-or-column-right = _: { };
            "Alt+Up".focus-window-up-or-column-left = _: { };
            "Alt+Down".focus-window-down-or-column-right = _: { };
            "Mod+Alt+Left".focus-monitor-left = _: { };
            "Mod+Alt+Right".focus-monitor-right = _: { };
            "Mod+Control+Alt+Left".move-window-to-monitor-left = _: { };
            "Mod+Control+Alt+Right".move-window-to-monitor-right = _: { };
            "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
            "Mod+0".focus-workspace = 10;
            "Alt+0".focus-workspace = 10;
            "Mod+1".focus-workspace = 1;
            "Alt+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Alt+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Alt+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Alt+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Alt+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Alt+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Alt+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Alt+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;
            "Alt+9".focus-workspace = 9;

            # --- Default Niri Keymaps ---
            "Mod+Shift+Slash".show-hotkey-overlay = _: { };
            "Mod+O".toggle-overview = _: { };
            "Mod+M".maximize-window-to-edges = _: { };
            "Mod+Ctrl+F".expand-column-to-available-width = _: { };
            "Mod+C".center-column = _: { };
            "Mod+Ctrl+C".center-visible-columns = _: { };

            "Mod+H".focus-column-left = _: { };
            "Mod+J".focus-window-down = _: { };
            "Mod+K".focus-window-up = _: { };
            "Mod+L".focus-column-right = _: { };

            "Mod+Ctrl+Left".move-column-left = _: { };
            "Mod+Ctrl+Right".move-column-right = _: { };
            "Mod+Ctrl+Up".move-window-up = _: { };
            "Mod+Ctrl+Down".move-window-down = _: { };
            "Mod+Ctrl+H".move-column-left = _: { };
            "Mod+Ctrl+J".move-window-down = _: { };
            "Mod+Ctrl+K".move-window-up = _: { };
            "Mod+Ctrl+L".move-column-right = _: { };

            "Mod+Home".focus-column-first = _: { };
            "Mod+End".focus-column-last = _: { };
            "Mod+Ctrl+Home".move-column-to-first = _: { };
            "Mod+Ctrl+End".move-column-to-last = _: { };

            "Mod+Shift+Left".focus-monitor-left = _: { };
            "Mod+Shift+Right".focus-monitor-right = _: { };
            "Mod+Shift+Up".focus-monitor-up = _: { };
            "Mod+Shift+Down".focus-monitor-down = _: { };
            "Mod+Shift+H".focus-monitor-left = _: { };
            "Mod+Shift+L".focus-monitor-right = _: { };
            "Mod+Shift+K".focus-monitor-up = _: { };
            "Mod+Shift+J".focus-monitor-down = _: { };

            "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = _: { };
            "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = _: { };
            "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = _: { };
            "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = _: { };
            "Mod+Shift+Ctrl+H".move-column-to-monitor-left = _: { };
            "Mod+Shift+Ctrl+L".move-column-to-monitor-right = _: { };
            "Mod+Shift+Ctrl+K".move-column-to-monitor-up = _: { };
            "Mod+Shift+Ctrl+J".move-column-to-monitor-down = _: { };

            "Mod+Page_Down".focus-workspace-down = _: { };
            "Mod+Page_Up".focus-workspace-up = _: { };
            "Mod+U".focus-workspace-down = _: { };
            "Mod+I".focus-workspace-up = _: { };
            "Mod+Ctrl+Page_Down".move-column-to-workspace-down = _: { };
            "Mod+Ctrl+Page_Up".move-column-to-workspace-up = _: { };
            "Mod+Ctrl+U".move-column-to-workspace-down = _: { };
            "Mod+Ctrl+I".move-column-to-workspace-up = _: { };
            "Mod+Shift+Page_Down".move-workspace-down = _: { };
            "Mod+Shift+Page_Up".move-workspace-up = _: { };
            "Mod+Shift+U".move-workspace-down = _: { };
            "Mod+Shift+I".move-workspace-up = _: { };

            "Mod+WheelScrollDown" = _: { props.cooldown-ms = 150; content.focus-workspace-down = _: { }; };
            "Mod+WheelScrollUp" = _: { props.cooldown-ms = 150; content.focus-workspace-up = _: { }; };
            "Mod+Ctrl+WheelScrollDown" = _: { props.cooldown-ms = 150; content.move-column-to-workspace-down = _: { }; };
            "Mod+Ctrl+WheelScrollUp" = _: { props.cooldown-ms = 150; content.move-column-to-workspace-up = _: { }; };

            "Mod+WheelScrollRight".focus-column-right = _: { };
            "Mod+WheelScrollLeft".focus-column-left = _: { };
            "Mod+Ctrl+WheelScrollRight".move-column-right = _: { };
            "Mod+Ctrl+WheelScrollLeft".move-column-left = _: { };
            "Mod+Shift+WheelScrollDown".focus-column-right = _: { };
            "Mod+Shift+WheelScrollUp".focus-column-left = _: { };
            "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = _: { };
            "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = _: { };

            "Mod+Ctrl+1".move-column-to-workspace = 1;
            "Mod+Ctrl+2".move-column-to-workspace = 2;
            "Mod+Ctrl+3".move-column-to-workspace = 3;
            "Mod+Ctrl+4".move-column-to-workspace = 4;
            "Mod+Ctrl+5".move-column-to-workspace = 5;
            "Mod+Ctrl+6".move-column-to-workspace = 6;
            "Mod+Ctrl+7".move-column-to-workspace = 7;
            "Mod+Ctrl+8".move-column-to-workspace = 8;
            "Mod+Ctrl+9".move-column-to-workspace = 9;
            "Mod+Ctrl+0".move-column-to-workspace = 10;

            "Mod+BracketLeft".consume-or-expel-window-left = _: { };
            "Mod+BracketRight".consume-or-expel-window-right = _: { };
            "Mod+Comma".consume-window-into-column = _: { };
            "Mod+Period".expel-window-from-column = _: { };
            "Mod+R".switch-preset-column-width = _: { };
            "Mod+Shift+R".switch-preset-column-width-back = _: { };
            "Mod+Ctrl+Shift+R".switch-preset-window-height = _: { };
            "Mod+Ctrl+R".reset-window-height = _: { };

            "Mod+Minus".set-column-width = "-10%";
            "Mod+Equal".set-column-width = "+10%";
            "Mod+Shift+Minus".set-window-height = "-10%";
            "Mod+Shift+Equal".set-window-height = "+10%";

            "Mod+V".toggle-window-floating = _: { };
            "Mod+Shift+V".switch-focus-between-floating-and-tiling = _: { };
            "Mod+W".toggle-column-tabbed-display = _: { };

            "Print".screenshot = _: { };
            "Ctrl+Print".screenshot-screen = _: { };
            "Alt+Print".screenshot-window = _: { };

            "Mod+Escape" = _: { props.allow-inhibiting = false; content.toggle-keyboard-shortcuts-inhibit = _: { }; };
            "Mod+Shift+E".quit = _: { };
            "Ctrl+Alt+Delete".quit = _: { };
            "Mod+Shift+P".power-off-monitors = _: { };

            # Volume, brightness, media controls
            "XF86AudioRaiseVolume" = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; };
            "XF86AudioLowerVolume" = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; };
            "XF86AudioMute" = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
            "XF86AudioMicMute" = _: { props.allow-when-locked = true; content.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; };

            "XF86AudioPlay" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl play-pause"; };
            "XF86AudioPause" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl play-pause"; };
            "XF86AudioStop" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl stop"; };
            "XF86AudioPrev" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl previous"; };
            "XF86AudioNext" = _: { props.allow-when-locked = true; content.spawn-sh = "playerctl next"; };

            "XF86MonBrightnessUp" = _: { props.allow-when-locked = true; content.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ]; };
            "XF86MonBrightnessDown" = _: { props.allow-when-locked = true; content.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ]; };
          };
        };
      };
    };
}
