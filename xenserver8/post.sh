#!/bin/sh -x
PACKER_OUTPUT=output-${SOURCE:-qemu}/packer-${SOURCE:-qemu}

TMP_DIR=$(mktemp -d /tmp/packer-maas-XXXX)

ROOT_DIR="${TMP_DIR}/root"

qemu-nbd --socket="${TMP_DIR}"/qemu-img.sock \
    --format="${IMG_FMT}" \
    --shared=10 \
    "${PACKER_OUTPUT}" &
sleep 5

mkdir -pv "${ROOT_DIR}"

DEV=${TMP_DIR}/p1

mkdir -pv "${DEV}"

nbdfuse "${DEV}" \
    --command nbdkit -s nbd \
    socket="${TMP_DIR}"/qemu-img.sock \
    --filter=partition partition="1" &

retries=0
until [ -f "${DEV}/nbd" ]; do
    sleep 1
    if ((++retries > 10)); then
        return 1
    fi
done

echo "Mounting ${DEV}/nbd under ${ROOT_DIR}..."
fuse2fs "${DEV}"/nbd "${ROOT_DIR}" -o fakeroot

echo 'Adding curtin-hooks to image...'
cp -rv curtin "$ROOT_DIR"
sync

echo "Unmount and Clean-up $ROOT_DIR..."
umount $DEV/nbd
sleep 3
umount $DEV
rm -rv $ROOT_DIR
echo 'Done'
