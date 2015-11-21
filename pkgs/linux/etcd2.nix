{ mkACI, pkgs, thin ? false, ... } @ args:
let 
  pkg = pkgs.go15Packages.etcd.bin;
in

mkACI rec {
  inherit pkgs;
  inherit thin;

  name = pkg.name;
  packages = [ pkg ];
  exec = "/bin/etcd";

  labels = {
    "os"="linux";
    "arch"="amd64";
  };

  mounts = {
    "datadir" = "/var/db/etcd2";
  };

  mountsRo = {
    "resolvconf"="/etc/resolv.conf";
  };

  env = {
    "ETCD_DATA_DIR"="/var/db/etcd2/";
  };
}
