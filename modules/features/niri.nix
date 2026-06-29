{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
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
            keyboard.xkb.layout = "de";
          };
          layout.gaps = 5;
          # layout.always-center-single-output = true;
          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
            #   "Mod+Shift+Q".action = quit ;
            #   "Mod+Q".action = close-window ;
            #   "Mod+Left".action = focus-column-left;
            #   "Mod+Right".action = focus-column-right;
            "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          };
        };
      };
    };
}
