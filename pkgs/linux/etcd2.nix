{ mkACI, pkgs, thin ? false, ... } @ args:
let 

in

mkACI rec {
  pkg  = pkgs.go15Packages.etcd.bin;
  name = pkg.name;

  packages = [ pkg ];
  binary = "etcd";
  exec = "/bin/etcd";

  mounts = {
    "datadir" = "/var/db/etcd2";
  };

  mountsRo = {
    "resolvconf"="/etc/resolv.conf";
  };

  envAdd = {
    "ETCD_DATA_DIR"="/var/db/etcd2/";
  };
}
