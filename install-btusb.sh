#!/bin/bash

set -eu

MAKEJ="make -j$(( $(nproc) + 1 ))"
BTUSB_PATCH=`pwd`/btusb.patch

source set-environment.sh

pushd workdir/${KERNEL_DIR}
# figure out install dir
KERNEL_FULLVERSION=$(make kernelversion)${KERNEL_LOCALVERSION}
INSTALL_DIR=/lib/modules/$KERNEL_FULLVERSION/kernel/drivers/bluetooth

echo "Patch"
patch -p1 -N < "${BTUSB_PATCH}" && true

echo "Configuring kernel"
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} tegra_defconfig
bash scripts/config \
        --file "${TEGRA_KERNEL_OUT}/.config" \
        --set-str LOCALVERSION ${KERNEL_LOCALVERSION}
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} prepare
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} scripts

# need to make twice (why?)
echo "Making module"
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} M=drivers/bluetooth
${MAKEJ} ARCH=arm64 O=${TEGRA_KERNEL_OUT} M=drivers/bluetooth

echo "Installing module"
sudo modprobe -r btusb
sudo cp ${TEGRA_KERNEL_OUT}/drivers/bluetooth/btusb.ko ${INSTALL_DIR}/
sudo depmod

popd

echo "Installing firmware"
pushd workdir
# download firmwares
if [[ ! -d linux-firmware ]]; then
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
fi

# install firmwares
sudo mkdir -p /lib/firmware/intel
sudo cp linux-firmware/intel/ibt* /lib/firmware/intel

popd
