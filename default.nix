{ pkgs ? import /home/steveej/synchronized/github/NixOS/nixpkgs {} }: with pkgs;

let
  mkACI = { buildInputs
            , version } @ args:
    stdenv.mkDerivation (rec { 
      # TODO?: possibly implement script over here
    } // args);
  std = stdenv.mkDerivation {
    name = "nix2go";
    buildInputs =  [
      goPackages.acbuild
    ];
  };
in rec {
  inherit std;
}
