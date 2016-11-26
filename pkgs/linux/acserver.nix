{ mkACI, pkgs, thin ? false, ... } @ args:
let
  acserver = with pkgs; stdenv.mkDerivation rec {
    date   = "2016-11-11";
    name = "acserver-"+date;
    src = fetchFromGitHub { 
      rev    = "ef1eb24de11f9c7fe74e1a91b82f34687ac13604";
      owner  = "appc";
      repo   = "acserver";
      sha256 = "0bwc3c1ax3igwva224di9izyr2wzw7nninn9m7s28z1dqwvjn7bh";
    };


    buildInputs = [ go ];
    buildPhase = ''
      export GOPATH=$src
      ./build.sh
    '';

    installPhase = ''
      mkdir -p $out/bin
      mv acserver $out/bin
    '';
  };
  pkg = acserver;

in mkACI rec {
  inherit pkgs;
  inherit thin;

  static = false;
  packages = [ pkg ];

  ports = { 
    srv = { protocol = "tcp"; port = 3000; };
  };
}
