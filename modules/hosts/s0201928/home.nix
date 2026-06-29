{ self, inputs, ... }: {
  flake.homeConfigurations.joweisse = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {system = "x86_64-linux";};
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
    programs = {
      fish.enable = true;
    };

    home.packages = [pkgs.hello];
    home.stateVersion = "26.05";
    
  };
}
