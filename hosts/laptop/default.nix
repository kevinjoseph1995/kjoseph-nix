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
}
