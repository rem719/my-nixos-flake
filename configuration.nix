# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nix-gaming, prism-cracked, anime-games-launcher, inputs,  ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # GRUB/Systemd Bootloader. (pls for the love of god remove the grub stuff first before enabling the systemd service back)
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
  enable = true;
  efiSupport = true;
  device = "nodev";
  useOSProber = true;   # finds Windows automatically
  efiInstallAsRemovable = true;
};

  boot.loader.efi.canTouchEfiVariables = false;

  # Use latest kernel.
   boot.kernelPackages = pkgs.linuxPackages_latest;

hardware.firmware = [
  (pkgs.stdenv.mkDerivation {
    name = "hda-jack-retask";
    src = ./firmware/hda-jack-retask.fw;

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/lib/firmware
      cp $src $out/lib/firmware/hda-jack-retask.fw
    '';
  })
];

 boot.kernelParams = [
  "snd_hda_intel.patch=,hda-jack-retask.fw"
];


  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # some shenanigans for my mouse lmao
services.udev.extraRules = ''
  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", \
    ATTRS{idVendor}=="a8a4", \
    ATTRS{idProduct}=="2255", \
    MODE="0660", \
    GROUP="input"
'';


  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = false;

  # Enable the XFCE desktop environment
  services.xserver.desktopManager.xfce.enable = true;

  # Enable the WindowMaker window manager
  services.xserver.windowManager.windowmaker.enable = true; 

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."hexlyn" = {
    isNormalUser = true;
    description = "Hexlyn";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "input" ];
   
    shell = pkgs.fish;
    
     packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Steam
programs.steam = {
  enable = true;
};

  # Enable 32bit graphics for Steam
hardware.graphics = {
  enable = true;
  enable32Bit = true;
};

  # Gamemode
  programs.gamemode.enable = true;

  # fish for le tty
  programs.fish = {
  enable = true;

  interactiveShellInit = ''
    set -g fish_greeting
  '';
};

  # nix-ld
programs.nix-ld.enable = true;


  # Uses tunedppd instead of normal ass ppd
  services.power-profiles-daemon.enable = false;
  services.tuned.enable = true;

  # le experimental features
  nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];

  substituters = [
    "https://cache.nixos.org/"
    "https://attic.xuyh0120.win/lantian"
  ];

  trusted-public-keys = [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  ];
};




  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    fastfetch
    alsa-tools
    lutris
    heroic
    protonup-qt
    tuned
    os-prober
    gcc
    gnumake
    pkg-config
    autoconf
    automake
    libtool
    cmake
    ninja
    git
    python3
    file
    patch
    which
    pear-desktop
    osu-lazer-bin
    obs-studio
    ppsspp
    pcsx2
    libreoffice
    wine-staging
    winetricks
    starship
    gamemode
    ntfs3g
    unrar
    mpv
    inputs.helium-browser.packages.${system}.default
    vscode
    protonplus
    kdePackages.kgamma
    goofcord
    wezterm
    xfce4-whiskermenu-plugin
    flameshot
    android-tools
    universal-android-debloater
    scrcpy
    inputs.zen-browser.packages.${system}.default
    easyeffects
    btop
    peazip
    unzip
    windowmaker
    dockapps.AlsaMixer-app
    dockapps.wmCalClock
    dockapps.wmcube
    dockapps.wmsm-app
    dockapps.wmsystemtray
    xorg.xwininfo
    pavucontrol
    dunst
    sxhkd
    pulseaudio
    libnotify
    bpftrace
    pamixer
    flowblade
    kdePackages.kdenlive
    teams-for-linux
    kdePackages.ark
    kdePackages.dolphin
    wireshark
    ani-cli
    protontricks
    winetricks
    gh
 (callPackage ./packages/wmclock.nix {})
 (callPackage ./wmbatteries.nix {})
 (callPackage ./wmnd.nix{})
];
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

  # Flatpak
  services.flatpak.enable = true; 

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
