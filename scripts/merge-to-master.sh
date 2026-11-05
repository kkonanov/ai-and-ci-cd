#!/usr/bin/env bash
# Merge: после успешного deploy-prod вливаем release в master.
#
# Использование: ./scripts/merge-to-master.sh <SHA>
#   SHA — коммит release, который только что доехал до prod.
#
# master = то, что сейчас в prod, поэтому двигаем master ровно на
# задеплоенный SHA (а не на текущую вершину release — она могла уйти вперёд)
# и только fast-forward: если в master есть коммиты, которых нет в release,
# скрипт падает — расхождение нужно разобрать руками, а не склеивать.
#
# Нужно: полная история (actions/checkout с fetch-depth: 0) и права
# contents: write у GITHUB_TOKEN.
set -euo pipefail

cd "$(dirname "$0")/.."

SHA="${1:-}"
if [[ -z "${SHA}" ]]; then
  echo "usage: $0 <SHA>" >&2
  exit 2
fi

echo "==> git fetch origin master"
git fetch --no-tags origin master

if ! git merge-base --is-ancestor origin/master "${SHA}"; then
  echo "ERROR: master не является предком ${SHA}: fast-forward невозможен," >&2
  echo "       в master есть коммиты, которых нет в release. Нужен ручной разбор." >&2
  exit 1
fi

echo "==> git push origin ${SHA}:refs/heads/master (fast-forward)"
git push origin "${SHA}:refs/heads/master"
