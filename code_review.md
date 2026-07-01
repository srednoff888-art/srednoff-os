# code_review.md

При review кода проверяй:

## P0 — блокеры

- утечка секретов;
- потеря данных;
- обход авторизации;
- отключение RLS/security;
- production outage risk;
- SQL injection / XSS / SSRF;
- destructive migrations без rollback.

## P1 — серьёзные проблемы

- сломанный core-flow;
- отсутствие обработки ошибок;
- race conditions;
- некорректные права доступа;
- нестабильные интеграции;
- отсутствие тестов на критичную логику.

## P2 — улучшения

- читаемость;
- дублирование;
- слабая типизация;
- отсутствие логов;
- неоптимальные запросы;
- неясные boundaries между слоями.

## Формат ответа

```md
## Code Review

P0:
-

P1:
-

P2:
-

Ship decision:
- SHIP / DO NOT SHIP / SHIP WITH RISKS

Required fixes:
-
```
