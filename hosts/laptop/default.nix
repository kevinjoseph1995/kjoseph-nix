{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/configuration.nix
  ];

  # External Samsung T7 SSD over USB
  fileSystems."/mnt/t7" = {
    device = "/dev/disk/by-uuid/ab9a7c20-ab48-43c6-9f57-1f63ad65e9ca";
    fsType = "ext4";
    options = [
      "nofail" # don't block boot if the drive is unplugged
      "x-systemd.device-timeout=5s"
      "noatime"
    ];
  };

  # The firmware advertises a TPM2 but the kernel's tpm_tis probe fails, so
  # /dev/tpm0 never appears and systemd waits out the 90s device timeout in
  # both the initrd and userspace. We don't use the TPM, so don't wait for it.
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  # Tailscale SSH: tailscaled answers SSH on the tailnet address itself, so no
  # sshd or firewall port is needed on this host.
  services.tailscale.extraSetFlags = [ "--ssh" ];

  environment.systemPackages = [
    pkgs.rclone
    pkgs.brightnessctl
  ];

  # Keep running with the lid closed; just turn the backlight off.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.acpid = {
    enable = true;
    lidEventCommands = ''
      if grep -q closed /proc/acpi/button/lid/*/state; then
        ${pkgs.brightnessctl}/bin/brightnessctl --save set 0
      else
        ${pkgs.brightnessctl}/bin/brightnessctl --restore
      fi
    '';
  };

  # Daily one-way mirror of Google Drive onto the T7.
  # Requires a one-time `rclone config` creating a remote named "gdrive".
  systemd.user.services.gdrive-sync = {
    description = "Mirror Google Drive to the T7 SSD";
    unitConfig.ConditionPathIsMountPoint = "/mnt/t7"; # skip when unplugged
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.rclone}/bin/rclone sync gdrive: /mnt/t7/gdrive \
        --drive-export-formats docx,xlsx,pptx,pdf \
        --backup-dir /mnt/t7/gdrive-deleted \
        --log-level INFO
    '';
  };

  systemd.user.timers.gdrive-sync = {
    description = "Daily Google Drive mirror to the T7 SSD";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
