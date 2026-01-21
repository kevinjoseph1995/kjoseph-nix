# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains a NixOS system configuration using Nix Flakes and Home Manager. It manages both system-level configuration (configuration.nix) and user-level configuration (home.nix) for a single user named "kevin" on an AMD-based system with NVIDIA GPU running NixOS 25.05.

## Architecture

### Flake Structure (flake.nix:12-28)
- Entry point is `flake.nix` which defines inputs (nixpkgs unstable, home-manager) and outputs
- System target: `nixosConfigurations.nixos` for x86_64-linux
- Allows unfree packages globally
- Home Manager is integrated as a NixOS module, not standalone

### Configuration Files
- **flake.nix**: Flake definition with inputs and outputs
- **configuration.nix**: System-wide NixOS configuration (boot, networking, graphics, services, users)
- **home.nix**: User-specific Home Manager configuration (dotfiles, programs, packages)
- **hardware-configuration.nix**: Auto-generated hardware config (DO NOT MODIFY - see hardware-configuration.nix:1-2)

### Key System Components (configuration.nix)
- Desktop: KDE Plasma 6 with SDDM display manager (configuration.nix:107-113)
- Graphics: NVIDIA drivers with open-source kernel module (configuration.nix:66-93)
- Audio: PipeWire (replaces PulseAudio) (configuration.nix:118-129)
- Security: SSH with key-based auth only, fail2ban enabled (configuration.nix:205-219)
- Virtualization: Docker enabled (configuration.nix:200-202)
- Shell: Fish shell as default for user kevin (configuration.nix:167)

### User Configuration (home.nix)
- Editor: Helix (hx) configured as default with nixfmt formatter for Nix files (home.nix:62-98)
- VCS: Both Git and Jujutsu (jj) configured with custom Fish prompt integration (home.nix:115-138)
- Terminal: Ghostty terminal emulator (home.nix:172-177)
- Multiplexer: Zellij with Fish as default shell (home.nix:165-170)
- VSCode: Managed via Home Manager with Copilot, GitLens, and clangd extensions (home.nix:179-210)

## Common Commands

### Building and Applying Configuration
```bash
# Rebuild entire NixOS system (requires sudo)
sudo nixos-rebuild switch --flake .#nixos

# Build without switching (test configuration)
sudo nixos-rebuild build --flake .#nixos

# Apply only Home Manager changes (no sudo needed)
home-manager switch --flake .#kevin
```

### Formatting
```bash
# Format all Nix files in repository
nixfmt *.nix

# Format a specific file
nixfmt configuration.nix
```

### Updating Dependencies
```bash
# Update flake.lock to latest versions
nix flake update

# Update specific input (e.g., nixpkgs)
nix flake lock --update-input nixpkgs
```

### Validation and Testing
```bash
# Check flake for errors
nix flake check

# Show flake metadata and outputs
nix flake show

# Evaluate configuration without building
nixos-rebuild dry-build --flake .#nixos
```

## Development Notes

### Adding System Packages
Add to `environment.systemPackages` in configuration.nix:193-198 for system-wide packages accessible to all users.

### Adding User Packages
- For declarative packages: Add to `home.packages` in home.nix:26-33
- For user-installed packages (via nix profile): Add to `users.users.kevin.packages` in configuration.nix:155-166

### Adding Services
System services go in configuration.nix under appropriate sections (marked with ===== SERVICES ===== at configuration.nix:204).

### Modifying Program Configuration
Most program configurations for user kevin are managed in home.nix under the `programs.*` attribute set (home.nix:58-213). This includes shell configs, editor settings, Git config, etc.

### Experimental Features
Flakes and nix-command are enabled system-wide (configuration.nix:223-226). All nix commands can use flake syntax.

### Home Manager Integration
Home Manager is integrated as a NixOS module (configuration.nix:18,238-243), not run standalone. Changes to home.nix require `sudo nixos-rebuild switch` or can be applied separately with `home-manager switch`.
