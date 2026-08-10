{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    pi.url = "github:lukasl-dev/pi.nix";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, stylix, ... }@inputs:
    let
      system = "x86_64-linux";

      # Local packages, shared between the flake output and the NixOS config.
      plannotatorOverlay = final: prev: {
        plannotator = final.callPackage ./pkgs/plannotator { };
      };

      # Patch Waybar 0.15.0 to use the Lua dispatch protocol that Hyprland >= 0.54 requires.
      # Upstream fix is in master but not yet released.
      waybarLuaIpcOverlay = final: prev: {
        waybar = prev.waybar.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace src/modules/hyprland/workspace.cpp \
              --replace-fail \
                '          m_ipc.getSocket1Reply("dispatch workspace " + std::to_string(id()));' \
                '          m_ipc.getSocket1Reply("/dispatch hl.dsp.focus({ workspace = \"" + std::to_string(id()) + "\" })");' \
              --replace-fail \
                '          m_ipc.getSocket1Reply("dispatch focusworkspaceoncurrentmonitor " + std::to_string(id()));' \
                '          m_ipc.getSocket1Reply("/dispatch hl.dsp.focus({ workspace = \"" + std::to_string(id()) + "\", on_current_monitor = true })");' \
              --replace-fail \
                '          m_ipc.getSocket1Reply("dispatch workspace name:" + name());' \
                '          m_ipc.getSocket1Reply("/dispatch hl.dsp.focus({ workspace = \"name:" + name() + "\" })");' \
              --replace-fail \
                '          m_ipc.getSocket1Reply("dispatch focusworkspaceoncurrentmonitor name:" + name());' \
                '          m_ipc.getSocket1Reply("/dispatch hl.dsp.focus({ workspace = \"name:" + name() + "\", on_current_monitor = true })");' \
              --replace-fail \
                '        m_ipc.getSocket1Reply("dispatch togglespecialworkspace " + name());' \
                '        m_ipc.getSocket1Reply("/dispatch hl.dsp.workspace.toggle_special(\"" + name() + "\")");' \
              --replace-fail \
                '        m_ipc.getSocket1Reply("dispatch togglespecialworkspace");' \
                '        m_ipc.getSocket1Reply("/dispatch hl.dsp.workspace.toggle_special()");'
          '';
        });
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ plannotatorOverlay waybarLuaIpcOverlay ];
      };
    in
    {
      packages.${system}.plannotator = pkgs.plannotator;

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = [ plannotatorOverlay waybarLuaIpcOverlay ];
            }
            stylix.nixosModules.stylix
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.michael = ./home.nix;
            }
          ];
        };
      };
    };
}
