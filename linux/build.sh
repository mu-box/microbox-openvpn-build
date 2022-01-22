#!/bin/bash -e

cd ~
mkdir build
mkdir src

cd ~/src
wget http://ftp.gnu.org/gnu/glibc/glibc-2.33.tar.gz
tar -xzf glibc-2.33.tar.gz
cd glibc-2.33
mkdir build
cd build
../configure --prefix=/root/build --enable-lock-elision=yes --enable-static-nss --disable-nscd CFLAGS="-fPIC -static -O3"
make -j 8
make install

cd ~/src
wget https://github.com/thkukuk/libnsl/releases/download/v2.0.0/libnsl-2.0.0.tar.xz
tar -xJf libnsl-2.0.0.tar.xz
cd libnsl-2.0.0
./configure --prefix=/root/build CFLAGS="-fPIC -static -O3"
make -j 8
make install

cd ~/src
wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz
tar -xzf openssl-1.1.1m.tar.gz
cd openssl-1.1.1m
./Configure no-dso --prefix=/root/build no-shared -fPIC linux-x86_64
make -j 8
make install

cd ~/src
wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
tar -xzf lzo-2.10.tar.gz
cd lzo-2.10
./configure --prefix=/root/build CFLAGS="-fPIC -static -O3"
make -j 8
make install

cd ~/src
wget https://swupdate.openvpn.org/community/releases/openvpn-2.5.5.tar.gz
tar -xzf openvpn-2.5.5.tar.gz
cd openvpn-2.5.5
./configure --enable-static --disable-shared --enable-iproute2 --disable-plugins --disable-plugin-down-root --prefix=/root/build --disable-plugin-auth-pam CFLAGS='-static' CPPFLAGS='-I/root/build/include -I/root/build/include/openssl' LDFLAGS='-L/root/build/lib' OPENSSL_LIBS='-lssl -lcrypto /root/build/lib/libc.a /root/build/lib/libnsl.a /root/build/lib/libdl.a /root/build/lib/libpthread.a'
make -j 8
cd src/openvpn
make openvpn
