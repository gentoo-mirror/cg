# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Per-Face Texture Mapping for Production Rendering"
HOMEPAGE="https://ptex.us/"
COMMIT="ea6890e041c3889ff7cb80a8546d2a3b6b8804bf"
SRC_URI="https://github.com/wdas/ptex/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~riscv x86"
IUSE="doc static-libs"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-text/doxygen )"

RESTRICT="test mirror"

S=${WORKDIR}/${PN}-${COMMIT}

src_prepare() {
	# https://github.com/wdas/ptex/issues/41
	cat <<-EOF > version || die
	v${PV}
	EOF
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE='Release'
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}/html"
		-DPTEX_BUILD_STATIC_LIBS=$(usex static-libs)
		-DPTEX_BUILD_DOCS=$(usex doc)
	)
	cmake_src_configure
}
