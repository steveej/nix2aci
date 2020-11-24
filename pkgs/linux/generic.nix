{ mkACI
, pkgs
, thin ? false
, static ? false
, packages ? []
, mounts ? {}
, mountsRo ? {}
, ... }
@ args:

mkACI rec {
  inherit pkgs;
  inherit static;
  inherit thin;
  inherit packages;
  inherit mounts mountsRo;
  versionAddon = if static == true then "-static" else "";

  isolators = {
      "os/linux/capabilities-retain-set" = { "set" = [ "CAP_NET_ADMIN" "CAP_SYS_ADMIN" ]; };
  };
}
