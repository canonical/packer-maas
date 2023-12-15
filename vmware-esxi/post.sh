#!/bin/sh -x

BOOT_DIR="${TMP_DIR:?}"/boot

echo 'Adding curtin-hooks to image...'
mount_part 1 "$BOOT_DIR" fusefat
cp -rv curtin "$BOOT_DIR"

echo 'Adding post-install scripts to image...'
cp -v scripts.tar.xz "$BOOT_DIR"/curtin/

echo 'Done'
