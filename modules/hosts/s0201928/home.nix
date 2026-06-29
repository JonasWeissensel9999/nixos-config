{ self, inputs, ... }: {
  # this is the standalone config for non-NixOS systems
  flake.homeConfigurations."jonas.weissensel" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
    modules = [
      self.homeModules.joweisseModule
      {
        home.username = "jonas.weissensel";
        home.homeDirectory = "/home/jonas.weissensel";
      }
    ];
  };
  flake.homeConfigurations.joweisse = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = [
      self.homeModules.joweisseModule
      {
        home.username = "joweisse";
        home.homeDirectory = "/home/joweisse";
      }
    ];
  };

  # this is your home.nix
  flake.homeModules.joweisseModule = { pkgs, ... }: {
    imports = [
      self.homeModules.noctalia
    ];
    programs = {
      fish.enable = true;
      tmux.enable = true;
    };

    home.packages = [ pkgs.hello ];
    home.stateVersion = "26.05";

  };
}
