.DEFAULT_GOAL: help
SHELL := /bin/bash

PROJECTNAME := "fip-healthcheck-go-template"
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: help
all: help
help: Makefile
	@echo
	@echo " Choose a command to run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

check-variable-%: # detection of undefined variables.
	@[[ "${${*}}" ]] || (echo '*** Please define variable `${*}` ***' && exit 1)

optional-variable-%: # detection of undefined variables.
	@[[ "${${*}}" ]] || (echo '*** Variable `${*}` is optional. Make sure you understand how to use it ***')

check-%: # detection of required software.
	@which ${*} > /dev/null || (echo '*** Please install `${*}` ***' && exit 1)

## init: Init the project. GITHUB_PROJECT=demo make init
init: check-variable-GITHUB_PROJECT
	@test -f ./scripts/init.sh && ./scripts/init.sh ${GITHUB_PROJECT} || echo "Project already initialized with name ${GITHUB_PROJECT}"

## drone-init: Init the drone-project. GITHUB_PROJECT=demo GITHUB_TOKEN=123token321 DRONE_TOKEN=tokenhere REGISTRY=registry.sighup.io REGISTRY_USER=robotuser REGISTRY_PASSWORD=thepassword make drone-init
drone-init: check-variable-GITHUB_PROJECT check-variable-GITHUB_TOKEN check-variable-DRONE_TOKEN check-variable-REGISTRY check-variable-REGISTRY_USER check-variable-REGISTRY_PASSWORD
	@test -f ./scripts/drone-init.sh && ./scripts/drone-init.sh ${GITHUB_PROJECT} ${GITHUB_TOKEN} ${DRONE_TOKEN} ${REGISTRY} ${REGISTRY_USER} ${REGISTRY_PASSWORD} || echo "Drone project already initialized with name ${GITHUB_PROJECT}"

requirements: check-docker
	@docker build --no-cache --pull --target requirements -f build/builder/Dockerfile -t ${PROJECTNAME}:requirements .

npm-requirements: check-docker
	@docker build --no-cache --pull --target npm-requirements -f build/builder/Dockerfile -t ${PROJECTNAME}:npm-requirements .

## embedme: Run embedme to render and embed markdown files
embedme: npm-requirements
	@docker run --rm -v ${ROOT_DIR}:/app -w /app ${PROJECTNAME}:npm-requirements embedme "**/*.md"
	@$(MAKE) add-license

## render: Render the default kustomization project into the examples directory
render: check-kustomize
	@kustomize build deployments/kustomization > examples/rendered.yaml
	@$(MAKE) add-license

## build: Build the container image
build: check-docker
	@docker build --no-cache --pull --target builder -f build/builder/Dockerfile -t ${PROJECTNAME}:local-build .
	@$(MAKE) clean-build

## lint: Run the policeman over the repository
lint: check-docker
	@docker build --no-cache --pull --target linter -f build/builder/Dockerfile -t ${PROJECTNAME}:local-lint .
	@$(MAKE) clean-lint

## build-release: Build the release container image
build-release: check-docker
	@docker build --no-cache --pull --target release -f build/builder/Dockerfile -t ${PROJECTNAME}:local-build-release .

## test: Run unit testing
test: check-docker
	@docker build --no-cache --pull --target tester -f build/builder/Dockerfile -t ${PROJECTNAME}:local-test .
	@$(MAKE) clean-test

## add-license: Add license headers in all files in the project
add-license: requirements
	@docker run --rm -v ${ROOT_DIR}:/app -w /app ${PROJECTNAME}:requirements addlicense -c "SIGHUP s.r.l" -v -l bsd .

## license: Check license headers are in-place in all files in the project
license: check-docker
	@docker build --no-cache --pull --target license -f build/builder/Dockerfile -t ${PROJECTNAME}:local-license .
	@$(MAKE) clean-license

## e2e-test: Execute e2e-tests. CLUSTER_VERSION=v1.21.1 make e2e-test
e2e-test: check-variable-CLUSTER_VERSION check-docker check-kind check-kubectl check-bats check-jq check-kustomize build-release
	@./scripts/e2e/run.sh ${PROJECTNAME}:local-build-release ${CLUSTER_VERSION}
	@$(MAKE) clean-build-release

## publish: Publish the container image
publish: check-variable-REGISTRY check-variable-REGISTRY_USER check-variable-REGISTRY_PASSWORD check-variable-IMAGE_NAME check-variable-IMAGE_TAG check-docker build-release
	@./scripts/publish/run.sh ${PROJECTNAME}:local-build-release ${REGISTRY} ${REGISTRY_USER} ${REGISTRY_PASSWORD} ${IMAGE_NAME} ${IMAGE_TAG}
	@$(MAKE) clean-build-release

## clean-%: Clean the container image resulting from another target. make build clean-build
clean-%:
	@docker rmi -f ${PROJECTNAME}:local-${*}
