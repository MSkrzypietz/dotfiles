{ config, lib, pkgs, ... }:

{
  home.username = "michael";
  home.homeDirectory = "/home/michael";

  home.file.".config/hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/hypr/hyprland.conf";
  home.file.".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/ideavim/.ideavimrc";

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = let
    constants =
      ''
        source ~/.zshrc.local
        export PATH="$HOME/go/bin:$PATH"
        export EDITOR="nvim"
        alias vim="nvim"
      '';
    keyMappings =
      ''
        bindkey -d # reset to default
        bindkey -v # vi key bindings

        bindkey "^E" autosuggest-execute
        bindkey "^A" autosuggest-accept
        bindkey "^V" autosuggest-clear
      '';
    beforeCompInit = lib.mkOrder 550 ''
      ${constants}
      ${keyMappings}
    '';
  in {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    initContent = beforeCompInit;
  };

  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      mod = "dock";
      exclusive = true;
      passtrough = false;
      gtk-layer-shell = true;
      height = 0;
      modules-left = [
        "hyprland/workspaces"
        "custom/divider"
        "cpu"
        "custom/divider"
        "memory"
      ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "tray"
        "custom/divider"
        "pulseaudio"
        "custom/divider"
        "clock"
      ];
      "hyprland/window" = { format = "{}"; };
      "hyprland/workspaces" = {
        on-click = "activate";
        format = "{name}";
        format-active = "<span class='active'>{name}</span>";
        format-urgent = "{name}";
        format-empty = "{name}";
        format-occupied = "{name}";
      };
      battery = { format = "󰁹 {}%"; };
      cpu = {
        interval = 10;
        format = "󰻠 {}%";
        max-length = 10;
        on-click = "";
      };
      memory = {
        interval = 30;
        format = "  {}%";
        format-alt = " {used:0.1f}G";
        max-length = 10;
      };
      backlight = {
        format = "󰖨 {}";
        device = "acpi_video0";
      };
      tray = {
        icon-size = 13;
        tooltip = false;
        spacing = 10;
      };
      network = {
        format = "󰖩 {essid}";
        format-disconnected = "󰖪 disconnected";
      };
      clock = {
        format = " {:%H:%M   %d.%m} ";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        tooltip = false;
        format-muted = " Muted";
        on-click = "pamixer -t";
        on-scroll-up = "pamixer -i 5";
        on-scroll-down = "pamixer -d 5";
        scroll-step = 5;
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
      };
      "pulseaudio#microphone" = {
        format = "{format_source}";
        tooltip = false;
        format-source = " {volume}%";
        format-source-muted = " Muted";
        on-click = "pamixer --default-source -t";
        on-scroll-up = "pamixer --default-source -i 5";
        on-scroll-down = "pamixer --default-source -d 5";
        scroll-step = 5;
      };
      "custom/divider" = {
        format = " | ";
        interval = "once";
        tooltip = false;
      };
      "custom/endright" = {
        format = "_";
        interval = "once";
        tooltip = false;
      };
    }];
    style = ''
	* {
	  font-family: JetBrainsMono Nerd Font Mono;
	}

	#workspaces button {
	    color: #a0aec0;
	    background-color: transparent;
	    border-radius: 0;
	    padding: 5px 10px;
	    margin: 0 2px;
	}

	#workspaces button.active {
	    color: white;
	    background-color: #4299e1;
	    border-radius: 5px;
	}
    '';
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome

    go
    jetbrains.goland
    jetbrains.webstorm
    opencode

    ghostty
    nodePackages_latest.nodejs
    wrangler
    hcloud
    terraform
    bun

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
/*
    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal
*/

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

/*
    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
*/
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "MSkrzypietz";
        email = "michael.skr97@gmail.com";
      };
    };
  };

  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
