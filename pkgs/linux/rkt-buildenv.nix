{ mkACI, pkgs, thin ? false, ... } @ args:

mkACI rec {
  inherit pkgs;
  inherit thin;
  dnsquirks = args.dnsquirks;

  acName = "rkt-buildenv";
  acVersion = "1.0";

  packages = with pkgs; [
    bashInteractive

    automake
    coreutils
    autoconf
    m4
    gnugrep
    gnused
    gcc
    git
    gzip
    wget
    patch

    glibc.out
    glibc.static
    autoreconfHook
    gnupg1
    squashfsTools
    cpio
    tree
    intltool
    libtool
    pkgconfig
    libgcrypt
    gperf
    libcap
    libseccomp
    libzip
    eject
    iptables
    bc
    acl
    trousers
    systemd
  ];

  mounts = {
    src = "/usr/src/rkt";
  };

  env = {
    LD_LIBRARY_PATH = "";
  };

}
