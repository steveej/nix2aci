{ mkACI, pkgs, thin ? false, ... } @ args:
let
  pkg = pkgs.getmail;
in

mkACI rec {
  inherit pkgs;
  inherit thin;
  dnsquirks = args.dnsquirks;

  packages = [ pkg pkgs.busybox pkgs.msmtp pkgs.python27Packages.supervisor ];

  user = "1000";
  group = "1000";

  env = {
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
  };
}
