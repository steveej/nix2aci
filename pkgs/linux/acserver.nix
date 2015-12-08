{ mkACI, pkgs, thin ? false, ... } @ args:
let
  acserver = with pkgs.goPackages; buildFromGitHub{
    rev    = "10bb6d29aaa46049f342e227f67b05c21a89ebfd";
    date   = "2015-11-07";
    owner  = "appc";
    repo   = "acserver";
    sha256 = "19fkhfyjzd59kd1fiyvlc4p9igp70h6z7kzw7pmamac792xkxpz7";
    patches = [
      (pkgs.fetchurl {
        url="https://gist.githubusercontent.com/anonymous/0de2a86354f987404f07/raw/6ad5f86ed9e472df0daacb479f94200514083a3b/-";
        sha256="1bf1h7qv8rgisw311fxkhgm8rx0l5f3b2nc9pcypqjy2fklhbrx7";
      })
    ];
  };
  pkg = acserver.bin;

in mkACI rec {
  inherit pkgs;
  inherit thin;

  static = false;
  packages = [ pkg ];
}
