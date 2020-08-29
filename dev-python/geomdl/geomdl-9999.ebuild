EAPI=7

PYTHON_COMPAT=( python{3_7,3_8} )
inherit git-r3 distutils-r1

DESCRIPTION="Object-oriented NURBS library in Python"
HOMEPAGE="https://onurraufbingol.com/NURBS-Python/"

LICENSE="MIT"
SLOT="0"
EGIT_REPO_URI="https://github.com/orbingol/NURBS-Python.git"
EGIT_BRANCH="5.x"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/cython[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
