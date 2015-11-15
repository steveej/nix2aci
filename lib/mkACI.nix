args @ { pkgs ? import <nixpkgs> {}
, name
, packages
, version ? pkgs.lib.strings.getVersion {drv=packages[0].name;}
, thin ? false
, labels ? {}
, mounts ? {}
, mountsRo ? {}
, ports ? {}
, env ? {}
, exec ? ""
, user ? "0"
, group ? "0"
}:
  pkgs.stdenv.mkDerivation rec { 
  inherit name;

  # acbuild and perl are needed for the build script that procudes the ACI
  buildInputs = [ pkgs.goPackages.acbuild pkgs.perl ];

  # the enclosed environment provides the content for the ACI
  customEnv = pkgs.buildEnv {
    name = name + "-env";
    paths = packages;
  };
  exportReferencesGraph = map (x: [("closure-" + baseNameOf x) x]) packages;

  acbuild="acbuild --debug ";

  labelAddString = builtins.foldl' (res: l: 
    res + "${acbuild} label add ${l} ${labels.${l}}\n"
  ) "" (builtins.attrNames labels);

  mountsString = builtins.foldl' (res: n: 
    res + "${acbuild} mount add ${n} ${mountsRo.${n}} --read-only\n"
  ) "" (builtins.attrNames mountsRo) +
    builtins.foldl' (res: n:
    res + "${acbuild} mount add ${n} ${mounts.${n}}\n"
  ) "" (builtins.attrNames mounts);

  envAddString = builtins.foldl' (res: n: res +
    "${acbuild} environment add ${n} ${env.${n}}\n"
  ) "" (builtins.attrNames env);

  portAddString = builtins.foldl' (res: p: 
    res + "${acbuild} port add ${p} ${builtins.concatStringsSep " " ports.${p}} \n"
  ) "" (builtins.attrNames ports);

  execString = if exec == null then "" else "${acbuild} set-exec ${exec}\n";


  phases = "buildPhase";
  buildPhase = ''
    set -e

    storePaths=$(perl ${pkgs.pathsFromGraph} closure-*)

    ${acbuild} begin
    trap "{ export EXT=$?;
    ${pkgs.findutils}/bin/find .acbuild/ -type d -exec chmod +wr {} +
    ${acbuild} end
    exit $EXT;
    }" EXIT

    # Generic Manifest information
    ${acbuild} set-name $name

    # The environment contians symlinks in bin/, sbin/, etc...
    # TODO: fix acbuild copy so it allows to copy this structure
    cp -a ${customEnv}/* .acbuild/currentaci/rootfs/

    mkdir -p $out
    printf "" > $out/$name.mounts

    # DNS quirks
    mkdir -p .acbuild/currentaci/rootfs/etc
    printf '127.0.0.1 localhost\n' "" >> .acbuild/currentaci/rootfs/etc/hosts
    printf '::1 localhost\n' "" >> .acbuild/currentaci/rootfs/etc/hosts

    ${if thin == true then ''
    for p in ''${storePaths}; do
      mountname=''${p//[\/\.]/} 
      mountname=''${mountname,,} 
      ${acbuild} mount add $mountname $p --read-only
      printf ' --volume=%s,kind=host,source=%s ' $mountname $p >> $out/$name.mounts
    done
    ''
    else ''
    mkdir -p .acbuild/currentaci/rootfs/nix/store/nix/store
    for p in ''${storePaths}; do
      cp -a ''${p} .acbuild/currentaci/rootfs''${p}
    done
    ''}

    ${labelAddString}
    ${mountsString}
    ${envAddString}
    ${portAddString}

    ${execString}
    ${acbuild} set-user ${user};
    ${acbuild} set-group ${group};

    ${acbuild} write --overwrite $out/$name.aci
  '';

}
