{ mkACI, pkgs, thin ? false, static ? true , ... } @ args:
let 
  pkg = pkgs.stdenv.mkDerivation rec {
    version = "0.0.1";
    name = "dnsfail";
    src = /home/steveej/src/github/steveej/hello_go/dnsfail;
    buildInputs = [ pkgs.goPackages.go ];
    installPhase = ''
      mkdir -p $out/bin
      CGO_ENABLED=0 go build -o $out/bin/dnsfail -a -tags netgo -ldflags '-w' dnsfail.go
    '';
  };

in mkACI rec {
  inherit pkgs;
  inherit thin;
  inherit static;

  name = pkg.name;
  packages = [ pkg ];
  exec = "/bin/dnsfail";

  labels = {
    "os"="linux";
    "arch"="amd64";
  };
}
