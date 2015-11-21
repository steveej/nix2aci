{ mkACI
, pkgs
, thin ? false
, ... }
@ args:

let
  pkg = pkgs.qemu;
in

mkACI rec {
  inherit pkgs;
  inherit thin;
  packages = [ pkg ];
  versionAddon = "";
  exec = ''/bin/qemu-kvm -- \
    -spice port=5101,addr=ipv4 \
    -vnc :0 \
    -boot reboot-timeout=60 \
  '';

  labels = {
    "os"="linux";
    "arch"="amd64";
  };

  ports = {
    "spice" = [ "tcp" "5101" ];
    "vnc" = [ "tcp" "5900" ];
  };
}

