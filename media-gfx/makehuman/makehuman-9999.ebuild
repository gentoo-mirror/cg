# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils mercurial

DESCRIPTION="Software for the modelling of 3D humanoid characters."
HOMEPAGE="http://www.makehuman.org/"
EHG_REPO_URI="https://bitbucket.org/MakeHuman/makehuman"
EHG_REVISION="stable"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="aqsis blender"

RDEPEND="
dev-lang/python:2.7
dev-python/pyopengl
media-libs/sdl-image
media-libs/mesa
media-libs/glew
blender? ( media-gfx/blender )
aqsis? ( media-gfx/aqsis )
"

DEPEND="${RDEPEND}"

src_prepare() {
	sed "s|^python makehuman.py "$@"|python2 makehuman.py "$@"|" -i makehuman/makehuman
}

src_install() {
	INST_DIR="${D}opt/makehuman"
	install -d -m755 $INST_DIR
	cp -r "${S}"/makehuman/* $INST_DIR
	install -d -m755 "${D}usr/bin/"
	cp -a "${FILESDIR}/makehuman_launcher.sh" "${D}usr/bin/makehuman"
	install -d -m755 "${D}usr/share/doc/makehuman"
	cp -a docs/* "${D}usr/share/doc/makehuman/"
	install -d -m755 "${D}usr/share/applications"
	cp -a "${FILESDIR}/makehuman.desktop" "${D}usr/share/applications"
	install -d -m755 "${D}usr/share/pixmaps"
	cp -a "${FILESDIR}/makehuman.png" "${D}usr/share/pixmaps/"
	if v="/usr/share/blender/*";then
	dodir $v/scripts/addons/
	cp -r "${S}"/blendertools/* "${D}"$v/scripts/addons/ || die
	fi
}
