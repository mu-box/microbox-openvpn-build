#!/bin/bash

cd ~
mkdir src

echo '::group::Setup OpenVPN Build System for Windows'
cd ~/src
git clone https://github.com/OpenVPN/openvpn-build.git
cp ~/build.vars ~/src/openvpn-build/generic/build.vars
cd openvpn-build/windows-nsis
echo '::endgroup::'

echo '::group::Build OpenVPN (and Deps) for Windows (amd64)'
set -e
./build-complete --sign --sign-pkcs12=/root/codesign.p12 --sign-timestamp="http://timestamp.digicert.com/"
echo '::endgroup::'

echo '::group::Rebuild OpenVPN for Windows (amd64) Statically'
cd ~/src/openvpn-build/windows-nsis/tmp/build-x86_64/openvpn-*/src/openvpn/
x86_64-w64-mingw32-gcc \
  -I/root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/include \
  -municode \
  -UUNICODE \
  -std=gnu89 \
  -o \
  .libs/openvpn.exe \
  argv.o \
  auth_token.o \
  base64.o \
  buffer.o \
  clinat.o \
  comp.o \
  compstub.o \
  comp-lz4.o \
  crypto.o \
  crypto_openssl.o \
  crypto_mbedtls.o \
  dhcp.o \
  env_set.o \
  error.o \
  event.o \
  fdmisc.o \
  forward.o \
  fragment.o \
  gremlin.o \
  helper.o \
  httpdigest.o \
  lladdr.o \
  init.o \
  interval.o \
  list.o \
  lzo.o \
  manage.o \
  mbuf.o \
  misc.o \
  platform.o \
  console.o \
  console_builtin.o \
  console_systemd.o \
  mroute.o \
  mss.o \
  mstats.o \
  mtcp.o \
  mtu.o \
  mudp.o \
  multi.o \
  networking_iproute2.o \
  networking_sitnl.o \
  ntlm.o \
  occ.o \
  pkcs11.o \
  pkcs11_openssl.o \
  pkcs11_mbedtls.o \
  openvpn.o \
  options.o \
  otime.o \
  packet_id.o \
  perf.o \
  pf.o \
  ping.o \
  plugin.o \
  pool.o \
  proto.o \
  proxy.o \
  ps.o \
  push.o \
  reliable.o \
  route.o \
  run_command.o \
  schedule.o \
  session_id.o \
  shaper.o \
  sig.o \
  socket.o \
  socks.o \
  ssl.o \
  ssl_openssl.o \
  ssl_mbedtls.o \
  ssl_ncp.o \
  ssl_verify.o \
  ssl_verify_openssl.o \
  ssl_verify_mbedtls.o \
  status.o \
  tls_crypt.o \
  tun.o \
  vlan.o \
  win32.o \
  cryptoapi.o \
  openvpn_win32_resources.o \
  block_dns.o \
  ../../src/compat/.libs/libcompat.a \
  -L/root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/lib \
  /root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/lib/liblz4.a \
  /root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/lib/liblzo2.a \
  /root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/lib/libpkcs11-helper.a \
  /root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/lib/libssl.a \
  /root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/lib/libcrypto.a \
  -lgdi32 \
  -lws2_32 \
  -lwininet \
  -lcrypt32 \
  -liphlpapi \
  -lwinmm \
  -lfwpuclnt \
  -lrpcrt4 \
  -lncrypt \
  -lsetupapi \
  -L/root/src/openvpn-build/windows-nsis/tmp/image-x86_64/openvpn/lib
echo '::endgroup::'


# ~/src/openvpn-build/windows-nsis/tmp/build-x86_64/openvpn-*/src/openvpn/.libs/openvpn.exe