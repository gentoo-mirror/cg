# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR=emake
PYTHON_COMPAT=( python2_7 )

inherit cmake python-utils-r1 toolchain-funcs

MY_PV="$(ver_rs "1-3" '_')"
DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="https://graphics.pixar.com/opensubdiv/docs/intro.html"
SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

# Modfied Apache-2.0 license, where section 6 has been replaced.
# See for example CMakeLists.txt for details.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda doc examples opencl openmp ptex tbb test tutorials"

RDEPEND="
	${PYTHON_DEPS}
	media-libs/glew:=
	>=media-libs/glfw-3.0.0:=
	x11-libs/libXinerama
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	opencl? ( virtual/opencl )
	ptex? ( >=media-libs/ptex-2.3.2 )
"
DEPEND="
	${RDEPEND}
	tbb? ( >=dev-cpp/tbb-4.0.0 )
"
BDEPEND="
	doc? (
		app-doc/doxygen
		dev-python/docutils
	)
	cuda? ( <sys-devel/gcc-11[cxx] )
"

S="${WORKDIR}/OpenSubdiv-${MY_PV}"

PATCHES=(
	"${FILESDIR}/${PN}-3.3.0-use-gnuinstalldirs.patch"
	"${FILESDIR}/${PN}-3.4.3-add-CUDA11-compatibility.patch"
	"${FILESDIR}/${PN}-3.4.0-0001-documentation-CMakeLists.txt-force-python2.patch"
	"${FILESDIR}/${PN}-3.4.3-install-tutorials-into-bin.patch"
)

RESTRICT="
	mirror
	!test? ( test )
"

pkg_pretend() {
#	if use cuda; then
#		[[ $(gcc-major-version) -gt 10 ]] && \
#		eerror "USE=cuda requires gcc < 11. Run gcc-config to switch your default compiler" && \
#		die "Need gcc version earlier than 10"
#	fi
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	# GLTESTS are disabled as portage is unable to open a display during test phase
	CMAKE_BUILD_TYPE="Release"
	local mycmakeargs=(
		-DGLEW_LOCATION="${EPREFIX}/usr/$(get_libdir)"
		-DGLFW_LOCATION="${EPREFIX}/usr/$(get_libdir)"
		-DNO_CLEW=ON
		-DNO_CUDA=$(usex !cuda)
		-DNO_DOC=$(usex !doc)
		-DNO_EXAMPLES=$(usex !examples)
		-DNO_GLTESTS=ON
		-DNO_OMP=$(usex !openmp)
		-DNO_OPENCL=$(usex !opencl)
		-DNO_PTEX=$(usex !ptex)
		-DNO_REGRESSION=$(usex !test)
		-DNO_TBB=$(usex !tbb)
		-DNO_TESTS=$(usex !test)
		-DNO_TUTORIALS=$(usex !tutorials)
	)

	# fails with building cuda kernels when using multiple jobs
	#export MAKEOPTS="-j1"
	cmake_src_configure
}
