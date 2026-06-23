#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <release|hotfix> <version>"
  exit 1
fi

TYPE="$1"      # release or hotfix
VERSION="$2"
BRANCH="${TYPE}/${VERSION}"

if [[ "$TYPE" != "release" && "$TYPE" != "hotfix" ]]; then
  echo "Type must be 'release' or 'hotfix'"
  exit 1
fi

echo "==> Starting git flow ${TYPE} ${VERSION}"
git flow "${TYPE}" start "${VERSION}"

echo ""
echo "Branch ${BRANCH} created. Do your work now (version bumps, changelog, fixes)."
read -p "Press enter when committed and ready to finish..."

echo "==> Finishing ${TYPE} (no auto-push — main is protected)"
git flow "${TYPE}" finish -n "${VERSION}"

echo "==> Pushing develop"
git push origin develop

echo "==> Pushing ${BRANCH}"
git push origin "${BRANCH}"

echo "==> Opening PR into main"
gh pr create --base main --head "${BRANCH}" --title "${TYPE^} ${VERSION}" --body "Automated ${TYPE} PR for v${VERSION}"

echo "==> Merging PR"
gh pr merge "${BRANCH}" --merge

echo "==> Syncing local main"
git checkout main
git pull origin main

echo "==> Tagging v${VERSION}"
git tag -a "v${VERSION}" -m "${TYPE^} ${VERSION}"
git push origin "v${VERSION}"

echo "==> Cleaning up ${BRANCH}"
git push origin --delete "${BRANCH}"
git branch -d "${BRANCH}" 2>/dev/null || true

echo "==> Done. v${VERSION} ${TYPE}d."
