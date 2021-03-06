# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-utils

DESCRIPTION="OpenGL to PostScript printing library"
HOMEPAGE="http://www.geuz.org/gl2ps/"
#SRC_URI="http://geuz.org/${PN}/src/${P}.tgz"
SRC_URI="http://geuz.org/${PN}/src/${PN}-git.tgz -> ${P}-git.tgz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc png zlib"

RDEPEND="
	media-libs/freeglut
	x11-libs/libXmu
	png? ( media-libs/libpng:0= )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	doc? (
		dev-tex/tth
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexrecommended )"

S=${WORKDIR}/${PN}-git

PATCHES=( "${FILESDIR}"/${PN}-1.4.1-cmake.patch )

src_prepare() {
	cmake-utils_src_prepare
	sed '/^install.*TODO\.txt/d' -i "${S}"/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DENABLE_DOC="$(usex doc)"
		-DENABLE_PNG="$(usex png)"
		-DENABLE_ZLIB="$(usex zlib)"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	if [[ ${CHOST} == *-darwin* ]] ; then
		install_name_tool \
			-id "${EPREFIX}"/usr/$(get_libdir)/libgl2ps.dylib \
			"${D%/}${EPREFIX}"/usr/$(get_libdir)/libgl2ps.dylib || die
	fi
}
