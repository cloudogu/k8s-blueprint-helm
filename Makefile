# Set these to the desired values
PROJECT_NAME=k8s-blueprint-helm
ARTIFACT_ID=k8s-blueprint-helm
VERSION=0.0.1

MAKEFILES_VERSION=10.4.0


include build/make/variables.mk
include build/make/self-update.mk
include build/make/clean.mk
include build/make/digital-signature.mk
include build/make/k8s-component.mk
include build/make/release.mk



