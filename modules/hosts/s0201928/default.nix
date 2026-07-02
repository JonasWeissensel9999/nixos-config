{ self, inputs, ... }: {
  # this is your system configuration entry-point

  flake.nixosConfigurations.S0201928 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.mdatp.nixosModules.mdatp
      inputs.disko.nixosModules.disko
      self.diskoConfigurations.S0201928
      self.nixosModules.S0201928Module
      self.nixosModules.myHomeManager

      # applications
      self.nixosModules.noctalia
      self.nixosModules.docker
    ];
  };

}
