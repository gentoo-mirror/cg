# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} )

inherit blender-addon

DESCRIPTION="Generates normal & height maps from image textures"
HOMEPAGE="hugotini.github.io/deepbump"
EGIT_REPO_URI="https://github.com/HugoTini/DeepBump"

LICENSE="GPL-3"
