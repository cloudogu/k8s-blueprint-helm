# Set these to the desired values
PROJECT_NAME=k8s-blueprint-helm
ARTIFACT_ID=k8s-blueprint-helm
APPEND_CRD_SUFFIX=false
VERSION=1.0.0

GOTAG?=1.25.1
MAKEFILES_VERSION=10.4.0

GO_BUILD_FLAGS?=-mod=vendor -a ./...
.DEFAULT_GOAL:=default

PRE_COMPILE = generate-deepcopy
IMAGE_IMPORT_TARGET=image-import
CHECK_VAR_TARGETS=check-all-vars-without-image

include build/make/variables.mk
include build/make/self-update.mk
include build/make/dependencies-gomod.mk
include build/make/build.mk
include build/make/test-common.mk
include build/make/test-unit.mk
include build/make/static-analysis.mk
include build/make/clean.mk
include build/make/digital-signature.mk
include build/make/mocks.mk
include build/make/k8s-controller.mk
include build/make/release.mk


default: compile

