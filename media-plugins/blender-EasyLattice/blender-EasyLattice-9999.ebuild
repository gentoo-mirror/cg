# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon. Create a lattice for shape editing"
HOMEPAGE="https://wiki.blender.org/index.php/Easy_Lattice_Editing_Addon"
EGIT_REPO_URI="https://bitbucket.org/kursad/blender_addons_easylattice.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/src/kk_QuickLatticeCreate.py
	fi
}
