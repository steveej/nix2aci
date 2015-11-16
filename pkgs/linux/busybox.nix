{ mkACI
, pkgs
, thin ? false
, static
, ... }
@ args:

let
  pkg = if static == true
    then
      (pkgs.busybox.override {
         extraConfig = ''
           CONFIG_STATIC y
           CONFIG_INSTALL_APPLET_DONT y
           CONFIG_INSTALL_APPLET_SYMLINKS n
         '';
      })
    else pkgs.busybox;
in

mkACI rec {
  inherit pkgs;
  thin = false;
  packages = [ pkg ];
  versionAddon = if static == true then "-static" else "";
  exec = ''/bin/busybox -- sh'';

  labels = {
    "os"="linux";
    "arch"="amd64";
  };

  ports = {
    "nc" = [ "tcp" "1024" ];
  };
}

