# nix2aci
Let's use Nix' super powers to build [App Container Images](http://github.com/appc/spec)!

This project should be understood as a proof of concept until stated otherwise.
You can expect this README to be minimal but it should always contain working examples.

## Requirements
* local copy of this repository
* [nix](http://www.nixos.org/nix) plus the skills to query package names
* [appc/acbuild](https://github.com/appc/acbuild/)
* [coreos/rkt](https://github.com/coreos/rkt/)

# Building ACIs
There's more than one way to build and use ACIs with Nix, because the filesystem structure allows for side-by-side installations of almost any package. Every package (version) is stored at $NIX\_STORE identified by hash, and can be pulled into different profiles independently. These profiles could be copied, but it should also be possible to pass them on to a container in one way.

## Thin ACIs
Thin ACIs don't contain any binary files, but for the most part just the manifest file and a directory skeleton.
The manifest file specifies one host type mount per package, representing the effectively available packages for the ACI.
These mountpoints can add up to a few dozen depending on the target package, and they all have to be passed to the container runtime that consumes the ACI, supplying the correct path from the host to the package's mount.

In order to make this usable, a file that can be `cat`ed into the rkt cmdline will be generated alongside the ACI when using the build script.

### Usage
This section will surely change in the future.

```
${0} name binary-name package1 [package2 ...]
```
* *name* will be prefixed with *aci* and *mounts* and by default land in $PWD/ACIs/.
* *binary-name* is the last part of the path to the executable. A simple heuristic will hopefully find the correct exec path.
* Package list with names printed by `nix-env --query` command

### Examples

#### etcd
Let's create an etcd package from scratch using the Nix package. Find them using the [nix-env](

* Optional step for nix-shell users to make sure you have acbuild in your path. Note that acbuild package has not reached any channel yet (8 Nov 2015). It's possible to use a more recent state of the nixpkgs repository for a nix-shell session like this:
```
$ nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/master.tar.gz
```

After identifying the correct package we construct the build arguments and call rkt.
```
$ nix-env -qaP '.*etcd.*'
nixos.go14Packages.etcd     go1.4-etcd-v2.1.2
nixos.go14Packages.go-etcd  go1.4-go-etcd-9847b93
nixos.etcd                  go1.5-etcd-v2.1.2
nixos.go15Packages.etcd     go1.5-etcd-v2.1.2
nixos.go15Packages.go-etcd  go1.5-go-etcd-9847b93
nixos.netcdf                netcdf-4.3.3.1
nixos.netcdfcxx4            netcdf-cxx4-4.2.1
$ export ACI_NAME=go1.5-etcd-v2.1.2
$ ./buildThinACI ${ACI_NAME} etcd etcd
...
Setting exec command [/nix/store/w1s2crksyjfp8pzsvgpvva497zwbcjvs-user-environment/bin/etcd]
Writing ACI to ACIs/go1.5-etcd-v2.1.2.aci
Ending the build

Let's take a look around

$ ls -lh ACIs/
total 8.0K
-rw-r--r-- 1 steveej users  704 Nov  8 04:16 go1.5-etcd-v2.1.2.aci
-rw-r--r-- 1 steveej users 1.1K Nov  8 04:16 go1.5-etcd-v2.1.2.mounts

Here we have our etcd2 ACI with the size of 704 bytes,
the mounts file seems to have more content. Now run it with rkt!

$ sudo rkt run --insecure-skip-verify `cat ACIs/${ACI_NAME}.mounts` ACIs/${ACI_NAME}.aci
...
[173555.313626] etcd[4]: 2015/11/8 03:19:34 etcdserver: published {Name:default ClientURLs:[http://localhost:2379 http://localhost:4001]} to cluster 7e27652122e8b2ae
[173555.313784] etcd[4]: 2015/11/8 03:19:34 etcdserver: setting up the initial cluster version to 2.1.0
[173555.313937] etcd[4]: 2015/11/8 03:19:34 etcdserver: set the initial cluster version to 2.1.0
^]^]^]

Yay!

But don't forget to cleanup
$ unset ACI_NAME
```

#### busybox + python3.5
Let's prepare a python environment for interactive sessions.

```
$ export ACI_NAME=bbpython35
$ ./buildThinACI bbpython35 sh busybox python35
...
Adding read only mount point "etcresolvconf"="/etc/resolv.conf"
Setting exec command [/nix/store/rgwh9qa5gl1lv9b3siczy78if709cjzd-user-environment/bin/sh]
Writing ACI to ACIs/bbpython35.aci
Ending the build
$ sudo rkt run --interactive --insecure-skip-verify `cat ACIs/${ACI_NAME}.mounts` ACIs/${ACI_NAME}.aci
rkt: using image from local store for image name coreos.com/rkt/stage1-coreos:0.10.0
rkt: using image from file /home/steveej/synchronized/github/steveej/nix2aci/ACIs/bbpython35.aci
run: group "rkt" not found, will use default gid when rendering images
/ # python3.5
Python 3.5.0 (default, Jan 01 1970, 00:00:01) 
[GCC 4.9.3] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> 
^]^]^]
$ unset ACI_NAME
```

## Fat ACIs
* TBD
