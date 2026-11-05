#!/usr/bin/env bash
# Lint: статический анализ кода ruff'ом.
# Запуск локально и в CI одинаковый: ./scripts/lint.sh
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> ruff $(ruff --version)"
ruff check app tests
