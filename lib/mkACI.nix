args @ { pkgs ? import <nixpkgs> {}
, name
, binary
, binaryPackage
, version ? pkgs.lib.strings.getVersion {drv=binaryPackage;}
, additionalBuildInputs ? []
, thin ? false
, mounts ? {}
, mountsRo ? {}
, envAdd ? {}
, envRemove ? []
}:
  pkgs.stdenv.mkDerivation rec { 
  inherit name;
  inherit binary;
  inherit binaryPackage;

  # acbuild and perl are needed for the build script that procudes the ACI
  buildInputs = [ pkgs.goPackages.acbuild pkgs.perl ];

  # the enclosed environment provides the content for the ACI
  customEnv = pkgs.buildEnv {
    name = name + "-env";
    paths = [ binaryPackage ] ++ additionalBuildInputs;
  };
  requestedBuildInputs = [ binaryPackage ] ++ additionalBuildInputs;
  exportReferencesGraph = map (x: [("closure-" + baseNameOf x) x]) requestedBuildInputs;

  acbuild="acbuild --debug ";

  mountsString = builtins.foldl' (res: n: 
    res + "${acbuild} mount add ${n} ${mountsRo.${n}} --read-only\n"
  ) "" (builtins.attrNames mountsRo) +
    builtins.foldl' (res: n:
    res + "${acbuild} mount add ${n} ${mounts.${n}}\n"
  ) "" (builtins.attrNames mounts);

  envAddString = builtins.foldl' (res: n: res +
    "${acbuild} environment add ${n} ${envAdd.${n}}\n"
  ) "" (builtins.attrNames envAdd);

  envRemoveString = builtins.foldl' (res: n: res +
    "${acbuild} environment remove ${n}\n"
  ) "" envRemove;


  phases = "buildPhase";
  buildPhase = ''
    set -e

    binaryPath=`${pkgs.findutils}/bin/find -L ${binaryPackage} -regex ".*/.?bin/${binary}" -executable | head -n1`
    storePaths=$(perl ${pkgs.pathsFromGraph} closure-*)

    ${acbuild} begin
    trap "{ export EXT=$?;
    ${pkgs.findutils}/bin/find .acbuild/ -type d -exec chmod +wr {} +
    ${acbuild} end
    exit $EXT;
    }" EXIT

    # Generic Manifest information
    ${acbuild} set-name $name
    ${acbuild} label add os linux
    ${acbuild} label add arch amd64

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

    ${mountsString}
    ${envAddString}
    ${envRemoveString}

    ${acbuild} set-exec -- $binaryPath
    ${acbuild} write --overwrite $out/$name.aci
  '';

}
