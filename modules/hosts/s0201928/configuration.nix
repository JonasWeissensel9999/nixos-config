{ self, inputs, ... }: {
  # this is your system configuration entry-point

  flake.nixosConfigurations.S0201928 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      self.diskoConfigurations.S0201928
      self.nixosModules.S0201928Module
      self.nixosModules.myHomeManager
    ];
  };

  # this is your configuration.nix, a place where you configure your system
  # you can place it in a separate file
  flake.nixosModules.S0201928Module = { config, pkgs, lib, ... }: {


  #### BEGIN hardware-configuration.nix

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  #### END hardware-configuration.nix

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "S0201928"; # Define your hostname.

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.iwd.enable = true; # Mutually exclusive to networking.wireless.enable
  networking.networkmanager.wifi.backend = "iwd";
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
   services.pipewire = {
     enable = true;
     pulse.enable = true;
   };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
# Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;
    users.root.initialHashedPassword = "$y$j9T$3gIEKU4P2HAD4dEoMXNYj0$fcqSPr78QKYvTXb/gJP7EyVjVx.AihOfL3KKbq/h1gB";
    users.joweisse = {
      initialHashedPassword = "$y$j9T$3ciRrPbwec2/jHjzAQf9K.$AcYsxXEbTDCuSCqKerDKTg..vOZI1ZyL3r/Aze/PgHA";
      isNormalUser = true;
      extraGroups = [
        "audio"
        "docker"
        "dialout"
        "networkmanager"
        "uucp"
        "wheel"
        "video"
      ];
      shell = pkgs.fish;
      uid = 1000;
      packages = with pkgs; [
        zoom-us
        keepassxc
      ];
    };
  };
  security.rtkit.enable = true;


  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
   environment.systemPackages = with pkgs; [
     neovim 
     wget
     git
   ];

  programs = {
    firefox.enable = true;
    fish.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?



  };

}
