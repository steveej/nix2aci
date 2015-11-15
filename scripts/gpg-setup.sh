#!/usr/bin/env bash
set -xe

GPG_HOMEDIR=/etc/gpg2

mkdir -p $GPG_HOMEDIR
chown root:nixbld -R $GPG_HOMEDIR
chmod 700 $GPG_HOMEDIR
pushd $GPG_HOMEDIR

BATCH=$GPG_HOMEDIR/gpg.batch
cat > ${BATCH} <<EOF
%echo Generating a default key
Key-Type: RSA 
Key-Length: 2048
Subkey-Type: RSA 
Subkey-Length: 2048
Name-Real: Your Name
Name-Comment: Nix Signing Key
Name-Email: your.name@your.tld
Expire-Date: 0
%pubring pubring.gpg
%secring secring.gpg
%commit
%echo done
EOF


gpg2 --homedir=$GPG_HOMEDIR --batch --gen-key ${BATCH}
gpg2 --homedir=$GPG_HOMEDIR --list-keys
gpg2 --homedir=$GPG_HOMEDIR --export --output $GPG_HOMEDIR/pubring.gpg.armor
gpg2 --homedir=$GPG_HOMEDIR --armor --export --output $GPG_HOMEDIR/pubring.gpg.armor
popd


chmod 770 $GPG_HOMEDIR
chmod 750 $GPG_HOMEDIR/*
