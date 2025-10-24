{ config, pkgs, ... }:

{
  home.username = "michael";
  home.homeDirectory = "/home/michael";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
/*
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };
*/

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
/*
    syntaxHighlighting.enable = true;
    keyMappings = # sh
      ''
        # bindkey -d # Reset to default.
        bindkey -v # Use vi key bindings.

        # bindkey "^H" autosuggest-execute
        # bindkey "^ " autosuggest-accept
        # bindkey "^Q" autosuggest-clear
        # bindkey -M vicmd "e" history-search-backward
        # bindkey -M vicmd "n" history-search-forward
        # bindkey -M vicmd "^[[A" history-search-backward # up
        # bindkey -M vicmd "^[[B" history-search-forward # down
        # bindkey -M vicmd v edit-command-line # ESC-v to edit in an external editor.
        # bindkey -M viins "^L" clear-screen
        # bindkey -M viins "^W" backward-kill-word
      '';
*/
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
        "network"
        "custom/divider"
        "backlight"
        "custom/divider"
        "pulseaudio"
        "custom/divider"
        "clock"
      ];
      "hyprland/window" = { format = "{}"; };
      "wlr/workspaces" = {
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
        all-outputs = true;
        on-click = "activate";
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
      "custom/weather" = {
        tooltip = true;
        format = "{}";
        restart-interval = 300;
        exec = "/home/roastbeefer/.cargo/bin/weather";
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
      style = pkgs.writeTextFile {
        name = "style.css";
        text = ''
          * {
            font-family: JetBrainsMono Nerd Font Mono;
          }
      '';
      };	
    }];
  };


  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    nerd-fonts.jetbrains-mono
    font-awesome

/*
    neofetch
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip
*/
    ghostty

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

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "MSkrzypietz";
    userEmail = "michael.skr97@gmail.com";
  };

  # starship - an customizable prompt for any shell
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

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
/*
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };
*/

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
