# kjoseph-nix

NixOS system configuration using Nix Flakes and Home Manager, managing both system-level and user-level configuration across multiple machines.

## Build Commands

```bash
# Rebuild desktop system (AMD + NVIDIA)
sudo nixos-rebuild switch --flake .#desktop

# Rebuild laptop system (Intel)
sudo nixos-rebuild switch --flake .#laptop

# Apply only Home Manager changes (no sudo needed)
home-manager switch --flake .#kevin

# Format all Nix files
nixfmt flake.nix common/*.nix hosts/**/*.nix

# Update flake inputs
nix flake update
```
