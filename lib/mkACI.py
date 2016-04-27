#!/usr/bin/env python
import json
import os
from optparse import OptionParser
from shutil import copyfile
import subprocess
import sys


def parse_opts():
    usage = "usage: %prog [options] file.aci manifest custom_env paths..."
    parser = OptionParser(usage=usage)
    parser.add_option("--thin", dest="thin")
    parser.add_option("--dnsquirks", dest="dnsquirks")
    parser.add_option("--static", dest="static")
    (options, args) = parser.parse_args()
    if len(args) < 3:
        sys.stderr.write("not enough arguments")
        parser.print_help()
        sys.exit(1)
    return options, args


def paths_from_graphs(graphs):
    paths = {}
    for graph in graphs:
        with open(graph) as f:
            while True:
                path = f.readline()
                if not path:
                    break
                paths[path.rstrip()] = True
                f.readline()
                count = f.readline()
                for i in range(int(count)):
                    f.readline()
    return paths.keys()


def add_mounts(manifestPath, storePaths, mountArgPath):
    with open(manifestPath) as f:
        manifest = json.load(f)
    with open(mountArgPath, "w+") as f:
        mount_points = manifest["app"]["mountPoints"]
        for path in storePaths:
            name = path.replace(".", "").replace("/", "").lower()
            mount_points.append({
                'name': name,
                'path': path,
                'readOnly': True
               })
            args = "--volume=%s,kind=host,source=%s "
            f.write(args % (name, path))
    with open(manifestPath, "w") as f:
        json.dump(manifest, f, indent=4)


def tar(file_list, archive):
    # prefix everything with rootfs except "manifest" and "rootfs" itself
    t = ['flags=rSh',
         's,^,rootfs/,',
         's,^rootfs/manifest,manifest,',
         's,^rootfs/rootfs,rootfs,']
    cmd = ["tar",
           "--create",
           "--file", archive,
           "--null",
           "--gzip",
           "-T", "-",
           "--transform", ";".join(t)]
    print("$ " + " ".join(cmd))
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    proc.communicate(input=str.encode("\0".join(file_list)))


def build_aci(aci,
              manifest,
              custom_env,
              closures,
              thin=True,
              static=False,
              dnsquirks=False):
    os.mkdir(os.path.dirname(aci))
    nixstore = []
    envfiles = []
    if static:
        storePaths = closures
    else:
        storePaths = paths_from_graphs(closures)

    for path in os.listdir(custom_env):
        if path == "etc":
            cp = ["cp", "-aL", os.path.join(custom_env, "etc"), "etc"]
            subprocess.call(cp)
        else:
            envfiles.append(path)

    copyfile(manifest, "manifest")
    if thin:
        mountArgPath = os.path.splitext(aci)[0] + ".mounts"
        add_mounts("manifest", storePaths, mountArgPath)
    else:
        nixstore.append("-C/")
        for path in storePaths:
            nixstore.append(path.rstrip()[1:])

    if dnsquirks:
        if not os.path.exists("etc"):
            os.mkdir("etc")
        with open("etc/hosts", "w+") as f:
            f.write("127.0.0.1 localhost\n::1 localhost\n")

    os.mkdir("rootfs")
    file_list = ["-C" + os.path.realpath("."), "manifest", "rootfs", "etc"]

    file_list.append("-C/")
    file_list += nixstore

    file_list.append("-C" + custom_env)
    file_list += envfiles

    tar(file_list, aci)


def main():
    options, args = parse_opts()

    def to_bool(s): return s in ["true"]

    build_aci(args[0],
              args[1],
              args[2],
              args[3:],
              thin=to_bool(options.thin),
              static=to_bool(options.static),
              dnsquirks=to_bool(options.dnsquirks))

if __name__ == "__main__":
    main()
