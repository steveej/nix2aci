{ mkACI, pkgs, thin ? false, ... } @ args:
let 
  pkg = pkgs.docker;
in

mkACI rec {
  inherit pkgs;
  inherit thin;
  dnsquirks = args.dnsquirks;

  packages = [ pkg pkgs.busybox pkgs.cacert ];

  mounts = {
    libdocker = "/var/lib/docker";
    rundocker = "/var/run/docker";
  };
}
