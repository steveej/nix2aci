{ mkACI
, pkgs
, thin ? false
, static ? false
, ... }
@ args:

let
  pkg = if static == true
    then
      (pkgs.busybox.override {
         enableStatic = true;
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
  inherit thin;
  packages = [ pkg pkgs.eject ];
  versionAddon = if static == true then "-pfwd-static" else "-pfwd";

  exec = [
    "/bin/busybox"
    "sh" "-c" "busybox mkdir -p /sbin; /bin/busybox --install -s; sh"
  ];

  mountsRo = {
    rslvc = "/etc/resolv.conf";
  };

  ports = {
    nc = { protocol = "tcp"; port = 1024; };
  };
}

