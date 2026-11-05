#!/usr/bin/env bash
# Test: юнит-тесты pytest.
# Запуск локально и в CI одинаковый: ./scripts/test.sh
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> $(python --version), pytest"
python -m pytest -v
