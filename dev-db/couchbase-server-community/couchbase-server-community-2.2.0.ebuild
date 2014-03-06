# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI=5
inherit eutils user

DESCRIPTION="Distributed key-value database management system"
HOMEPAGE="http://www.couchbase.com"
SRC_URI="
	amd64? ( http://packages.couchbase.com/releases/${PV}/${PN}_${PV}_x86_64.deb )
	x86? ( http://packages.couchbase.com/releases/${PV}/${PN}_${PV}_x86.deb )
"


LICENSE="COUCHBASE INC. COMMUNITY EDITION"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=sys-libs/ncurses-5[tinfo]
		>=dev-libs/libevent-1.4.13
		>=dev-libs/cyrus-sasl-2"
DEPEND="${RDEPEND}"

S=${WORKDIR}

pkg_setup() {
	enewgroup couchbase
	enewuser couchbase -1 /bin/bash /opt/couchbase couchbase
}

src_unpack() {
	ar x "${DISTDIR}"/${A}
	cd ${WORKDIR}
	tar xzf data.tar.gz
}

src_install() {
	# basic cleanup
	rm -rf opt/couchbase/etc/{couchbase_init.d,couchbase_init.d.tmpl,init.d}

	# bin install / copy
	dodir /opt/couchbase
	tar xfm opt/couchbase/lib/python/pysqlite2.tar -C opt/couchbase/lib/python || die
	cp -a opt/couchbase/* "${D}"/opt/couchbase/

	dodir /opt/couchbase/var/lib/couchbase/{data,mnesia,tmp}

	fperms o+x /opt/couchbase/lib/python/pysqlite2/
	fperms -R o+r /opt/couchbase/lib/python/pysqlite2/
	fowners -R couchbase:couchbase /opt/couchbase/

	doinitd "${FILESDIR}"/couchbase-server
	dosym /opt/couchbase/etc/logrotate.d/couchdb /etc/logrotate.d/couchdb
}