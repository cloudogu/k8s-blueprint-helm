# Set these to the desired values
PROJECT_NAME=blueprint
ARTIFACT_ID=k8s-blueprint
VERSION=1.2.2

MAKEFILES_VERSION=10.5.0


include build/make/variables.mk
include build/make/self-update.mk
include build/make/clean.mk
include build/make/digital-signature.mk
include build/make/k8s-component.mk
include build/make/release.mk

.PHONY: helm-release
helm-release:
	build/make/release.sh helm


helm-print: ${BINARY_HELM}
	@echo "Render helm chart using default values from 'values.yaml'"
	@${BINARY_HELM} template --debug ${HELM_SOURCE_DIR}