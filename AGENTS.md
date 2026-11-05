# AGENTS.md

Сервис delivery-calc — калькулятор доставки (Python 3.12).
Код — `app/`, тесты — `tests/` (pytest), манифесты Kubernetes — `k8s/`.

## Ветки

- Разработка — в feature-ветках, Pull Request — в `release`.
- Всё, что влито в `release`, едет в prod.
- `master` — то, что сейчас в prod.

## CI/CD

- Логика шагов — в scripts/*.sh
- Версии actions: @v5, не @main
- permissions: минимальные
- Секреты — только по имени
- После правок: actionlint

## Учебное окружение

Реальных registry и кластера нет. В scripts/*.sh команды `docker push`
и `kubectl` не выполняются, а печатаются (dry-run).
Lint (ruff), тесты (pytest) и `docker build` выполняются по-настоящему.
