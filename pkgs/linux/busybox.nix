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
  inherit static;
  thin = false;
  packages = [ pkg pkgs.eject ];
  versionAddon = if static == true then "-static" else "";
  exec = ''/bin/busybox -- sh -c "busybox mkdir -p /sbin; /bin/busybox --install -s; sh"'';
}

