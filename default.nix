{ pkgs ?  import ((import <nixpkgs> {}).fetchgit { 
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "16037c6df5d99d8f19a46f686a63072ab071d69b";
    sha256 = "0bn7px4vn47am8997jaqbh5xcwvc1wigahrz93q2ph3pscbpgk5s";
    leaveDotGit = true; }) {}
, mkACI ? import lib/mkACI.nix
}:

let 
in {
  acserver = import pkgs/linux/acserver.nix { inherit pkgs mkACI; static=false; };
  bash = import pkgs/linux/bash.nix { inherit pkgs mkACI; static=false; };
  busybox = import pkgs/linux/busybox.nix { inherit pkgs mkACI; static=false; };
  busyboxStatic = import pkgs/linux/busybox.nix { inherit pkgs mkACI; static=true; };
  coreosIpxeServer = import pkgs/linux/coreos-ipxe-server.nix { inherit pkgs mkACI; };
  dnsmasq = import pkgs/linux/dnsmasq.nix { inherit pkgs mkACI; };
  dnsfail = import pkgs/linux/dnsfail.nix { inherit pkgs mkACI; };
  docker = import pkgs/linux/docker.nix { inherit pkgs mkACI; dnsquirks=false; };
  etcd2 = import pkgs/linux/etcd2.nix { inherit pkgs mkACI; };
#  lighthttpd = import pkgs/linux/lighthttpd.nix { inherit pkgs mkACI; };
  pixiecore = import pkgs/linux/pixiecore.nix { inherit pkgs mkACI; static=false; };
  qemu = import pkgs/linux/qemu.nix { inherit pkgs mkACI; };
  rkt = import pkgs/linux/rkt.nix { inherit pkgs mkACI; dnsquirks=false;};
}
