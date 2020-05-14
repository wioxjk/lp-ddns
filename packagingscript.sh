#!/usr/bin/env bash
# Based on scripts by azlux.fr


pkgname=lp-ddns

repo="wioxjk/lp-ddns"
current=$(reprepro -b /srv/repos/ list stable bashtop | head -n1 | awk '{print $3}')

if [[ ! -d /tmp/${pkgname} ]]; then
    git clone https://github.com/$repo /tmp/lp-ddns
else
    cd /tmp/${pkgname}
    git fetch
    tp=$(git pull)
fi

cd /tmp/${pkgname}
new=$(grep 'declare version=' ${pkgname} | cut -d '"' -f 2)


if [ "$current" == "$new" ]; then
    exit
fi

echo "New BASHTOP version $current -> $new"

STARTDIR="/tmp/${pkgname}/build"
DESTDIR="$STARTDIR/pkg"
OUTDIR="$STARTDIR/deb"
rm -rf "$STARTDIR"
mkdir "$STARTDIR"

install -Dm 755 "/tmp/${pkgname}/${pkgname}" "$DESTDIR/usr/local/bin/${pkgname}"

mkdir -p "$DESTDIR/DEBIAN"

cat >"$DESTDIR/DEBIAN/control"<<EOL
Source: lp-ddns
Section: custom
Priority: optional
Maintainer: Jonathan Sélea <jonathan@selea.se>
Package: ${pkgname}
Version: $new
Standard-Version: 0.2a
Architecture: all
Essential: no
Depends-On: curl bash
Homepage: https://linux.pizza
Vcs-Git: https://github.com/wioxjk/lp-ddns
Bugs: https://github.com/wioxjk/lp-ddns/issues
Description: Tool for managing Dynamic DNS toghether with FreeDNS.linux.pizza
EOL

mkdir  "$OUTDIR"
dpkg-deb --build "$DESTDIR" "$OUTDIR"
reprepro -b /srv/repos includedeb buster "$OUTDIR"/*.deb
reprepro -b /srv/repos includedeb stretch "$OUTDIR"/*.deb

rm -rf "$STARTDIR"
