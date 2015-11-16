{ pkgs ?  import ((import <nixpkgs> {}).fetchgit { 
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "6602f49495c94e8533c8b482698bcf570a8d8933";
    sha256 = "1m47xcz0vq7yrg9inrvlxfgrz3kv5jza619a86galmzwxxymysmq";
    leaveDotGit = true; }) {}
, mkACI ? import lib/mkACI.nix
}:

let 
in {
  busybox = import pkgs/linux/busybox.nix { inherit pkgs; inherit mkACI; static=false; };
  busyboxStatic = import pkgs/linux/busybox.nix { inherit pkgs; inherit mkACI; static=true; };
  etcd2 = import pkgs/linux/etcd2.nix { inherit pkgs; inherit mkACI; static=false; };
}
