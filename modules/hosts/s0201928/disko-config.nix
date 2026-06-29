{ inputs, ... }: {
  imports = [
    inputs.disko.flakeModules.default
  ];

  flake.diskoConfigurations.S0201928.disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  # keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                extraFormatArgs = [ "--pbkdf argon2id" ];
                extraOpenArgs = [ "--timeout 10" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "ssd"
                        "compress=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                        "discard=async"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "ssd"
                        "compress=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                        "discard=async"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "ssd"
                        "compress=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                        "discard=async"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "20G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
