# GITHUB_RESEARCH.md — обязательный протокол проверки GitHub

Используй этот документ каждый раз, когда задача требует внешнего инженерного опыта.

## Когда запускать

Запускать перед:

- выбором архитектуры;
- выбором библиотеки;
- созданием бота, парсера, агента, сайта, SaaS, dashboard;
- интеграцией с API;
- настройкой деплоя;
- сложным багфиксом;
- refactor;
- security-sensitive изменениями.

## Запросы для поиска

Используй разные типы запросов:

```text
<technology> <feature> example
<technology> <problem> GitHub
<framework> starter <feature>
<integration> boilerplate
<library> production example
<error message> GitHub issue
```

Примеры:

```text
telegram bot supabase vercel github
nextjs supabase auth rls starter
openai structured outputs typescript github
freelance job scraper telegram bot github
vercel cron supabase edge functions github
```

## Фильтр качества

Хороший репозиторий:

- активно обновлялся в последние 6–12 месяцев;
- имеет понятный README;
- имеет лицензию;
- имеет issues/PR без признаков заброшенности;
- не выглядит как одноразовый demo-spam;
- содержит тесты или production-подход;
- совместим со стеком проекта.

Плохой репозиторий:

- нет лицензии;
- последний коммит старый;
- много нерешённых critical issues;
- нет документации;
- hardcoded secrets;
- архитектура завязана на устаревшие версии;
- много копипасты и нет тестов.

## Таблица сравнения

```md
| Repo | Stars | Last update | License | Stack | Useful pattern | Risks |
|---|---:|---|---|---|---|---|
|  |  |  |  |  |  |  |
```

## Решение после анализа

```md
## Decision

Adopt:
- 

Adapt:
- 

Avoid:
- 

Build ourselves:
- 

Why:
-
```

## Правило лицензий

Не копировать код из репозитория, если:

- лицензия отсутствует;
- лицензия несовместима;
- непонятно происхождение кода.

Можно использовать идеи и паттерны, если они не являются прямым копированием.
