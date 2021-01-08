EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit git-r3 python-single-r1

DESCRIPTION="A central repository of Blender addons"
HOMEPAGE="https://git.blender.org/gitweb/gitweb.cgi/blender-addons.git"
EGIT_REPO_URI="https://git.blender.org/blender-addons.git"

LICENSE="GPL-2"
SLOT="2.92"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

#PATCHES=(
#	"${FILESDIR}/gltf.patch"
#)

src_install() {
	egit_clean
    insinto /usr/share/blender/${SLOT}/scripts/${PN}/
	doins -r "${S}"/*
	python_optimize "${ED}/usr/share/blender/${SLOT}/scripts/${PN}/"
}

