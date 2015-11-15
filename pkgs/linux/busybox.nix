{ mkACI, pkgs, thin ? false, ... } @ args:
let
  staticbb = (pkgs.busybox.override {                                                                       
        extraConfig = ''                                                                       
          CONFIG_STATIC y                                                                      
          CONFIG_INSTALL_APPLET_DONT y                                                         
          CONFIG_INSTALL_APPLET_SYMLINKS n                                                     
        '';                                                                                    
  });       
  pkg = staticbb;
in

mkACI rec {
  inherit pkgs; 
  thin = false;

  name = pkg.name+"-static";
  packages = [ pkg ];
  exec = ''/bin/busybox -- nc -l -p 1024'';

  labels = {
    "os"="linux";
    "arch"="amd64";
  };

  ports = {
    "nc" = [ "tcp" "1024" ];
  };
}

