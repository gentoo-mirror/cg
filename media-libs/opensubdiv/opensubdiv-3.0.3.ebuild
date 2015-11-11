# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils eutils

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="http://graphics.pixar.com/opensubdiv"
SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v3_0_3.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda ptex"

DEPEND="media-libs/glew
	media-libs/glfw
	dev-cpp/tbb
	sys-libs/zlib
	ptex? ( media-libs/ptex )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	"
DEPEND="${RDEPEND}"
S=${WORKDIR}/OpenSubdiv-3_0_3
src_configure() {
	local mycmakeargs=""
	
	mycmakeargs="
		${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DNO_MAYA=1
		-DNO_DOC=1
		-DNO_CUDA=1
	"
	if ! use ptex ; then
			mycmakeargs+="${mycmakeargs} -DNO_PTEX=1"
	fi
	cmake-utils_src_configure
}
