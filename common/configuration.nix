# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  # ===== IMPORTS =====
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # ===== BOOT =====
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # ===== NETWORKING =====
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # SSH port is opened per-host (see hosts/desktop/default.nix) so the
    # laptop doesn't run/expose sshd on every network it joins.
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # ===== TIME & LOCALIZATION =====
  time.timeZone = "America/Los_Angeles";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # ===== GRAPHICS & DISPLAY =====
  # Enable OpenGL
  hardware.graphics.enable = true;

  # X11 and Desktop Environment
  services.xserver = {
    enable = false; # You can disable this if you're only using the Wayland session.
    xkb = {
      layout = "us";
      variant = "";
    };
    # Enable touchpad support (enabled default in most desktopManager).
    # libinput.enable = true;
  };

  services.displayManager = {
    sddm.enable = true; # Enable the KDE Plasma Display Manager
  };
  services.desktopManager.plasma6.enable = true;

  # ===== AUDIO =====
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # ===== FONTS =====
  fonts = {
    fontconfig.enable = true;
    # Install JetBrains Mono system-wide
    packages = with pkgs; [
      jetbrains-mono
      # For Nerd Font icons, use the patched variant instead:
      # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    # Optionally set as the default monospace font
    fontconfig.defaultFonts = {
      monospace = [ "JetBrains Mono" ];
    };
  };

  # ===== USERS =====
  users.users.kevin = {
    isNormalUser = true;
    description = "Kevin Joseph";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev" # debug probes, also over SSH where uaccess doesn't apply
    ];
    packages = with pkgs; [
      google-chrome
      ghostty
      htop
      fish
      ripgrep
      helix
      wget
      nil
      zellij
      jujutsu # Source control management tool
      obs-studio
    ];
    shell = pkgs.fish;
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGkl8n+Yhe6S/N0k8SKPY1bOqlIf1kG6M0NuQri5EuFw"
      ];
    };
  };

  # ===== PROGRAMS =====
  programs = {
    fish.enable = true;
    steam.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # ===== ENVIRONMENT & PACKAGES =====
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixfmt
    home-manager
    git
    usbutils
  ];

  virtualisation.docker = {
    enable = true;
  };

  # ===== SERVICES =====
  # sshd + fail2ban are host-specific now (see hosts/desktop/default.nix) so
  # the laptop doesn't listen for SSH on every network it joins.
  services.printing.enable = true; # Enable CUPS to print documents.
  services.tailscale = {
    enable = true;
    # Opens the UDP port Tailscale uses for direct peer-to-peer connections;
    # without it, traffic falls back to relaying through Tailscale's DERP servers.
    openFirewall = true;
  };
  # udev rules from probe-rs: give the logged-in user access to debug probes
  # (e.g. the micro:bit's CMSIS-DAP) without needing root.
  services.udev.packages = [ pkgs.probe-rs-tools ];
  # Those rules set GROUP="plugdev". If the group doesn't exist, udev drops the
  # whole rule line, including the TAG+="uaccess" that grants access.
  users.groups.plugdev = { };

  # ---------------------------------------------------------------------------
  # Baloo: stop baloo_file_extractor from crash-looping at login
  # ---------------------------------------------------------------------------
  # Symptom: a flood of "baloo_file_extractor crashed" drkonqi notifications
  # (and coredumps, SIGABRT) shortly after logging in to Plasma.
  #
  # Cause: kde-baloo.service (the indexer daemon, `baloo_file`) is started by
  # systemd's user manager early in the session, and it can win a race against
  # the session importing DISPLAY / WAYLAND_DISPLAY / XAUTHORITY into the user
  # manager's environment. When that happens the service runs with NO display
  # variables at all. `baloo_file` itself doesn't care, but it spawns
  # `baloo_file_extractor` in batches, and the extractor constructs a
  # QGuiApplication. Qt then tries the "xcb" and "wayland" platform plugins,
  # both fail ("could not connect to display" / "Failed to create wl_display"),
  # and Qt calls qFatal() -> abort(). baloo_file respawns the extractor
  # immediately, so it crashes dozens of times within seconds. The index itself
  # is fine; it just never makes progress on content extraction.
  #
  # Diagnosis (for the next person): `journalctl --user -u kde-baloo` shows the
  # platform plugin errors, and /proc/<MainPID of kde-baloo>/environ lacks
  # WAYLAND_DISPLAY / DISPLAY. `systemctl --user restart kde-baloo` fixes it
  # until the next unlucky login, which is why this needs a real fix.
  #
  # Fix: force Qt's "offscreen" platform plugin for this service. The extractor
  # never shows any UI (it only reads files and writes the index), so it has no
  # need for a real display, and "offscreen" initialises without one. This
  # makes the service independent of the login race entirely, and is safe even
  # when the display variables *are* present.
  #
  # Remove this if upstream KDE/nixpkgs makes baloo_file_extractor use
  # QCoreApplication (or otherwise stops requiring a display), or if the
  # session environment import is ordered before the user service starts.
  systemd.user.services.kde-baloo.environment.QT_QPA_PLATFORM = "offscreen";

  # ===== NIX CONFIGURATION =====
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ===== SYSTEM STATE VERSION =====
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # ===== HOME MANAGER =====
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      kevin = import ./home.nix;
    };
  };
}
