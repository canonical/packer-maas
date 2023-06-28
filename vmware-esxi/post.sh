#!/bin/sh

echo 'Packing scripts...'
SCRIPT_DIR=$TMP_DIR/altbootbank
mkdir -p ${SCRIPT_DIR}
cp -rv maas ${SCRIPT_DIR}/
python3 -m pip install -r requirements.txt --no-compile --target ${SCRIPT_DIR}/maas
find ${SCRIPT_DIR} -name __pycache__ -type d -or -name *.so | xargs rm -rf
tar cJf $TMP_DIR/scripts.tar.xz -C ${SCRIPT_DIR} .

echo 'Adding curtin-hooks to image...'
mount_part 1 $TMP_DIR/boot fusefat
cp -rv curtin $TMP_DIR/boot/

echo 'Adding post-install scripts to image...'
cp -v $TMP_DIR/scripts.tar.xz $TMP_DIR/boot/curtin/

echo 'Unmounting image...'
sync -f $TMP_DIR/boot
fusermount -u $TMP_DIR/boot
