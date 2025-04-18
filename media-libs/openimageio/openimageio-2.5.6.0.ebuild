# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FONT_PN=OpenImageIO
PYTHON_COMPAT=( python3_{10..12} )
OPENVDB_COMPAT=( {7..12} )

TEST_OIIO_IMAGE_COMMIT="aae37a54e31c0e719edcec852994d052ecf6541e"
TEST_OEXR_IMAGE_COMMIT="df16e765fee28a947244657cae3251959ae63c00"
inherit cmake flag-o-matic font python-single-r1 openvdb

DESCRIPTION="A library for reading and writing images"
HOMEPAGE="https://sites.google.com/site/openimageio/ https://github.com/OpenImageIO"
SRC_URI="https://github.com/OpenImageIO/oiio/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" test? (
	https://github.com/OpenImageIO/oiio-images/archive/${TEST_OIIO_IMAGE_COMMIT}.tar.gz -> ${PN}-oiio-test-image-${TEST_OIIO_IMAGE_COMMIT}.tar.gz
	https://github.com/AcademySoftwareFoundation/openexr-images/archive/${TEST_OEXR_IMAGE_COMMIT}.tar.gz -> ${PN}-oexr-test-image-${TEST_OEXR_IMAGE_COMMIT}.tar.gz
)"
S="${WORKDIR}/${FONT_PN}-${PV}"

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86 ~riscv"

X86_CPU_FEATURES=(
	aes:aes sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
# font install is enabled upstream
# building test enabled upstream
IUSE="
${CPU_FEATURES[@]%:*}
aom avif clang color-management +cxx17 dicom +doc ffmpeg gif heif icc jpeg2k opencv
tools openvdb png ptex +python qt5 qt6 raw rav1e tbb test +truetype wayland webp X"

REQUIRED_USE="
	aom? (
		avif
	)
	avif? (
		|| (
			aom
			rav1e
		)
	)
	tools? (
		^^ (
			qt5
			qt6
		)
	)
	openvdb? (
		${OPENVDB_REQUIRED_USE}
		tbb
	)
	python? (
		${PYTHON_REQUIRED_USE}
	)
	qt5? (
		tools
	)
	qt6? (
		tools
	)
	rav1e? (
		avif
	)
	tbb? (
		openvdb
	)
"


RESTRICT="
	mirror
	!test? ( test ) test
"

BDEPEND="
	doc? (
		app-doc/doxygen
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
"
RDEPEND="
	dev-libs/boost:=
	dev-cpp/robin-map
	dev-libs/libfmt:=
	dev-libs/pugixml:=
	>=media-libs/libheif-1.13.0:=
	media-libs/libpng:0=
	>=media-libs/libwebp-0.2.1:=
	>=dev-libs/imath-3.1.2-r4:=
	>=media-libs/opencolorio-2.1.1-r4:=
	>=media-libs/openexr-3:0=[threads]
	media-libs/tiff:=
	sys-libs/zlib:=
	virtual/jpeg:0
	dicom? ( sci-libs/dcmtk )
	ffmpeg? ( media-video/ffmpeg:= )
	gif? ( media-libs/giflib:0= )
	jpeg2k? ( >=media-libs/openjpeg-2.0:2= )
	opencv? ( media-libs/opencv:= )
	openvdb? (
		dev-cpp/tbb:=
		media-gfx/openvdb:=[${OPENVDB_SINGLE_USEDEP}]
	)
	ptex? ( media-libs/ptex:= )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-libs/boost:=[python,${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/pybind11[${PYTHON_USEDEP}]
		')
	)
	qt5? (
		media-libs/libglvnd
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtwidgets:5
	)
	qt6? (
		media-libs/libglvnd
		dev-qt/qtbase:6[gui,widgets,opengl]
	)
	raw? ( media-libs/libraw:= )
	truetype? ( media-libs/freetype:2= )
"
DEPEND="${RDEPEND}"

DOCS=( CHANGES.md CREDITS.md README.md )

QA_PRESTRIPPED="usr/lib/python.*/site-packages/.*"

pkg_pretend() {
	use qt5 && use qt6 && einfo "The \"qt5\" USE flag has no effect when the \"qt6\" USE flag is also enabled."
}

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use openvdb && openvdb_pkg_setup
}

src_prepare() {
	cmake_src_prepare
	cmake_comment_add_subdirectory src/fonts

	if use test ; then
		mkdir -p "${BUILD_DIR}"/testsuite || die
		mv "${WORKDIR}"/oiio-images-${TEST_OIIO_IMAGE_COMMIT} "${BUILD_DIR}"/testsuite/oiio-images || die
		mv "${WORKDIR}"/openexr-images-${TEST_OEXR_IMAGE_COMMIT} "${BUILD_DIR}"/testsuite/openexr-images || die
	fi
}

src_configure() {
	CMAKE_BUILD_TYPE=Release

	use openvdb && openvdb_src_configure
	# Build with SIMD support
	local cpufeature
	local mysimd=()
	for cpufeature in "${CPU_FEATURES[@]}"; do
		use "${cpufeature%:*}" && mysimd+=("${cpufeature#*:}")
	done

	# If no CPU SIMDs were used, completely disable them
	[[ -z ${mysimd} ]] && mysimd=("0")

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	# Even if there are no SIMD features selected, it seems like the code will turn on NEON support if it is available.
	use arm64 && append-flags -flax-vector-conversions

	local mycmakeargs=(
		-DOIIO_BUILD_TOOLS=$(usex tools)
		-DBUILD_TESTING=$(usex test)
		-DOIIO_BUILD_TESTS=$(usex test)
		-DOIIO_DOWNLOAD_MISSING_TESTDATA=OFF
		-DINSTALL_FONTS=OFF
		-DBUILD_DOCS=$(usex doc)
		-DVERBOSE=ON
		-DINSTALL_DOCS=$(usex doc)
		-DINSTALL_FONTS=OFF
		-DSTOP_ON_WARNING=OFF
		-DUSE_CCACHE=OFF
		-DUSE_EXTERNAL_PUGIXML=ON
		-DUSE_SIMD=$(local IFS=','; echo "${mysimd[*]}")
		-DUSE_DCMTK=$(usex dicom)
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_FREETYPE=$(usex truetype)
		-DUSE_GIF=$(usex gif)
		-DUSE_LIBRAW=$(usex raw)
		-DUSE_NUKE=OFF # not in Gentoo
		-DUSE_OPENCOLORIO=$(usex color-management)
		-DUSE_OPENCV=$(usex opencv)
		-DUSE_OPENJPEG=$(usex jpeg2k)
		-DUSE_OPENVDB=$(usex openvdb)
		-DUSE_PNG=$(usex png)
		-DUSE_PTEX=$(usex ptex)
		-DUSE_PYTHON=$(usex python)
		-DUSE_TBB=$(usex tbb)
		-DUSE_WEBP=$(usex webp)
		-DLINKSTATIC=OFF
		-Wno-dev
	)

	if use qt5 || use qt6; then
		mycmakeargs+=( -DUSE_QT=ON )
		if use qt6; then
			mycmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_Qt5=ON )
		else
			mycmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_Qt6=ON )
		fi
	else
		mycmakeargs+=( -DUSE_QT=OFF )
	fi

	use cxx17 && mycmakeargs+=(	-DCMAKE_CXX_STANDARD=17	)

	if use python; then
		mycmakeargs+=(
			-DPYTHON_VERSION=${EPYTHON#python}
			-DPYTHON_SITE_DIR=$(python_get_sitedir)
		)
	fi

	cmake_src_configure
}

src_test() {
	# TODO: investigate failures
	local myctestargs=(
		-E "(oiiotool|maketx|oiiotool-maketx|texture-crop|texture-crop.batch|texture-half|texture-half.batch|texture-uint16|texture-uint16.batch|texture-interp-bilinear|texture-interp-bilinear.batch|texture-interp-closest|texture-interp-closest.batch|texture-levels-stochaniso|texture-levels-stochaniso.batch|texture-levels-stochmip|texture-levels-stochmip.batch|texture-mip-onelevel|texture-mip-onelevel.batch|texture-mip-stochastictrilinear|texture-mip-stochastictrilinear.batch|texture-mip-stochasticaniso|texture-mip-stochasticaniso.batch|texture-uint8|texture-uint8.batch|texture-skinny|texture-skinny.batch|texture-icwrite|texture-icwrite.batch|jpeg2000-broken|openexr-damaged|openvdb-broken|texture-texture3d-broken|texture-texture3d-broken.batch|psd|ptex-broken|raw-broken|targa|tiff-depths|zfile|unit_simd|cineon|dds|openvdb.batch-broken|texture-texture3d.batch-broken|cmake-consumer|texture-udim|texture-udim2|texture-udim.batch|texture-udim2.batch)"
	)

	cmake_src_test
}

src_install() {
	cmake_src_install
	# can't use font_src_install
	# it does directory hierarchy recreation
	FONT_S=(
		"${S}/src/fonts/Droid_Sans"
		"${S}/src/fonts/Droid_Sans_Mono"
		"${S}/src/fonts/Droid_Serif"
	)
	insinto ${FONTDIR}
	for dir in "${FONT_S[@]}"; do
		doins "${dir}"/*.ttf
	done
}
