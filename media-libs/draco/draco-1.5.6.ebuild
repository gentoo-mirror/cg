# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# FIXME:
#  * will we be able to add javascript support through emscripten library?
#    This library seems to be highly unfriendly to be installed system wide!
#  * add USD (Pixar's Universal Scene Description) support, see
#    https://github.com/PixarAnimationStudios/USD
#  * add support for Unity(3D) and Maya plugins?

# Notes:
# - We don't add USE flags for ccache and distcc, because the library builds
#   in minimal time (a few seconds)

EAPI=8

inherit cmake

DESCRIPTION="Library for compressing and decompressing 3D geometric objects"
HOMEPAGE="https://google.github.io/draco/"
SRC_URI="https://github.com/google/draco/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+compat gltf usd"

RDEPEND="
	usd? ( media-libs/openusd )
"

DEPEND="${RDEPEND}
	virtual/pkgconfig"
# Testing needs the dev-cpp/gtest source code to be available in a
# side-directory of the draco sources, therefore we restrict test for now.
RESTRICT="test mirror"
DOCS=( AUTHORS CONTRIBUTING.md README.md )

PATCHES=(
	"${FILESDIR}/draco-fix-include-cstdint.patch"
)

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		# currently only used for javascript/emscripten build
		-DBUILD_ANIMATION_ENCODING=OFF # default
		-DDRACO_GLTF_BITSTREAM=$(usex gltf)
#		-DDRACO_MAYA_PLUGIN=OFF # default
		-DBUILD_SHARED_LIBS=ON
#		-DDRACO_UNITY_PLUGIN=OFF # default (FIXME?)
		-DBUILD_USD_PLUGIN=$(usex usd) # default
		-DEMSCRIPTEN=OFF # explicitly forbid this
		-DDRACO_BACKWARDS_COMPATIBILITY=$(usex compat)
		# currently only used for javascript/emscripten build and by default
		# set to on with C/C++ build
		-DENABLE_DECODER_ATTRIBUTE_DEDUPLICATION=OFF
		-DENABLE_EXTRA_SPEED=OFF # don't use -O3 optimization
		#-DENABLE_EXTRA_WARNINGS=OFF
		-DDRACO_MESH_COMPRESSION=ON # default
		-DDRACO_POINT_CLOUD_COMPRESSION=ON # default
		-DDRACO_PREDICTIVE_EDGEBREAKER=ON # default
		-DDRACO_STANDARD_EDGEBREAKER=ON # default
		-DENABLE_TESTS=OFF
		#-DENABLE_WERROR=OFF # default
		#-DENABLE_WEXTRA=OFF # add extra compiler warnings
	)

	cmake_src_configure
}
