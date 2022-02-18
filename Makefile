SHELL := /bin/bash
interactive := $(shell test -t 0 && echo yes)

.PHONY: default clean clean-linux clean-linux-amd64 clean-linux-arm64 clean-linux-arm clean-linux-s390x clean-mac clean-mac-amd64 clean-mac-arm64 clean-windows linux-env mac-env windows-env linux-container linux-amd64-container linux-arm64-container linux-arm-container linux-s390x-container mac-container windows-container publish publish-linux publish-linux-amd64 publish-linux-arm64 publish-linux-arm publish-linux-s390x publish-mac publish-mac-amd64 publish-mac-arm64 publish-windows

default: copy-windows copy-mac copy-linux

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
		docker run -d --rm --name build-linux mubox/build-openvpn-linux sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-linux" ]]; then \
		docker start build-linux; \
	fi

linux-amd64-container: linux-env
	if [[ ! $$(docker ps -a) =~ "build-linux-amd64" ]]; then \
		docker run -d --rm -e TARGET=amd64 --name build-linux-amd64 mubox/build-openvpn-linux sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-linux-amd64" ]]; then \
		docker start build-linux-amd64; \
	fi

linux-arm64-container: linux-env
	if [[ ! $$(docker ps -a) =~ "build-linux-arm64" ]]; then \
		docker run -d --rm -e TARGET=arm64 --name build-linux-arm64 mubox/build-openvpn-linux sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-linux-arm64" ]]; then \
		docker start build-linux-arm64; \
	fi

linux-arm-container: linux-env
	if [[ ! $$(docker ps -a) =~ "build-linux-arm32" ]]; then \
		docker run -d --rm -e TARGET=arm --name build-linux-arm32 mubox/build-openvpn-linux sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-linux-arm32" ]]; then \
		docker start build-linux-arm32; \
	fi

linux-s390x-container: linux-env
	if [[ ! $$(docker ps -a) =~ "build-linux-s390x" ]]; then \
		docker run -d --rm -e TARGET=s390x --name build-linux-s390x mubox/build-openvpn-linux sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-linux-s390x" ]]; then \
		docker start build-linux-s390x; \
	fi

mac-container: mac-env
	if [[ ! $$(docker ps -a) =~ "build-mac" ]]; then \
		docker run -d --rm --name build-mac mubox/build-openvpn-mac sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-mac" ]]; then \
		docker start build-mac; \
	fi

mac-amd64-container: mac-env
	if [[ ! $$(docker ps -a) =~ "build-mac-amd64" ]]; then \
		docker run -d --rm -e TARGET=amd64 --name build-mac-amd64 mubox/build-openvpn-mac sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-mac-amd64" ]]; then \
		docker start build-mac-amd64; \
	fi

mac-arm64-container: mac-env
	if [[ ! $$(docker ps -a) =~ "build-mac-arm64" ]]; then \
		docker run -d --rm -e TARGET=arm64 --name build-mac-arm64 mubox/build-openvpn-mac sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-mac-arm64" ]]; then \
		docker start build-mac-arm64; \
	fi

windows-container: windows-env
	if [[ ! $$(docker ps -a) =~ "build-windows" ]]; then \
		docker run -d --rm --name build-windows mubox/build-openvpn-windows sleep 365d; \
	elif [[ ! $$(docker ps) =~ "build-windows" ]]; then \
		docker start build-windows; \
	fi

linux-build: linux-container
	docker exec ${interactive:+-i} -t build-linux /root/build.sh

linux-amd64-build: linux-amd64-container
	docker exec ${interactive:+-i} -t build-linux-amd64 /root/build.sh

linux-arm64-build: linux-arm64-container
	docker exec ${interactive:+-i} -t build-linux-arm64 /root/build.sh

linux-arm-build: linux-arm-container
	docker exec ${interactive:+-i} -t build-linux-arm32 /root/build.sh

linux-s390x-build: linux-s390x-container
	docker exec ${interactive:+-i} -t build-linux-s390x /root/build.sh

mac-build: mac-container
	docker exec ${interactive:+-i} -t build-mac /root/build.sh

mac-amd64-build: mac-amd64-container
	docker exec ${interactive:+-i} -t build-mac-amd64 /root/build.sh

mac-arm64-build: mac-arm64-container
	docker exec ${interactive:+-i} -t build-mac-arm64 /root/build.sh

windows-build: windows-container
	docker exec ${interactive:+-i} -t build-windows /root/build.sh

copy-linux: copy-linux-amd64 copy-linux-arm64 copy-linux-arm copy-linux-s390x

copy-linux-amd64: dist/linux/amd64/openvpn

copy-linux-arm64: dist/linux/arm64/openvpn

copy-linux-arm: dist/linux/arm/openvpn

copy-linux-s390x: dist/linux/s390x/openvpn

copy-mac: copy-mac-amd64 copy-mac-arm64

copy-mac-amd64: dist/darwin/amd64/openvpn

copy-mac-arm64: dist/darwin/arm64/openvpn

copy-windows: dist/windows/amd64/openvpn.exe

dist/darwin/amd64/openvpn: mac-amd64-build
	mkdir -p dist/darwin/amd64
	if [[ $$(docker ps) =~ "build-mac-amd64" ]]; then \
		docker cp build-mac-amd64:/root/build/amd64/sbin/openvpn dist/darwin/amd64/openvpn; \
	else \
		docker cp build-mac:/root/build/amd64/sbin/openvpn dist/darwin/amd64/openvpn; \
	fi

dist/darwin/arm64/openvpn: mac-arm64-build
	mkdir -p dist/darwin/arm64
	if [[ $$(docker ps) =~ "build-mac-arm64" ]]; then \
		docker cp build-mac-arm64:/root/build/arm64/sbin/openvpn dist/darwin/arm64/openvpn; \
	else \
		docker cp build-mac:/root/build/arm64/sbin/openvpn dist/darwin/arm64/openvpn; \
	fi

dist/linux/amd64/openvpn: linux-amd64-build
	mkdir -p dist/linux/amd64
	if [[ $$(docker ps) =~ "build-linux-amd64" ]]; then \
		docker cp build-linux-amd64:/root/build/amd64/sbin/openvpn dist/linux/amd64/openvpn; \
	else \
		docker cp build-linux:/root/build/amd64/sbin/openvpn dist/linux/amd64/openvpn; \
	fi

dist/linux/arm/openvpn: linux-arm-build
	mkdir -p dist/linux/arm
	if [[ $$(docker ps) =~ "build-linux-arm32" ]]; then \
		docker cp build-linux-arm32:/root/build/arm/sbin/openvpn dist/linux/arm/openvpn; \
	else \
		docker cp build-linux:/root/build/arm/sbin/openvpn dist/linux/arm/openvpn; \
	fi

dist/linux/arm64/openvpn: linux-arm64-build
	mkdir -p dist/linux/arm64
	if [[ $$(docker ps) =~ "build-linux-arm64" ]]; then \
		docker cp build-linux-arm64:/root/build/arm64/sbin/openvpn dist/linux/arm64/openvpn; \
	else \
		docker cp build-linux:/root/build/arm64/sbin/openvpn dist/linux/arm64/openvpn; \
	fi

dist/linux/s390x/openvpn: linux-s390x-build
	mkdir -p dist/linux/s390x
	if [[ $$(docker ps) =~ "build-linux-s390x" ]]; then \
		docker cp build-linux-s390x:/root/build/s390x/sbin/openvpn dist/linux/s390x/openvpn; \
	else \
		docker cp build-linux:/root/build/s390x/sbin/openvpn dist/linux/s390x/openvpn; \
	fi

dist/windows/amd64/openvpn.exe: windows-build
	mkdir -p dist/windows/amd64
	docker cp build-windows:/root/src/openvpn-build/windows-nsis/tmp/build-x86_64/openvpn-2.5.5/src/openvpn/.libs/openvpn.exe dist/windows/amd64/openvpn.exe

clean-linux:
	if [[ $$(docker ps) =~ "build-linux" ]]; then \
		docker stop build-linux; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-linux" ]]; then \
		docker rm build-linux; \
	fi

clean-linux-amd64:
	if [[ $$(docker ps) =~ "build-linux-amd64" ]]; then \
		docker stop build-linux-amd64; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-linux-amd64" ]]; then \
		docker rm build-linux-amd64; \
	fi

clean-linux-arm64:
	if [[ $$(docker ps) =~ "build-linux-arm64" ]]; then \
		docker stop build-linux-arm64; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-linux-arm64" ]]; then \
		docker rm build-linux-arm64; \
	fi

clean-linux-arm:
	if [[ $$(docker ps) =~ "build-linux-arm32" ]]; then \
		docker stop build-linux-arm32; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-linux-arm32" ]]; then \
		docker rm build-linux-arm32; \
	fi

clean-linux-s390x:
	if [[ $$(docker ps) =~ "build-linux-s390x" ]]; then \
		docker stop build-linux-s390x; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-linux-s390x" ]]; then \
		docker rm build-linux-s390x; \
	fi

clean-mac:
	if [[ $$(docker ps) =~ "build-mac" ]]; then \
		docker stop build-mac; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-mac" ]]; then \
		docker rm build-mac; \
	fi

clean-mac-amd64:
	if [[ $$(docker ps) =~ "build-mac-amd64" ]]; then \
		docker stop build-mac-amd64; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-mac-amd64" ]]; then \
		docker rm build-mac-amd64; \
	fi

clean-mac-arm64:
	if [[ $$(docker ps) =~ "build-mac-arm64" ]]; then \
		docker stop build-mac-arm64; \
		sleep 1; \
	fi
	if [[ $$(docker ps -a) =~ "build-mac-arm64" ]]; then \
		docker rm build-mac-arm64; \
	fi

clean-windows:
	if [[ $$(docker ps) =~ "build-windows" ]]; then \
		docker stop build-windows; \
		sleep 1; \
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

publish-mac: publish-mac-amd64 publish-mac-arm64

publish-mac-amd64:
	aws s3 sync \
		dist/darwin/amd64/ \
		s3://tools.microbox.cloud/openvpn/darwin/amd64 \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1

publish-mac-arm64:
	aws s3 sync \
		dist/darwin/arm64/ \
		s3://tools.microbox.cloud/openvpn/darwin/arm64 \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1

publish-linux: publish-linux-amd64 publish-linux-arm64 publish-linux-arm publish-linux-s390x

publish-linux-amd64:
	aws s3 sync \
		dist/linux/amd64/ \
		s3://tools.microbox.cloud/openvpn/linux/amd64 \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1

publish-linux-arm64:
	aws s3 sync \
		dist/linux/arm64/ \
		s3://tools.microbox.cloud/openvpn/linux/arm64 \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1

publish-linux-arm:
	aws s3 sync \
		dist/linux/arm/ \
		s3://tools.microbox.cloud/openvpn/linux/arm \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1

publish-linux-s390x:
	aws s3 sync \
		dist/linux/s390x/ \
		s3://tools.microbox.cloud/openvpn/linux/s390x \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1

publish-windows:
	aws s3 sync \
		dist/windows/ \
		s3://tools.microbox.cloud/openvpn/windows \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1

publish:
	aws s3 sync \
		dist/ \
		s3://tools.microbox.cloud/openvpn; \
		--grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers \
		--region us-east-1
