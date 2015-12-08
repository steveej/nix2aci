{ mkACI, pkgs, thin ? false, ... } @ args:
let
  pixiecore = with pkgs.goPackages; buildFromGitHub{
    rev    = "b9a4006784aec6400b161a214cc16514c0f65900";
    date   = "2015-10-22";
    owner  = "danderson";
    repo   = "pixiecore";
    sha256 = "1qfhyyxfm48xhyz3cfnz5m695s3vla5zg0sh7fhribd0i949f1vv";
    buildInputs = [ net crypto ];
  };
  pkg = pixiecore.bin;

in mkACI rec {
  inherit pkgs;
  inherit thin;

  static = false;
  packages = [ pkg ];

  os="linux";
  arch="amd64";
}
