{ mkACI, pkgs, thin ? false, ... } @ args:
let 

in

mkACI rec {
  name = binaryPackage.name;
  binaryPackage = pkgs.go15Packages.etcd.bin;
  binary = "etcd";

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
