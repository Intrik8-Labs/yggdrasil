.PHONY: help restore build format test check run docker-build feature-start feature-finish release hotfix

SOLUTION := Yggdrasil.slnx
API_PROJECT := src/Host/Yggdrasil.Api/Yggdrasil.Api.csproj
IMAGE_NAME ?= yggdrasil-api

help:
	@echo "Development targets:"
	@echo "  restore       Restore solution dependencies"
	@echo "  build         Build the solution"
	@echo "  format        Verify source formatting"
	@echo "  test          Run all solution tests"
	@echo "  check         Run restore, format, build, and test"
	@echo "  run           Run the API host"
	@echo "  docker-build  Build the API container image"
	@echo "  feature-start Start a git-flow feature"
	@echo "  feature-finish Finish a git-flow feature"
	@echo "  release       Ship VERSION as a git-flow release"
	@echo "  hotfix        Ship VERSION as a git-flow hotfix"

restore:
	dotnet restore $(SOLUTION)

build:
	dotnet build $(SOLUTION) --no-restore

format:
	dotnet format $(SOLUTION) --verify-no-changes --no-restore

test:
	dotnet test $(SOLUTION) --no-restore

check: restore format build test

run:
	dotnet run --project $(API_PROJECT)

docker-build:
	docker build --tag $(IMAGE_NAME) .

feature-start:
	@read -p "Feature name: " name; git flow feature start "$$name"

feature-finish:
	@read -p "Feature name: " name; git flow feature finish "$$name"

release:
	@test -n "$(VERSION)" || (echo "Usage: make release VERSION=0.1.0"; exit 1)
	@./scripts/git-flow-ship.sh release $(VERSION)

hotfix:
	@test -n "$(VERSION)" || (echo "Usage: make hotfix VERSION=0.1.1"; exit 1)
	@./scripts/git-flow-ship.sh hotfix $(VERSION)
