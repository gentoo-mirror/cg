# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 cmake-utils eutils

DESCRIPTION="3D point cloud processing software"
HOMEPAGE="http://www.danielgm.net/cc/"
EGIT_REPO_URI="https://github.com/cloudcompare/trunk"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""


DEPEND="media-libs/glew
	sci-mathematics/cgal
	sci-libs/pcl
	dev-qt/qtcore:5
	dev-qt/qtopengl:5"

RDEPEND="${DEPEND}"

CMAKE_BUILD_TYPE=Release

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DINSTALL_QANIMATION_PLUGIN=ON
		-DINSTALL_QBLUR_PLUGIN=ON
		-DINSTALL_QBROOM_PLUGIN=ON
		-DINSTALL_QCOMPASS_PLUGIN=ON
		-DINSTALL_QDUMMY_PLUGIN=OFF
		-DINSTALL_QEDL_PLUGIN=ON
		-DINSTALL_QCSF_PLUGIN=ON
		-DINSTALL_QGMMREG_PLUGIN=ON
		-DINSTALL_QKINECT_PLUGIN=OFF
		-DINSTALL_QPCL_PLUGIN=ON
		-DINSTALL_QPCV_PLUGIN=ON
		-DINSTALL_QPHOTOSCAN_IO_PLUGIN=ON
		-DINSTALL_QPOISSON_RECON_PLUGIN=ON
		-DINSTALL_QRANSAC_SD_PLUGIN=ON
		-DINSTALL_QSRA_PLUGIN=ON
		-DINSTALL_QSSAO_PLUGIN=ON
		-DOPTION_USE_DXF_LIB=ON
		-DOPTION_USE_FBX_SDK=ON
		-DOPTION_USE_GDAL=ON
		-DOPTION_USE_LIBLAS=ON
		-DINSTALL_QHPR_PLUGIN=ON
		-DPOISSON_RECON_WITH_OPEN_MP=ON
		-DWITH_FFMPEG_SUPPORT=ON
		-DINSTALL_QFACETS_PLUGIN=ON
		-DOPTION_USE_SHAPE_LIB=ON
		-DINSTALL_QM3C2_PLUGIN=ON
		-DINSTALL_QHOUGH_NORMALS_PLUGIN=true
		-DCOMPILE_CC_CORE_LIB_WITH_CGAL=ON
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	newicon "${S}"/qCC/images/icon/cc_icon_64.png "${PN}".png
	make_desktop_entry CloudCompare
}