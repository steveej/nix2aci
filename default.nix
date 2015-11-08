{ pkgs ? import <nixpkgs> {}
, mkACI ? import lib/mkACI.nix
}:

let 
  stdArgs = { inherit pkgs; inherit mkACI; };
in {
  busybox = import pkgs/linux/busybox.nix stdArgs // { };
  etcd2 = import pkgs/linux/etcd2.nix stdArgs // { };
}
