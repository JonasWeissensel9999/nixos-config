{ self, inputs, ... }: {
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.git-mob = pkgs.callPackage ./_package.nix { };
    };
}
