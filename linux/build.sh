#!/bin/bash -e

cd ~
mkdir build
mkdir src

cd ~/src
wget https://ftp.gnu.org/gnu/glibc/glibc-2.33.tar.gz
wget https://github.com/thkukuk/libnsl/releases/download/v2.0.0/libnsl-2.0.0.tar.xz
wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz
wget https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
wget https://swupdate.openvpn.org/community/releases/openvpn-2.5.5.tar.gz

echo 'amd64 x86_64-pc-linux-gnu x86_64-linux-gnu linux-x86_64
arm64 aarch64-unknown-linux-gnu aarch64-linux-gnu linux-aarch64
s390x s390x-ibm-linux-gnu s390x-linux-gnu linux64-s390x
arm armv7-unknown-linux-gnu arm-linux-gnueabihf linux-armv4' | \
    while read arch target fsname ossl; do
        tar -xzf glibc-*.tar.gz
        cd glibc-*/
        patch -u -p 1 -i ~/glibc-arm32-static-mode.patch
        mkdir build
        cd build
        ../configure --prefix=/root/build/${arch} --host=${target} --target=${target} --enable-lock-elision=yes --enable-static-nss --disable-nscd CFLAGS="-fPIC -static -O3" \
            CC="${fsname}-gcc" CXX="${fsname}-g++" AR="${fsname}-ar" RANLIB="${fsname}-ranlib" OBJCOPY="${fsname}-objcopy" OBJDUMP="${fsname}-objdump"
        make -j 8
        make install
        cd ~/src/
        rm -r glibc-*/

        tar -xJf libnsl-*.tar.xz
        cd libnsl-*/
        ./configure --prefix=/root/build/${arch} --host=${target} --target=${target} CFLAGS="-fPIC -static -O3" \
            CC="${fsname}-gcc" CXX="${fsname}-g++" AR="${fsname}-ar" RANLIB="${fsname}-ranlib" OBJCOPY="${fsname}-objcopy" OBJDUMP="${fsname}-objdump"
        make -j 8
        make install
        cd ~/src/
        rm -r libnsl-*/

        tar -xzf openssl-*.tar.gz
        cd openssl-*/
        ./Configure --prefix=/root/build/${arch} no-dso no-asm no-shared -fPIC ${ossl}
        make -j 8 CC="${fsname}-gcc" CXX="${fsname}-g++" AR="${fsname}-ar" RANLIB="${fsname}-ranlib" OBJCOPY="${fsname}-objcopy" OBJDUMP="${fsname}-objdump"
        make install
        cd ~/src/
        rm -r openssl-*/

        tar -xzf lzo-*.tar.gz
        cd lzo-*/
        ./configure --prefix=/root/build/${arch} --host=${target} --target=${target} --enable-static --disable-debug CFLAGS="-fPIC -static -O3" \
            CC="${fsname}-gcc" CXX="${fsname}-g++" AR="${fsname}-ar" RANLIB="${fsname}-ranlib" OBJCOPY="${fsname}-objcopy" OBJDUMP="${fsname}-objdump"
        make -j 8
        make install
        cd ~/src/
        rm -r lzo-*/

        tar -xzf openvpn-*.tar.gz
        cd openvpn-*/
        ./configure --prefix=/root/build/${arch} --host=${target} --target=${target} --enable-static --disable-shared --enable-iproute2 --disable-plugins \
            --disable-plugin-down-root --disable-plugin-auth-pam CFLAGS="-fPIC -static -O3" \
            CPPFLAGS="-I/root/build/${arch}/include -I/root/build/${arch}/include/openssl" LDFLAGS="-L/root/build/${arch}/lib" \
            CC="${fsname}-gcc" CXX="${fsname}-g++" AR="${fsname}-ar" RANLIB="${fsname}-ranlib" OBJCOPY="${fsname}-objcopy" OBJDUMP="${fsname}-objdump" \
            OPENSSL_LIBS="/root/build/${arch}/lib/libssl.a /root/build/${arch}/lib/libcrypto.a /root/build/${arch}/lib/libc.a /root/build/${arch}/lib/libnsl.a /root/build/${arch}/lib/libdl.a /root/build/${arch}/lib/libpthread.a"
        make -j 8
        make install
        cd ~/src/
        rm -r openvpn-*/
    done