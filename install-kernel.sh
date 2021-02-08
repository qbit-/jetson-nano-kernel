#!/bin/bash

set -eu

source set-environment.sh

pushd workdir

echo "Installing modules"
sudo make -C ${KERNEL_DIR} -j$(( $(nproc) + 1 )) ARCH=arm64 O=${TEGRA_KERNEL_OUT} modules_install

echo "Installing kernel"
sudo mv -n /boot/Image /boot/Image.orig
sudo cp "${TEGRA_KERNEL_OUT}"/arch/arm64/boot/Image /boot/
sudo cp "${TEGRA_KERNEL_OUT}"/arch/arm64/boot/dts/*.dtb /boot/
sudo cp "${TEGRA_KERNEL_OUT}"/arch/arm64/boot/dts/*.dtbo /boot/
#sudo mv -n /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf.orig
#sudo cp extlinux.conf /boot/extlinux/
