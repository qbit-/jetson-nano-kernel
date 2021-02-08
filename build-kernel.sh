#!/bin/bash

set -eu

source download-kernel.sh

pushd workdir

# copy usb firmware
USB_FIRMWARE="tegra21x_xusb_firmware"
cp "/lib/firmware/${USB_FIRMWARE}" ${KERNEL_DIR}/firmware/

echo "Configuring kernel"
make -C ${KERNEL_DIR} ARCH=arm64 O=${TEGRA_KERNEL_OUT} tegra_defconfig
make -C ${KERNEL_DIR} ARCH=arm64 O=${TEGRA_KERNEL_OUT} menuconfig

echo "Adding USB firmware to kernel"
bash ${KERNEL_DIR}/scripts/config \
	--file "${TEGRA_KERNEL_OUT}/.config" \
	--set-str LOCALVERSION ${KERNEL_LOCALVERSION} \
	--set-str CONFIG_EXTRA_FIRMWARE "${USB_FIRMWARE}" \
	--set-str CONFIG_EXTRA_FIRMWARE_DIR "firmware"

echo "Making kernel"
make -C ${KERNEL_DIR} -j$(( $(nproc) + 1 )) ARCH=arm64 O=${TEGRA_KERNEL_OUT}

popd
