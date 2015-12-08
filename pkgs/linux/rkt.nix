{ mkACI, pkgs, thin ? false, ... } @ args:
let 
  pkg = pkgs.rkt;
in

mkACI rec {
  inherit pkgs;
  inherit thin;
  dnsquirks = args.dnsquirks;
  packages = [ pkg pkgs.openssl pkgs.iptables ];
}
