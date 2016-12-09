{ mkACI
, pkgs
, thin ? false
, static ? false
, ... }
@ args:

let
  pkg = pkgs.bash;
  
in
mkACI rec {
  inherit pkgs;
  inherit static;
  thin = false;
  packages = [ pkg pkgs.eject pkgs.eject pkgs.httping pkgs.coreutils ];
  exec = ''/bin/sh'';
}

