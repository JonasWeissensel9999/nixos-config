{ self, inputs, ... }: {
  flake.nixosModules.docker = { pkgs, ... }: {
    virtualisation.docker = {
      # disable global daemon for rootless setup
      enable = false;
      storageDriver = "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
        # Optionally customize rootless Docker daemon settings
        # daemon.settings = { dns = [ "1.1.1.1" "8.8.8.8" ]; registry-mirrors = [ "https://mirror.gcr.io" ]; };
      };
    };
    # this makes me a root user, i don't want that.
    # users.users.joweisse.extraGroups = [ "docker" ];
  };
}
