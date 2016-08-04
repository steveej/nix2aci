{ mkACI
, pkgs
, thin ? false
, static
, packages ? []
, ... }
@ args:

mkACI rec {
  inherit pkgs;
  inherit static;
  inherit thin;
  inherit packages;
  versionAddon = if static == true then "-static" else "";

  isolators = {
      "os/linux/capabilities-retain-set" = { "set" = [ "CAP_NET_ADMIN" "CAP_SYS_ADMIN" ]; };
  };
}
