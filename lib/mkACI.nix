args @ { pkgs
, packages
, pkg ? builtins.elemAt packages 0
, acName ? (builtins.parseDrvName pkg.name).name
, acVersion ? if builtins.hasAttr "version" pkg && pkg.version != "" then pkg.version else (builtins.parseDrvName pkg.name).version
, versionAddon ? ""
, arch ? builtins.replaceStrings ["x86_64"] ["amd64"] (builtins.elemAt (pkgs.stdenv.lib.strings.splitString "-" pkg.system) 0)
, os ? builtins.elemAt (pkgs.stdenv.lib.strings.splitString "-" pkg.system) 1
, thin ? false
, acLabels ? {}
, mounts ? {}
, mountsRo ? {}
, ports ? {}
, env ? {}
, exec ? null
, user ? "0"
, group ? "0"
, sign ? true
, isolators ? {}
, dnsquirks ? true
, static ? false
}:

let
  mountPoint = readOnly: name: {
     "name" = name;
     "path" = mounts.${name};
     "readOnly" = readOnly;
  };
  propertyList = (list:
    builtins.map (l: {"name" = l; "value" = list.${l}; }) (builtins.attrNames list));

  mountPoints = (builtins.map (mountPoint false) (builtins.attrNames mounts));
  mountPointsRo = (builtins.map (mountPoint true) (builtins.attrNames mountsRo));
  name = (builtins.replaceStrings ["go1.5-" "go1.4-" "-"] [ "" "" "_"] acName);
  version = (builtins.replaceStrings ["-"] ["_"] acVersion + versionAddon);
  execArgv = if (builtins.isString exec) then [exec]
    else if (builtins.isList exec) then exec
    else throw "exec should be a list, got: " + (builtins.typeOf exec);

  portProps = (builtins.map (p: {"name" = p;} // ports.${p}) (builtins.attrNames ports));

  manifest = {
    acKind = "ImageManifest";
    acVersion = "0.7.4+git";
    name = name;
    version = version;
    labels = (propertyList (acLabels // {
      os = os;
      arch = arch;
    }));
    app = {
      exec = execArgv;
      user = (toString user);
      group = (toString group);
      mountPoints = mountPoints ++ mountPointsRo;
      ports = portProps;
      isolators = (propertyList isolators);
      environment = (propertyList env);
    };
  };

  bool_to_str = b: if b then "true" else "false";
in
  pkgs.stdenv.mkDerivation rec {
  name = builtins.replaceStrings ["go1.5-" "go1.4-" "-"] [ "" "" "_"] acName;
  version = builtins.replaceStrings ["-"] ["_"] acVersion + versionAddon;

  inherit os;
  inherit arch;

  buildInputs = [ pkgs.python3 ];

  # the enclosed environment provides the content for the ACI
  customEnv = pkgs.buildEnv {
    name = name + "-env";
    paths = packages;
  };
  exportReferencesGraph = map (x: [("closure-" + baseNameOf x) x]) packages;

  acname = "${name}-${version}-${os}-${arch}";

  manifestJson = builtins.toFile "manifest" (builtins.toJSON manifest);

  phases = "buildPhase";
  buildPhase = ''
    set -x
    set -e

    # Generic Manifest information
    python3 ${./mkACI.py} \
      --thin=${bool_to_str thin} \
      --dnsquirks=${bool_to_str dnsquirks} \
      --static=${bool_to_str static} \
      $out/${acname}.aci ${manifestJson} ${customEnv} \
      ${if static == true then (builtins.elemAt packages 0) else "closure-*"}

    postProcScript=$out/postprocess.sh
    cat > $postProcScript <<EOF
    #!/usr/bin/env bash
    set -e
    script_outdir=\''${1:-ACIs/}
    mkdir -p \$script_outdir
    echo "Linking $out/${acname}.aci into \$script_outdir"
    ln -sf "$out/${acname}.aci" "\$script_outdir/"
    ${if thin == true then
    "echo \"Linking $out/${acname}.mounts into \\$script_outdir\"
    ln -sf \"$out/${acname}.mounts\" \"\\$script_outdir\""
    else ""}
    ${if sign == true then
     "gpg2 --yes --batch --armor --output \"\\$script_outdir/${acname}.aci.asc\" --detach-sig \"$out/${acname}.aci\""
     else ""}
    EOF

    chmod +x "$postProcScript"
    set +x
  '';

}
