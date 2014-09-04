#!/bin/bash

compile_nzbget(){
    tmpdir=/tmp/tmp.$(( $RANDOM * 19318203981230 + 40 ))
    apt-get remove -y nzbget
    mkdir $tmpdir
    cd $tmpdir
    touch configure
    touch Makefile.in
    touch config.h.in
    wget -qO- $3 | tar --strip-components 1 -C $tmpdir -zxf -
    ./configure --prefix=/usr --enable-parcheck
    make -j5
    sudo checkinstall --pkgname="nzbget" \
                      --pkgversion="$1" \
                      --type=debian \
                      --backup=no \
                      --deldoc=yes \
                      --fstrans=no \
                      --default \
                      --pakdir="/tmp/nzbget-package"
    cd /
    cp /tmp/nzbget-package/nzbget*.deb /tmp/nzbget-${2}-amd64.deb
    cp /tmp/nzbget-package/nzbget*.deb /tmp/
    rm -rf $tmpdir /tmp/nzbget-package
}

compile_trunk_nzbget(){
    tmpdir=/tmp/tmp.$(( $RANDOM * 19318203981230 + 40 ))
    apt-get remove -y nzbget
    mkdir $tmpdir
    svn co https://svn.code.sf.net/p/nzbget/code/trunk $tmpdir
    cd $tmpdir
    snvRevision=$(svn info | grep "Revision" | awk '{print $2}')
    confVersion=$(grep "PACKAGE_VERSION=" ./configure | cut -d"'" -f2)
    revision="${confVersion}-r${snvRevision}"
    echo "const char* svn_version(void)\n{\n  const char* SVN_Version = \"${snvRevision}\";\n  return SVN_Version;\n}" > ./svn_version.cpp
    touch configure
    touch Makefile.in
    touch config.h.in
    ./configure --prefix=/usr --enable-parcheck
    make -j5
    sudo checkinstall --pkgname="nzbget" \
                      --pkgversion="$revision" \
                      --type=debian \
                      --backup=no \
                      --deldoc=yes \
                      --fstrans=no \
                      --default \
                      --pakdir="/tmp/nzbget-package"
    cd /
    cp /tmp/nzbget-package/nzbget*.deb /tmp/nzbget-DEVEL-amd64.deb
    cp /tmp/nzbget-package/nzbget*.deb /tmp/
    rm -rf $tmpdir /tmp/nzbget-package
}

compile_libpar2(){
    tmpdir=/tmp/tmp.$(( $RANDOM * 19318203981230 + 40 ))
    apt-get remove -y libpar2-1
    mkdir $tmpdir
    cd $tmpdir
    wget -qO- https://launchpad.net/libpar2/trunk/0.4/+download/libpar2-0.4.tar.gz | tar --strip-components 1 -C $tmpdir -zxf -
    wget -nv http://nzbget.net/files/libpar2-0.4-external-verification.patch -O $tmpdir/libpar2-0.4-external-verification.patch
    patch < libpar2-0.4-external-verification.patch
    ./configure --prefix=/usr
    make -j5
    sudo checkinstall --pkgname="libpar2-1" \
                      --pkgversion="0.4" \
                      --pkgrelease="3patched" \
                      --type=debian \
                      --backup=yes \
                      --deldoc=yes \
                      --fstrans=no \
                      --default \
                      --pakdir="/tmp"
    cd /
    rm -rf $tmpdir 
}

if [[ -n $1 ]]; then
    apt-get update -qq
    apt-get install -qy libncurses5-dev sigc++ libssl-dev libxml2-dev sigc++ build-essential checkinstall subversion
    eval "$@"
else
    program_name=`basename $0`
    echo "Usage: $program_name compile_libpar2"
    echo "Usage: $program_name compile_nzbget VERSION BRANCH URL"
    echo "Usage: $program_name compile_trunk_nzbget VERSION"
fi