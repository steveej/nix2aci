{ mkACI, pkgs, thin ? false, ... } @ args:
let
  acserver = with pkgs.goPackages; buildFromGitHub{
    rev    = "45f764ab522020a5fcaf4bbd38802bbe3169e99d";
    date   = "2016-01-27";
    owner  = "appc";
    repo   = "acserver";
    sha256 = "1w71k3ivv8fp68cgxh4kx7w590mf19dlw3hyc31bxkydaicf781r";
  };
  pkg = acserver.bin;

in mkACI rec {
  inherit pkgs;
  inherit thin;

  static = false;
  packages = [ pkg ];

  ports = { 
    srv = { protocol = "tcp"; port = 3000; };
  };
}
