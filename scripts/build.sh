#!/usr/bin/env bash
# Build: сборка Docker-образа delivery-calc с тегом = SHA коммита.
#
# Переменные окружения:
#   IMAGE_NAME  — репозиторий образа (по умолчанию registry.marketplace.example/delivery-calc)
#   IMAGE_TAG   — тег; по умолчанию GITHUB_SHA (в CI), иначе `git rev-parse HEAD`
#
# Учебное окружение: реального registry нет, поэтому `docker push`
# не выполняется, а печатается (dry-run). `docker build` выполняется по-настоящему.
set -euo pipefail

cd "$(dirname "$0")/.."

IMAGE_NAME="${IMAGE_NAME:-registry.marketplace.example/delivery-calc}"
IMAGE_TAG="${IMAGE_TAG:-${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || true)}}"

if [[ -z "${IMAGE_TAG}" ]]; then
  echo "ERROR: не удалось определить SHA коммита: задайте IMAGE_TAG или GITHUB_SHA" >&2
  exit 1
fi

IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

echo "==> docker build ${IMAGE}"
docker build \
  --label "org.opencontainers.image.revision=${IMAGE_TAG}" \
  -t "${IMAGE}" \
  .

echo "==> [dry-run] docker push ${IMAGE}"

# Отдаём имя образа следующим шагам CI (если запущены в GitHub Actions).
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "image=${IMAGE}" >> "${GITHUB_OUTPUT}"
fi
