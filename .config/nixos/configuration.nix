# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Add the unstable channel as root.
  # sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
  # sudo nix-channel --update
  unstable = import <nixos-unstable>
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in
{
  imports = [
      (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "char"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Disable the X11 windowing system. We're using Wayland
  services.xserver.enable = false;

  # Enable the Hyprland Environment.
  services.displayManager.enable = true;
  programs.hyprland.enable = true;
  # Greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "alacritty";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.vscode-server = {
    enable = true;
    enableFHS = true;
  };

  # Some things just don't work without a keyring.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true; # load gnome-keyring at startup
  programs.seahorse.enable = true; # enable the graphical frontend
  services.dbus.packages = [ pkgs.seahorse ];
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable bluetooth
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kaldir = {
    isNormalUser = true;
    description = "kaldir";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };

  # OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable gvfs for nautilus.
  services.gvfs.enable = true;

  # Install various packages.
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.git = {
    enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libsecret
    python314
    nautilus
    htop
    btop
    tmux
    vim
    hyprcursor
    hyprshot
    hypridle
    rofi-wayland
    rofi-calc
    rofi-power-menu
    alacritty
    unstable.vscode-fhs
    rustup
    clang
    neofetch
    _1password-gui
    discord
    xdg-utils
    greetd.tuigreet
    swww
    wl-clipboard
    cliphist
    wtype
    waybar
    pywal16
    imagemagick
    bluez
    networkmanager
    swaynotificationcenter
    brightnessctl
    parsec-bin
    spotify
  ];

  nixpkgs.overlays = [
    (final: prev: {
      rofi-calc = prev.rofi-calc.override { rofi-unwrapped = prev.rofi-wayland-unwrapped; };
    })
  ];

  # Workaround for Rofi plugin support
  environment.variables.ROFI_PLUGIN_PATH = "${pkgs.rofi-calc}/lib/rofi";

  fonts.packages = with pkgs; [
    font-awesome
    nerdfonts
  ];

  # Open ports in the firewall. [ SSH Spotify ]
  networking.firewall.allowedTCPPorts = [ 22 57621 ];
  # Open ports in the firewall. [ Spotify ]
  networking.firewall.allowedUDPPorts = [ 5353 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
