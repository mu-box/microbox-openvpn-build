SHELL := /bin/bash
interactive := $(shell test -t 0 && echo yes)

.PHONY: default clean clean-linux clean-mac clean-windows linux-env mac-env windows-env linux-container mac-container windows-container publish

default: dist/windows/amd64/openvpn.exe dist/darwin/amd64/openvpn dist/darwin/arm64/openvpn dist/linux/amd64/openvpn dist/linux/arm/openvpn dist/linux/arm64/openvpn dist/linux/s390x/openvpn

clean: clean-linux clean-mac clean-windows

linux-env:
	if [[ ! $$(docker images mubox/build-openvpn-linux) =~ "mubox/build-openvpn-linux" ]]; then \
		echo '::group::Build Linux Environment'; \
		docker build --no-cache -t mubox/build-openvpn-linux -f linux/Dockerfile linux; \
		echo '::endgroup::'; \
	fi

mac-env: mac/MacOSX10.11.sdk.tar.xz mac/MacOSX11.1.sdk.tar.xz
	if [[ ! $$(docker images mubox/build-openvpn-mac) =~ "mubox/build-openvpn-mac" ]]; then \
		echo '::group::Build Mac Environment'; \
		docker build --no-cache -t mubox/build-openvpn-mac -f mac/Dockerfile mac; \
		echo '::endgroup::'; \
	fi

windows-env: windows/codesign.p12
	if [[ ! $$(docker images mubox/build-openvpn-windows) =~ "mubox/build-openvpn-windows" ]]; then \
		echo '::group::Build Windows Environment'; \
		docker build --no-cache -t mubox/build-openvpn-windows -f windows/Dockerfile windows; \
		echo '::endgroup::'; \
	fi

windows/codesign.p12: certs
	openssl pkcs12 -export -nodes -out windows/codesign.p12 -inkey certs/win/codesign.key -in certs/win/codesign.crt -passout pass:

mac/MacOSX10.11.sdk.tar.xz:
	curl -fsSL https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX10.11.sdk.tar.xz -o mac/MacOSX10.11.sdk.tar.xz

mac/MacOSX11.1.sdk.tar.xz:
	curl -fsSL https://github.com/joseluisq/MacOSX-SDKs/releases/download/11.1/MacOSX11.1.sdk.tar.xz -o mac/MacOSX11.1.sdk.tar.xz

linux-container: linux-env
	if [[ ! $$(docker ps -a) =~ "build-linux" ]]; then \
		docker run -d --name build-linux mubox/build-openvpn-linux sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-linux" ]]; then \
		docker start build-linux; \
	fi

mac-container: mac-env
	if [[ ! $$(docker ps -a) =~ "build-mac" ]]; then \
		docker run -d --name build-mac mubox/build-openvpn-mac sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-mac" ]]; then \
		docker start build-mac; \
	fi

windows-container: windows-env
	if [[ ! $$(docker ps -a) =~ "build-windows" ]]; then \
		docker run -d --name build-windows mubox/build-openvpn-windows sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-windows" ]]; then \
		docker start build-windows; \
	fi

linux-build: linux-container
	docker exec ${interactive:+-i} -t build-linux /root/build.sh

mac-build: mac-container
	docker exec ${interactive:+-i} -t build-mac /root/build.sh

windows-build: windows-container
	docker exec ${interactive:+-i} -t build-windows /root/build.sh

dist/darwin/amd64/openvpn: mac-build
	mkdir -p dist/darwin/amd64
	docker cp build-mac:/root/build/amd64/sbin/openvpn dist/darwin/amd64/openvpn

dist/darwin/arm64/openvpn: mac-build
	mkdir -p dist/darwin/arm64
	docker cp build-mac:/root/build/arm64/sbin/openvpn dist/darwin/arm64/openvpn

dist/linux/amd64/openvpn: linux-build
	mkdir -p dist/linux/amd64
	docker cp build-linux:/root/build/amd64/sbin/openvpn dist/linux/amd64/openvpn

dist/linux/arm/openvpn: linux-build
	mkdir -p dist/linux/arm
	docker cp build-linux:/root/build/arm/sbin/openvpn dist/linux/arm/openvpn

dist/linux/arm64/openvpn: linux-build
	mkdir -p dist/linux/arm64
	docker cp build-linux:/root/build/arm64/sbin/openvpn dist/linux/arm64/openvpn

dist/linux/s390x/openvpn: linux-build
	mkdir -p dist/linux/s390x
	docker cp build-linux:/root/build/s390x/sbin/openvpn dist/linux/s390x/openvpn

dist/windows/amd64/openvpn.exe: windows-build
	mkdir -p dist/windows/amd64
	docker cp build-windows:/root/src/openvpn-build/windows-nsis/tmp/build-x86_64/openvpn-2.5.5/src/openvpn/.libs/openvpn.exe dist/windows/amd64/openvpn.exe

clean-linux:
	if [[ $$(docker ps) =~ "build-linux" ]]; then \
		docker stop build-linux; \
	fi
	if [[ $$(docker ps -a) =~ "build-linux" ]]; then \
		docker rm build-linux; \
	fi

clean-mac:
	if [[ $$(docker ps) =~ "build-mac" ]]; then \
		docker stop build-mac; \
	fi
	if [[ $$(docker ps -a) =~ "build-mac" ]]; then \
		docker rm build-mac; \
	fi

clean-windows:
	if [[ $$(docker ps) =~ "build-windows" ]]; then \
		docker stop build-windows; \
	fi
	if [[ $$(docker ps -a) =~ "build-windows" ]]; then \
		docker rm build-windows; \
	fi

certs:
	mkdir -p certs
	aws s3 sync \
		s3://private.microbox.cloud/certs \
		certs/ \
		--region us-west-2

publish:
	aws s3 sync \
		dist/ \
		s3://tools.microbox.cloud/openvpn \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1
