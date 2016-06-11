{ mkACI, pkgs, thin ? false, ... } @ args:
let
  pkg = pkgs.dovecot;
in

mkACI rec {
  inherit pkgs;
  inherit thin;
  dnsquirks = args.dnsquirks;

  packages = [ pkg pkgs.dovecot_pigeonhole ];

  ports = {
    imaps = { protocol = "tcp"; port = "993"; };
    sieve = { protocol = "tcp"; port = "4190"; };
  };

  mounts = {
    mail = "/var/vmail";
    etc-dovecot = "/etc/dovecot";
  };

  env = {
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
  };
}
