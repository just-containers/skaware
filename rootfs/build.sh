#!/usr/bin/env bash 
set -e
set -x

# make version (for skarnet)
make_version=4.1

# skarnet versions
musl_version=1.0.4
skalibs_version=2.2.1.0
execline_version=2.0.2.0
s6_version=2.1.0.1
s6_portable_utils_version=2.0.0.1

# point to make
MAKE_4x=/usr/local/bin/make

# configures /dev/random in order to disable hangs
rm /dev/random
mknod /dev/random c 1 9

# create build dir
mkdir -p /build

# install make
cd /build
curl -R -L -O http://ftp.gnu.org/gnu/make/make-${make_version}.tar.gz
tar xf make-${make_version}.tar.gz
cd make-${make_version}

./configure
make
make install

# install musl
cd /build
curl -R -L -O http://www.musl-libc.org/releases/musl-${musl_version}.tar.gz
tar xf musl-${musl_version}.tar.gz
cd musl-${musl_version}

CFLAGS="-fno-toplevel-reorder -fno-stack-protector" \
  ./configure                                       \
    --prefix=/usr/musl                              \
    --exec-prefix=/usr                              \
    --disable-shared
${MAKE_4x}
${MAKE_4x} install

# install skalibs
cd /build
curl -R -L -O http://skarnet.org/software/skalibs/skalibs-${skalibs_version}.tar.gz
tar xf skalibs-${skalibs_version}.tar.gz
cd skalibs-${skalibs_version}

CC="musl-gcc -static"  \
  ./configure          \
    --prefix=$HOME/usr \
    --disable-shared
${MAKE_4x}
${MAKE_4x} install

# install execline
cd /build
curl -R -L -O http://skarnet.org/software/execline/execline-${execline_version}.tar.gz
tar xf execline-${execline_version}.tar.gz
cd execline-${execline_version}

CC="musl-gcc -static"                     \
  ./configure                             \
    --prefix=$HOME/usr                    \
    --exec-prefix=$HOME/dist/execline/usr \
    --with-include=$HOME/usr/include      \
    --with-lib=$HOME/usr/lib/skalibs      \
    --disable-shared
${MAKE_4x}
${MAKE_4x} install

tar                                                                \
  -zcvf $HOME/dist/execline-${execline_version}-linux-amd64.tar.gz \
  -C $HOME/dist/execline                                           \
  ./

tar -zcvf $HOME/dist/execline-${execline_version}-linux-amd64.tar.gz $HOME/dist/execline

# install s6
cd /build
curl -R -L -O http://www.skarnet.org/software/s6/s6-${s6_version}.tar.gz
tar xf s6-${s6_version}.tar.gz
cd s6-${s6_version}

CC="musl-gcc -static"                     \
  ./configure                             \
    --prefix=$HOME/usr                    \
    --exec-prefix=$HOME/dist/s6/usr       \
    --with-include=$HOME/usr/include      \
    --with-lib=$HOME/usr/lib/skalibs      \
    --with-lib=$HOME/usr/lib/execline     \
    --disable-shared
${MAKE_4x}
${MAKE_4x} install

mkdir -p $HOME/dist/s6/etc
install -D -m644 $HOME/usr/etc/leapsecs.dat $HOME/dist/s6/etc/leapsecs.dat

tar                                                    \
  -zcvf $HOME/dist/s6-${s6_version}-linux-amd64.tar.gz \
  -C $HOME/dist/s6                                     \
  ./

# install s6-portable-utils
cd /build
curl -R -L -O http://skarnet.org/software/s6-portable-utils/s6-portable-utils-${s6_portable_utils_version}.tar.gz
tar xf s6-portable-utils-${s6_portable_utils_version}.tar.gz
cd s6-portable-utils-${s6_portable_utils_version}

CC="musl-gcc -static"                              \
  ./configure                                      \
    --prefix=$HOME/usr                             \
    --exec-prefix=$HOME/dist/s6-portable-utils/usr \
    --with-include=$HOME/usr/include               \
    --with-lib=$HOME/usr/lib/skalibs               \
    --disable-shared
${MAKE_4x}
${MAKE_4x} install

tar                                                                                  \
  -zcvf $HOME/dist/s6-portable-utils-${s6_portable_utils_version}-linux-amd64.tar.gz \
  -C $HOME/dist/s6-portable-utils                                                    \
  ./

# copy results
cp $HOME/dist/execline-${execline_version}-linux-amd64.tar.gz /dist
cp $HOME/dist/s6-${s6_version}-linux-amd64.tar.gz /dist
cp $HOME/dist/s6-portable-utils-${s6_portable_utils_version}-linux-amd64.tar.gz /dist
