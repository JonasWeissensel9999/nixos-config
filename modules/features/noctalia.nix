{ self, inputs, ... }: {

  flake.nixosModules.noctalia = { pkgs, lib, ... }: {
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
  };

  flake.homeModules.noctalia = { pkgs, ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia;
      settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
    };
  };
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;

    };
  };
}
