#!/bin/bash

set -o errexit  # abort on nonzero exit status
set -o nounset  # abort on undeclared variable
set -o pipefail # don't hide errors within pipes

make_doxygen=N
while getopts ":d" opt; do
	case "${opt}" in
	d)
		make_doxygen=Y
		;;
	\?)
		echo "Invalid option: -${OPTARG}" >&2
		usage
		exit 1
		;;

	esac
done

#|-- em-odp (repository)
#      |─ odp
#      |─ installation
#      └─ scripts
script_dir=$(readlink --canonicalize "$(dirname "$0")")
install_dir=$(dirname "${script_dir}")/installation
mkdir "${install_dir}" --parents

# Clone, build and install ODP which is needed by EM-ODP
git clone --branch master --depth 1 https://github.com/OpenDataPlane/odp.git
pushd odp
./bootstrap

odp_config_opts=(
	--prefix="${install_dir}/odp_install"
	--without-examples
	--without-tests
)
./configure "${odp_config_opts[@]}"

make -j "$(nproc)"
make install

popd

# Build and install EM-ODP
./bootstrap

em_config_opts=(
	--prefix="${install_dir}/em-odp_install"
	--with-odp-path="${install_dir}/odp_install"
	--enable-check-level=3
	--enable-esv
)

./configure "${em_config_opts[@]}"

# Make doxygen document
if [[ "${make_doxygen}" = "Y" ]]; then
	make doxygen-doc
else
	make -j "$(nproc)"
	make install
fi
