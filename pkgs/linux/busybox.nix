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
      labels = {
        "os"="linux";
        "arch"="amd64";
      };
      ports = {
        "nc" = [ "tcp" "1024" ];
      };
      name = staticbb.name+"-static";
      packages = [ staticbb ];
      exec = ''/bin/busybox -- nc -l -p 1024'';
}

