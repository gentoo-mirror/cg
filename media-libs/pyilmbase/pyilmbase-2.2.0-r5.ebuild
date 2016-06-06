# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/pyilmbase/pyilmbase-2.2.0.ebuild,v 0.1 2014/12/05 16:41:48 brothermechanic Exp $

EAPI=5
PYTHON_COMPAT=( python3_5 )

inherit eutils autotools flag-o-matic python-single-r1

DESCRIPTION="Python bindings for the IlmBase"
HOMEPAGE="http://openexr.com/"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-lang/python
	dev-libs/boost[python]
	media-libs/openexr
	media-libs/ilmbase
	dev-python/numpy
	dev-libs/boost-numpy
	"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/PyImath_python3.patch
	epatch "${FILESDIR}"/configure_ac_python3.patch
	epatch "${FILESDIR}"/imathnumpymodule_cpp.patch
	epatch "${FILESDIR}"/python-pyilmbase-link.patch
	eautoreconf
}

src_configure() {
	econf \
		--prefix=/usr \
		--with-boost-python-libname=boost_python-${EPYTHON#python}
}

src_install() {
	einstall -j1 || die "install failed"
}
