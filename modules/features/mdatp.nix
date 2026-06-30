{ self, inputs, ... }: {
  flake.nixosModules.nix-mdatp = { pkgs, ... }: {
    services.mdatp.enable = true;
  };
}
