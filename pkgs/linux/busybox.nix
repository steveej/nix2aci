{ mkACI, pkgs, thin ? false, ... } @ args:
let
  staticbb = (pkgs.busybox.override {                                                                       
        extraConfig = ''                                                                       
          CONFIG_STATIC y                                                                      
          CONFIG_INSTALL_APPLET_DONT y                                                         
          CONFIG_INSTALL_APPLET_SYMLINKS n                                                     
        '';                                                                                    
  });       
in

mkACI rec {
      thin = false;
      name = staticbb.name+"-static";
      binaryPackage = staticbb;
      binary = "busybox";
}

