.PHONY: feature-start feature-finish release hotfix

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
