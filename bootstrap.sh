#!/bin/sh

set -e
set -u

MANIFEST="$1"

WD="$PWD"
BUILD="$WD/build"
PREFIX="$HOME/local"

export CPPFLAGS="-I$PREFIX/include"
export LD_LIBRARY_PATH="$PREFIX/lib"
export LDFLAGS="-I$PREFIX/lib"
export PATH="$PREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:$PREFIX/share"

mkdir -p "$PREFIX"

meson_build() {
	mkdir _build
	meson --prefix="$PREFIX" --libdir="$LD_LIBRARY_PATH" _build .  
	ninja -C _build
	ninja -C _build install
}

build() {
	rm -rf "$BUILD"
	mkdir "$BUILD"
	cd "$BUILD"
	curl -L "$1" > dist.x
	tar -xf dist.x --strip-components=1
	rm dist.x
	[ -f ./configure ] || [ ! -f ./autogen.sh ] || ./autogen.sh --prefix="$PREFIX"
	if [ -f ./configure ]
	then
		./configure --prefix="$PREFIX"
		make -j2
		make install
	else #if  [ ! -f ./meson.build ]
	#then
		#atk
		meson_build
	fi
	cd "$WD"
}

for LIB in `cat "$MANIFEST"`; do
	echo
	echo '*************************************************************************************'
	echo "* Building $LIB"
	echo '*************************************************************************************'
	echo
	build "$LIB"
done

cd "$PREFIX/.."
tar cJf "$WD/deps.txz" local
ls -al "$WD/deps.txz"
