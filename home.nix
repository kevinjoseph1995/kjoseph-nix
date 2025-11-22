{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ===== USER & HOME =====
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "kevin";
  home.homeDirectory = "/home/kevin";

  # ===== HOME MANAGER VERSION =====
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes. You should not change this value
  # without reading the release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # ===== PACKAGES =====
  # Install user-scoped packages here.
  home.packages = [
    # pkgs.hello
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.grc
  ];

  # ===== FILES (DOTFILES) =====
  # Manage plain files via home.file.
  home.file = {
    # ".screenrc".source = dotfiles/screenrc;
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # ===== ENVIRONMENT VARIABLES =====
  # If you don't manage your shell with Home Manager, source hm-session-vars.sh manually.
  home.sessionVariables = {
    EDITOR = "hx";
  };

  # ===== PROGRAMS =====
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
    # Settings written as TOML. Add your preferences here.
    settings = {
      # Key mappings equivalent to Helix TOML:
      # [keys.normal."space"]
      # o = "file_picker_in_current_buffer_directory"
      keys = {
        normal = {
          "space" = {
            o = "file_picker_in_current_buffer_directory";
          };
        };
      };
      editor = {
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        auto-format = true;
        scroll-lines = 1;
      };
      theme = "gruvbox";
    };
    # Language-specific configuration.
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        }
      ];
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "gruvbox";
        src = pkgs.fishPlugins.gruvbox.src;
      }
    ];
    shellAliases = {
      gs = "git status";
      gpl = "git pull";
      grep = "rg";
    };
    shellInit = '''';
  };

  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Kevin Joseph";
        email = "kevinjoseph1995@gmail.com";
      };
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
    };
  };
}
