args @ { pkgs
, packages
, name ? (builtins.parseDrvName (builtins.elemAt packages 0).name).name
, versionAddon ? ""
, version ? pkgs.lib.strings.getVersion {name=(builtins.elemAt packages 0).name; drv=builtins.elemAt packages 0;} + versionAddon
, thin ? false
, labels ? {}
, mounts ? {}
, mountsRo ? {}
, ports ? {}
, env ? {}
, exec ? ""
, user ? "0"
, group ? "0"
, sign ? true
}:
  pkgs.stdenv.mkDerivation rec { 
  inherit name;
  inherit version;

  # acbuild and perl are needed for the build script that procudes the ACI
  buildInputs = [ pkgs.go15Packages.acbuild pkgs.perl ];

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
    set -x
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

    # DNS quirks
    mkdir -p .acbuild/currentaci/rootfs/etc
    printf '127.0.0.1 localhost\n' "" >> .acbuild/currentaci/rootfs/etc/hosts
    printf '::1 localhost\n' "" >> .acbuild/currentaci/rootfs/etc/hosts

    ${if thin == true then ''
    printf "" > $out/$name.mounts
    for p in ''${storePaths}; do
      mountname=''${p//[\/\.]/} 
      mountname=''${mountname,,} 
      ${acbuild} mount add $mountname $p --read-only
      printf ' --volume=%s,kind=host,source=%s ' $mountname $p >> $out/$name-$version.mounts
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

    ${acbuild} write --overwrite $out/$name-$version.aci

    postProcScript=$out/postprocess.sh

    cat > $postProcScript <<EOF
#!/usr/bin/env bash
script_outdir=\''${1:-ACIs/}
mkdir -p \$script_outdir
echo Linking $out/$name-$version.aci into \$script_outdir
ln -sf $out/$name-$version.aci \$script_outdir/
if [[ -e $out/$name-$version.mounts ]]; then 
  echo Linking $out/$name-$version.mounts into \$script_outdir
  ln -sf $out/$name-$version.mounts \$script_outdir;
fi
${if sign == true then "gpg2 --batch --armor --output \\$script_outdir/$name-$version.aci.asc --detach-sig $out/$name-$version.aci"
else ""}
EOF

    chmod +x $postProcScript
  '';

}
