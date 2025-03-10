#!/bin/sh
CWD=$(pwd)
KERNEL_VAR_FILE=${CWD}/kernel-vars

apt-get remove -y libeditreadline-dev || :
apt-get install -y liblua5.3-dev || :
ACCEL_SRC=${CWD}/accel-ppp
if [ ! -d ${ACCEL_SRC} ]; then
    echo "Accel-PPP source not found"
    exit 1
fi

if [ ! -f ${KERNEL_VAR_FILE} ]; then
    echo "Kernel variable file '${KERNEL_VAR_FILE}' does not exist, run ./build_kernel.sh first"
    exit 1
fi

. ${KERNEL_VAR_FILE}
mkdir -p ${ACCEL_SRC}/build
cd ${ACCEL_SRC}/build

echo "I: Build Accel-PPP Debian package"
cmake -DBUILD_IPOE_DRIVER=TRUE \
    -DBUILD_VLAN_MON_DRIVER=TRUE \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DKDIR=${KERNEL_DIR} \
    -DLUA=5.3 \
    -DMODULES_KDIR=${KERNEL_VERSION}${KERNEL_SUFFIX} \
    -DCPACK_TYPE=Debian12 ..
make
cpack -G DEB

# rename resulting Debian package according git description
mv accel-ppp*.deb ${CWD}/accel-ppp_$(git describe --always --tags)_$(dpkg --print-architecture).deb
apt-get remove -y liblua5.3-dev libreadline-dev || :
apt-get install -y libeditreadline-dev || :
