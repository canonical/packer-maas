#!/bin/sh -x

echo 'Adding curtin-hooks to image...'
mkdir -p $TMP_DIR/curtin
cp windows-curtin-hooks/curtin/* $TMP_DIR/curtin/
sync -f $TMP_DIR/curtin

echo 'Adding cloudbase to image...'
mkdir -p $TMP_DIR/'Program Files'/'Cloudbase Solutions'/Cloudbase-Init
cp -r ./cloudbase-init/* $TMP_DIR/'Program Files'/'Cloudbase Solutions'/Cloudbase-Init/
sync -f $TMP_DIR/'Program Files'