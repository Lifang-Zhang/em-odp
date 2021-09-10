#!/bin/bash
set -e

ODP_VERSION=master
INIT_DIRECTORY="${PWD}"
echo "${INIT_DIRECTORY}"
BUILD_DIR=$(readlink -e "$(dirname "$0")")/build

mkdir "${BUILD_DIR}" -p
pushd "${BUILD_DIR}"

# Clone and build ODP
git clone --branch "${ODP_VERSION}" --depth 1 https://github.com/OpenDataPlane/odp.git
pushd ./odp
./bootstrap

odp_config_opts=(
	--prefix="${BUILD_DIR}/odp_install"
	--without-examples
	--without-tests
)
./configure "${odp_config_opts[@]}"

make -j "$(nproc)"
make install

popd && popd

# Build and install EM-ODP
pushd "${BUILD_DIR}/../.."
./bootstrap

em_config_opts=(
	--prefix="${BUILD_DIR}/em-odp_install"
	--with-odp-path="${BUILD_DIR}/odp_install"
	--enable-check-level=3
	--enable-esv
)

./configure "${em_config_opts[@]}"

make -j "$(nproc)"
make install
#popd
