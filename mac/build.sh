#!/bin/bash

cd ~
mkdir src

echo '::group::Prepare macOS Crossbuild Support'
cd ~/src
git clone https://github.com/tpoechtrager/osxcross.git
cp ~/MacOSX*.sdk.tar.xz ~/src/osxcross/tarballs/
cd osxcross
patch -u -p 1 -i ~/inject-libc++-for-sdk-11+.patch
tools/get_dependencies.sh
echo '::endgroup::'
for v in 11.1 10.11; do
    echo "::group::Build macOS ${v} Crossbuild Tools"
    SDK_VERSION=$v UNATTENDED=1 ./build.sh
    ./build_gcc.sh
    ./build_binutils.sh
    echo '::endgroup::'
done
export PATH=$PATH:/root/src/osxcross/target/bin:/root/src/osxcross/target/binutils/bin
cd ~
mkdir -p build/{amd64,arm64}

echo '::group::Get macOS Deps: OpenSSL'
cd ~/src
wget https://www.openssl.org/source/openssl-${:OPENSSL_VERSION-1.1.1m}.tar.gz
tar -xzf openssl-*.tar.gz
cd openssl-*/
echo '::endgroup::'

echo '::group::Build macOS (amd64) Deps: OpenSSL'
./Configure no-dso no-asm --prefix=/root/build/amd64 darwin64-x86_64-cc
make -j 8 CC=x86_64-apple-darwin15-gcc AR=x86_64-apple-darwin15-ar RANLIB=x86_64-apple-darwin15-ranlib
x86_64-apple-darwin15-ranlib libssl.a
x86_64-apple-darwin15-ranlib libcrypto.a
make install CC=x86_64-apple-darwin15-gcc AR=x86_64-apple-darwin15-ar RANLIB=x86_64-apple-darwin15-ranlib
make clean
echo '::endgroup::'

echo '::group::Build macOS (arm64) Deps: OpenSSL'
./Configure no-dso no-asm --prefix=/root/build/arm64 darwin64-arm64-cc
make -j 8 CC=aarch64-apple-darwin20.2-cc AR=aarch64-apple-darwin20.2-ar RANLIB=aarch64-apple-darwin20.2-ranlib
aarch64-apple-darwin20.2-ranlib libssl.a
aarch64-apple-darwin20.2-ranlib libcrypto.a
make install CC=aarch64-apple-darwin20.2-cc AR=aarch64-apple-darwin20.2-ar RANLIB=aarch64-apple-darwin20.2-ranlib
echo '::endgroup::'

echo '::group::Get macOS Deps: LZO'
cd ~/src
wget https://www.oberhumer.com/opensource/lzo/download/lzo-${LZO_VERSION:-2.10}.tar.gz
tar -xzf lzo-*.tar.gz
cd lzo-*/
echo '::endgroup::'

echo '::group::Build macOS (amd64) Deps: LZO'
CC=x86_64-apple-darwin15-gcc AR=x86_64-apple-darwin15-ar RANLIB=x86_64-apple-darwin15-ranlib ./configure --host=x86_64-apple-darwin15 --prefix=/root/build/amd64 CFLAGS="-fPIC -O3"
make -j 8
make install
make clean
echo '::endgroup::'

echo '::group::Build macOS (arm64) Deps: LZO'
CC=aarch64-apple-darwin20.2-cc AR=aarch64-apple-darwin20.2-ar RANLIB=aarch64-apple-darwin20.2-ranlib ./configure --host=aarch64-apple-darwin20.2 --prefix=/root/build/arm64 CFLAGS="-fPIC -O3"
make -j 8
make install
echo '::endgroup::'

echo '::group::Get OpenVPN Source'
cd ~/src
wget https://swupdate.openvpn.org/community/releases/openvpn-${OPENVPN_VERSION:-2.5.5}.tar.gz
tar -xzf openvpn-*.tar.gz
cd openvpn-*/
echo '::endgroup::'

echo '::group::Build OpenVPN for macOS (amd64)'
CC=x86_64-apple-darwin15-cc AR=x86_64-apple-darwin15-ar RANLIB=x86_64-apple-darwin15-ranlib ./configure --host=x86_64-apple-darwin15 --enable-shared=no --disable-plugins --disable-plugin-down-root --prefix=/root/build/amd64 --disable-plugin-auth-pam CPPFLAGS='-I/root/build/amd64/include -I/root/build/amd64/include/openssl -I/root/src/osxcross/target/SDK/MacOSX10.11.sdk/usr/include -D__APPLE_USE_RFC_3542' LDFLAGS='-L/root/build/amd64/lib'
make -j 8
make install
make clean
echo '::endgroup::'

echo '::group::Build OpenVPN for macOS (arm64)'
CC=aarch64-apple-darwin20.2-cc AR=aarch64-apple-darwin20.2-ar RANLIB=aarch64-apple-darwin20.2-ranlib ./configure --host=aarch64-apple-darwin20.2 --enable-shared=no --disable-plugins --disable-plugin-down-root --prefix=/root/build/arm64 --disable-plugin-auth-pam CPPFLAGS='-I/root/build/arm64/include -I/root/build/arm64/include/openssl -I/root/src/osxcross/target/SDK/MacOSX11.1.sdk/usr/include -D__APPLE_USE_RFC_3542' LDFLAGS='-L/root/build/arm64/lib'
make -j 8
make install
echo '::endgroup::'
