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
          };
        };
      };
    };
}
