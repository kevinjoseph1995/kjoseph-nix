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

  # Allow specific unfree packages for Home Manager builds (needed for VS Code).
  nixpkgs.config.allowUnfree = true;

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
    ".config/jj/config.toml".text = ''
      [user]
      name = "Kevin Joseph"
      email = "kevinjoseph1995@gmail.com"
      [ui]
      color = "always"
    '';
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
          formatter.command = lib.getExe pkgs.nixfmt;
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
    interactiveShellInit = ''
      function fish_jj_prompt
          # If jj isn't installed, there's nothing we can do
          # Return 1 so the calling prompt can deal with it
          if not command -sq jj
              return 1
          end
          set -l info "$(
              jj log 2>/dev/null --no-graph --ignore-working-copy --color=always --revisions @ \
                  --template '
                      separate(" ",
                          if(conflict, label("conflict", "×")),
                      )
                  '
          )"
          or return 1
          if test -n "$info"
              printf ' %s' $info
          end
      end

      function fish_vcs_prompt --description 'Print all vcs prompts'
        fish_jj_prompt $argv
        or fish_git_prompt $argv
      end

      function fish_prompt
        # Show the current path and any detected VCS state
        set -l last_status $status
        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)
        set_color normal
        fish_vcs_prompt
        printf ' > '
        return $last_status
      end
    '';
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

  programs.ghostty = {
    enable = true;
    settings = {
      shell-integration-features = "ssh-terminfo,ssh-env";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default = {
      userSettings = {
        "workbench.colorTheme" = "Default Light Modern";
        "editor.formatOnSave" = true;
        "github.copilot.enable" = {
          "*" = true;
          "plaintext" = false;
          "markdown" = true;
          "scminput" = false;
        };
        "github.copilot.nextEditSuggestions.enabled" = false;
        "terminal.integrated.profiles.linux" = {
          "fish" = {
            "path" = "fish";
            "args" = [ ];
          };
        };
        "terminal.integrated.defaultProfile.linux" = "fish";
        "[cpp]" = {
          "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
        };
      };
      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens
        github.copilot
        llvm-vs-code-extensions.vscode-clangd
      ];
    };
  };
  programs.claude-code = {
    enable = true;
  };
}
