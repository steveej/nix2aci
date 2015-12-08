{ mkACI
, pkgs
, thin ? false
, ... }
@ args:

let
  pkg = pkgs.lighttpd;
in

mkACI rec {
  inherit pkgs;
  inherit thin;
  packages = [ pkg pkgs.php55 ];
  versionAddon = "";
  exec = ''/bin/lighthttpd'';

  ports = {
    "http" = [ "tcp" "8000" ];
    "https" = [ "tcp" "8443" ];
  };
}

