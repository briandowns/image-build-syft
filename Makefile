SEVERITIES = HIGH,CRITICAL

ifeq ($(ARCH),)
ARCH=$(shell go env GOARCH)
endif

BUILD_META=-build$(shell date +%Y%m%d)
ORG ?= briandowns
PKG ?= github.com/anchore/syft
SRC ?= github.com/anchore/syft
TAG ?= v0.22.0

ifneq ($(DRONE_TAG),)
TAG := $(DRONE_TAG)
endif

.PHONY: image-build
image-build:
	docker build \
		--pull \
		--build-arg PKG=$(PKG) \
		--build-arg SRC=$(SRC) \
		--build-arg TAG=$(TAG) \
        --build-arg ARCH=$(ARCH) \
		--tag $(ORG)/hardened-syft:$(TAG) \
		--tag $(ORG)/hardened-syft:$(TAG)-$(ARCH) \
	.

.PHONY: image-push
image-push:
	docker push $(ORG)/hardened-syft:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-syft:$(TAG) \
		$(ORG)/hardened-syft:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-syft:$(TAG)

.PHONY: image-scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-syft:$(TAG)
