{ mkACI, pkgs, thin ? false, ... } @ args:
let 
  pkg = pkgs.dovecot22;
in

mkACI rec {
  inherit pkgs;
  inherit thin;
  dnsquirks = args.dnsquirks;

  packages = [ pkg pkgs.dovecot_pigeonhole ];

  ports = {
      "imaps" = [ "tcp" "993" ];
      "sieve" = [ "tcp" "4190" ];
  };

  mounts = {
    "mail" = "/var/vmail";
    "etc-dovecot" = "/etc/dovecot";
  };

  env = {
      "LC_ALL" = "en_US.UTF-8";
      "LANG" = "en_US.UTF-8";
  };
}
