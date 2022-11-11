EAPI=8

inherit blender-addon

DESCRIPTION="A central repository of Blender addons"
HOMEPAGE="https://git.blender.org/gitweb/gitweb.cgi/blender-addons"
EGIT_REPO_URI="https://git.blender.org/blender-addons"

if [[ ${PV} == 9999 ]]; then
    EGIT_BRANCH="master"
    KEYWORDS=""
    MY_PV="3.5"
else
    MY_PV="$(ver_cut 1-2)"
    EGIT_BRANCH="blender-v${MY_PV}-release"
    KEYWORDS="~amd64 ~x86"
fi
SLOT=${MY_PV}

LICENSE="GPL-2"

DEPEND="${PYTHON_DEPS}"

PATCHES=(
    "${FILESDIR}/node_wrangler.patch"
)

src_install(){
    : ${GENTOO_BLENDER_ADDONS_DIR:="/usr/share/blender/$(get_blender_impl)/scripts"}
    rm -r .{git,github}
    insinto ${GENTOO_BLENDER_ADDONS_DIR}/${PN}
    doins -r "${S}"/*
    python_optimize "${ED}${GENTOO_BLENDER_ADDONS_DIR}/${PN}"
}
