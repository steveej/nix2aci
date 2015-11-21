{ pkgs ?  import ((import <nixpkgs> {}).fetchgit { 
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "6602f49495c94e8533c8b482698bcf570a8d8933";
    sha256 = "1m47xcz0vq7yrg9inrvlxfgrz3kv5jza619a86galmzwxxymysmq";
    leaveDotGit = true; }) {}
, mkACI ? import lib/mkACI.nix
}:

let 
in {
  busybox = import pkgs/linux/busybox.nix { inherit pkgs mkACI; static=false; };
  busyboxStatic = import pkgs/linux/busybox.nix { inherit pkgs mkACI; static=true; };

  coreosIpxeServer = import pkgs/linux/coreos-ipxe-server.nix { inherit pkgs mkACI; };

  dnsmasq = import pkgs/linux/dnsmasq.nix { inherit pkgs mkACI; };
  dnsfail = import pkgs/linux/dnsfail.nix { inherit pkgs mkACI; };

  etcd2 = import pkgs/linux/etcd2.nix { inherit pkgs mkACI; };

  lighthttpd = import pkgs/linux/lighthttpd.nix { inherit pkgs mkACI; };

  qemu = import pkgs/linux/qemu.nix { inherit pkgs mkACI; };
}
