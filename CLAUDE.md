# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains a NixOS system configuration using Nix Flakes and Home Manager. It manages both system-level configuration and user-level configuration for a single user named "kevin" across multiple machines (desktop and laptop) running NixOS 25.05.

## Architecture

### Flake Structure (flake.nix)
- Entry point is `flake.nix` which defines inputs (nixpkgs unstable, home-manager) and outputs
- Two system targets: `nixosConfigurations.desktop` and `nixosConfigurations.laptop` for x86_64-linux
- Allows unfree packages globally
- Home Manager is integrated as a NixOS module, not standalone

### Directory Layout
```
.
├── flake.nix              # Flake definition with inputs and outputs
├── common/
│   ├── configuration.nix  # Shared system config (boot, networking, audio, services, users)
│   └── home.nix           # User-specific Home Manager config (dotfiles, programs, packages)
├── hosts/
│   ├── desktop/
│   │   ├── default.nix              # Desktop-specific config (NVIDIA GPU)
│   │   └── hardware-configuration.nix  # Auto-generated (DO NOT MODIFY)
│   └── laptop/
│       ├── default.nix              # Laptop-specific config
│       └── hardware-configuration.nix  # Auto-generated (DO NOT MODIFY)
```

### Host-Specific Configuration
- **Desktop** (hosts/desktop/default.nix): AMD CPU, NVIDIA GPU with open-source kernel module
- **Laptop** (hosts/laptop/default.nix): Intel CPU, no discrete GPU

### Shared System Components (common/configuration.nix)
- Desktop: KDE Plasma 6 with SDDM display manager
- Audio: PipeWire (replaces PulseAudio)
- Security: SSH with key-based auth only, fail2ban enabled
- Virtualization: Docker enabled
- Shell: Fish shell as default for user kevin

### User Configuration (common/home.nix)
- Editor: Helix (hx) configured as default with nixfmt formatter for Nix files
- VCS: Both Git and Jujutsu (jj) configured with custom Fish prompt integration
- Terminal: Ghostty terminal emulator
- Multiplexer: Zellij with Fish as default shell
- VSCode: Managed via Home Manager with Copilot, GitLens, and clangd extensions

## Common Commands

### Building and Applying Configuration
```bash
# Rebuild desktop system (requires sudo)
sudo nixos-rebuild switch --flake .#desktop

# Rebuild laptop system (requires sudo)
sudo nixos-rebuild switch --flake .#laptop

# Build without switching (test configuration)
sudo nixos-rebuild build --flake .#desktop

# Apply only Home Manager changes (no sudo needed)
home-manager switch --flake .#kevin
```

### Formatting
```bash
# Format all Nix files in repository
nixfmt flake.nix common/*.nix hosts/**/*.nix

# Format a specific file
nixfmt common/configuration.nix
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
nixos-rebuild dry-build --flake .#desktop
nixos-rebuild dry-build --flake .#laptop
```

## Development Notes

### Adding System Packages
Add to `environment.systemPackages` in common/configuration.nix for system-wide packages accessible to all users on all hosts.

### Adding User Packages
- For declarative packages: Add to `home.packages` in common/home.nix
- For user-installed packages (via nix profile): Add to `users.users.kevin.packages` in common/configuration.nix

### Adding Host-Specific Configuration
Put host-specific settings in the appropriate `hosts/<host>/default.nix` file. For example, GPU drivers, power management, or hardware-specific services.

### Adding Services
System services shared across all hosts go in common/configuration.nix under the SERVICES section. Host-specific services go in the host's `default.nix`.

### Modifying Program Configuration
Most program configurations for user kevin are managed in common/home.nix under the `programs.*` attribute set. This includes shell configs, editor settings, Git config, etc.

### Experimental Features
Flakes and nix-command are enabled system-wide (common/configuration.nix). All nix commands can use flake syntax.

### Home Manager Integration
Home Manager is integrated as a NixOS module (common/configuration.nix), not run standalone. Changes to home.nix require `sudo nixos-rebuild switch` or can be applied separately with `home-manager switch`.
