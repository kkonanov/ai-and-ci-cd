#!/usr/bin/env bash
# Deploy: выкатка образа delivery-calc в Kubernetes с автооткатом.
#
# Использование: ./scripts/deploy.sh <IMAGE_TAG>
#   IMAGE_TAG — тег образа (SHA коммита, как в scripts/build.sh).
#   Откат на любую версию = запустить этот же скрипт с её SHA.
#
# Переменные окружения:
#   KUBECONFIG_DATA  — содержимое kubeconfig целевого кластера (из секрета CI)
#   IMAGE_NAME       — репозиторий образа (по умолчанию registry.marketplace.example/delivery-calc)
#   ROLLOUT_TIMEOUT  — сколько ждать готовности (по умолчанию 5m)
#
# Если rollout не дождался готовности — `kubectl rollout undo` к предыдущей
# ревизии, и скрипт всё равно завершается с ошибкой: откат — сигнал разобраться.
#
# Учебное окружение: реального кластера нет, поэтому команды kubectl
# не выполняются, а печатаются (dry-run). Чтобы показать откат,
# задайте DRY_RUN_FAIL_ROLLOUT=1 — dry-run `rollout status` «упадёт».
set -euo pipefail

cd "$(dirname "$0")/.."

IMAGE_TAG="${1:-}"
if [[ -z "${IMAGE_TAG}" ]]; then
  echo "usage: $0 <IMAGE_TAG>" >&2
  exit 2
fi

if [[ -z "${KUBECONFIG_DATA:-}" ]]; then
  echo "ERROR: KUBECONFIG_DATA пуст: проверьте секрет окружения" >&2
  exit 1
fi

IMAGE_NAME="${IMAGE_NAME:-registry.marketplace.example/delivery-calc}"
IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"
ROLLOUT_TIMEOUT="${ROLLOUT_TIMEOUT:-5m}"
NAMESPACE="delivery"
DEPLOYMENT="deployment/delivery-calc"
CONTAINER="app"

# kubeconfig — во временный файл с правами 600, удаляется при выходе.
KUBECONFIG="$(mktemp "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/kubeconfig.XXXXXX")"
export KUBECONFIG
trap 'rm -f "${KUBECONFIG}"' EXIT
chmod 600 "${KUBECONFIG}"
printf '%s\n' "${KUBECONFIG_DATA}" > "${KUBECONFIG}"

ROLLED_BACK=0

# Dry-run: печатаем команду вместо выполнения.
kubectl() {
  echo "==> [dry-run] kubectl $*"
  if [[ "${DRY_RUN_FAIL_ROLLOUT:-0}" == "1" && "${ROLLED_BACK}" == "0" && "$*" == *"rollout status"* ]]; then
    echo "error: timed out waiting for the condition" >&2
    return 1
  fi
}

echo "==> deploy ${IMAGE} -> ${NAMESPACE}/${DEPLOYMENT}"
kubectl -n "${NAMESPACE}" set image "${DEPLOYMENT}" "${CONTAINER}=${IMAGE}"

if ! kubectl -n "${NAMESPACE}" rollout status "${DEPLOYMENT}" --timeout="${ROLLOUT_TIMEOUT}"; then
  echo "ERROR: rollout ${IMAGE} не прошёл, откатываю на предыдущую ревизию" >&2
  ROLLED_BACK=1
  kubectl -n "${NAMESPACE}" rollout undo "${DEPLOYMENT}"
  kubectl -n "${NAMESPACE}" rollout status "${DEPLOYMENT}" --timeout="${ROLLOUT_TIMEOUT}" \
    || echo "ERROR: откат тоже не дождался готовности, нужен ручной разбор" >&2
  exit 1
fi

echo "==> deployed ${IMAGE}"
