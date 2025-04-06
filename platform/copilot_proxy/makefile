VERSION ?= 0.0.1

build:
	cd sidecar && docker build --file=Dockerfile --no-cache --tag=aviatrix/avx-demo-sidecar:${VERSION} .
	cd nginx && docker build --file=Dockerfile --no-cache --tag=aviatrix/avx-demo-nginx:${VERSION} .
