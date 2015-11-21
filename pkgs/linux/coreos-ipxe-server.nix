{ mkACI, pkgs, thin ? false, ... } @ args:
let 
  pkg = pkgs.goPackages.buildFromGitHub rec {
    version = "0.3.0";
    rev    = "v${version}";
    date   = "2014-05-11";
    owner  = "kelseyhightower";
    repo   = "coreos-ipxe-server";
    sha256 = "0divwc5zcq2zq3adacnhqzn7sx189xm6ffbbxr32rvmj826pndjl";
  };

in mkACI rec {
  inherit pkgs;
  inherit thin;

  name = pkg.name;
  packages = [ pkg.bin ];
  exec = "/bin/coreos-ipxe-server";

  labels = {
    "os"="linux";
    "arch"="amd64";
  };

  mounts = {
    "datadir" = "/opt/coreos-ipxe-server";
  };

  ports = {
    "www" = [ "tcp" "4777" ];
  };
}
