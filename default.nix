{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/b69f568f4c3ebaf48a7f66b0f051d28157a61afb.tar.gz") {}
, mkACI ? import lib/mkACI.nix
}:

let
  callPackage = pkg: args: pkgs.callPackage pkg ({ inherit pkgs mkACI; dnsquirks=false; } // args);
in {
  #TODO:broken upstream# acserver = callPackage pkgs/linux/acserver.nix { };
  bash = callPackage pkgs/linux/bash.nix { };
  busybox = callPackage pkgs/linux/busybox.nix { };
  busyboxThin = callPackage pkgs/linux/busybox.nix { thin=true; };
  busyboxStatic = callPackage pkgs/linux/busybox.nix { static=true; };
  busyboxPfwd = callPackage pkgs/linux/busybox-pfwd.nix { };
  dnsmasq = callPackage pkgs/linux/dnsmasq.nix { };
  docker = callPackage pkgs/linux/docker.nix { };
  flannel = callPackage pkgs/linux/flannel.nix { };
  dovecot = callPackage pkgs/linux/dovecot.nix { };
  etcd2 = callPackage pkgs/linux/etcd2.nix { };
  getmail = callPackage pkgs/linux/getmail.nix { };
  iperf = callPackage pkgs/linux/iperf.nix { };
  #TODO package# pixiecore = callPackage pkgs/linux/pixiecore.nix { };
  qemu = callPackage pkgs/linux/qemu.nix { };
  rkt = callPackage pkgs/linux/rkt.nix { };
  rktBuildenv = callPackage pkgs/linux/rkt-buildenv.nix { };
  tcpdump = callPackage pkgs/linux/generic.nix { packages=[ pkgs.tcpdump ]; };
}
