{ mkACI, pkgs, thin ? false, ... } @ args:
let 
  #pkg = pkgs.goPackages.buildFromGitHub rec {
  #  version = "0.3.0";
  #  rev    = "v${version}";
  #  date   = "2014-05-11";
  #  owner  = "kelseyhightower";
  #  repo   = "coreos-ipxe-server";
  #  sha256 = "0divwc5zcq2zq3adacnhqzn7sx189xm6ffbbxr32rvmj826pndjl";
  #};
  pkg = pkgs.stdenv.mkDerivation rec {
    version = "0.4.0";
    rev = version;
    name = "coreos-ipxe-server";
    src = /home/steveej/src/github/steveej/coreos-ipxe-server;
    buildInputs = [ pkgs.goPackages.go ];
    installPhase = ''
      mkdir -p $out/bin
      CGO_ENABLED=0 go build -o $out/bin/coreos-ipxe-server -a -tags netgo -ldflags '-w'
    '';
  };

in mkACI rec {
  inherit pkgs;
  inherit thin;

  static = true;

  packages = [ pkg ];
  exec = "/bin/coreos-ipxe-server";
  acVersion = pkg.version;

  mounts = {
    "datadir" = "/opt/coreos-ipxe-server";
  };

  ports = {
    "www" = [ "tcp" "4777" ];
  };
}
