# Домашнее задание к занятию «Индексы» — Павел Логачев

## Задание 1

Работа выполнена в том же контейнере с MySQL `8.0.46`, что и задание `12-02-sql-ddl-dml`. Используется восстановленная ранее база `sakila`: все 16 таблиц на InnoDB. Запросы выполнены в консольном клиенте `mysql`. Скрипты с `ANALYZE TABLE`, созданием индекса и временными таблицами для проверки выполнены целиком от `root`: [01-index-size.sql](<indexes/01-index-size.sql>), [03-create-index.sql](<indexes/03-create-index.sql>) и [06-equivalence.sql](<indexes/06-equivalence.sql>). Остальные скрипты выполнены от имени `sys_temp`.

Нужно получить процентное отношение общего размера всех индексов к общему размеру всех таблиц.

Скрипт: [01-index-size.sql](<indexes/01-index-size.sql>).

```sql
ANALYZE TABLE actor, address, category, city, country, customer, film,
  film_actor, film_category, film_text, inventory, language, payment,
  rental, staff, store;
SELECT TABLE_SCHEMA AS schema_name, COUNT(*) AS base_tables,
       SUM(DATA_LENGTH) AS data_bytes, SUM(INDEX_LENGTH) AS index_bytes,
       SUM(DATA_LENGTH + INDEX_LENGTH) AS data_plus_indexes_bytes,
       ROUND(100.0 * SUM(INDEX_LENGTH) / NULLIF(SUM(DATA_LENGTH), 0), 2)
         AS index_to_data_percent
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila' AND TABLE_TYPE = 'BASE TABLE'
GROUP BY TABLE_SCHEMA;
```

Перед замером для всех 16 таблиц выполнен `ANALYZE TABLE`, чтобы обновить статистику. Все таблицы вернули `status OK`. Размеры берутся из `information_schema.TABLES` только для базовых таблиц `sakila`, без представлений. Отношение считается как 100 × `SUM(INDEX_LENGTH)` / `SUM(DATA_LENGTH)`.

Результат:

| schema_name | base_tables | data_bytes | index_bytes | data_plus_indexes_bytes | index_to_data_percent |
| --- | ---: | ---: | ---: | ---: | ---: |
| sakila | 16 | 4374528 | 2392064 | 6766592 | 54.68 |

Размер индексов составляет 54.68 % от размера таблиц: 100 × 2392064 / 4374528.

Особенности расчёта. В InnoDB `DATA_LENGTH` включает кластерный индекс, то есть сами строки вместе с первичным ключом. `INDEX_LENGTH` учитывает вторичные индексы. Оба значения — статистика по выделенным страницам, а не точный размер логических данных.

![Отношение размера индексов к размеру таблиц: 54.68 %](<indexes/evidence/01-index-size.png>)

Замер выше сделан до создания индекса из задания 2. После создания индекса и `ANALYZE TABLE payment` суммарный `INDEX_LENGTH` вырос на 278528 байт, до 2670592 байт, а отношение стало 61.05 %. Запрос: [08-stand-state.sql](<indexes/08-stand-state.sql>), вывод: [08-stand-state.txt](<indexes/evidence/08-stand-state.txt>), снимки: [1](<indexes/evidence/08-stand-state-1.png>), [2](<indexes/evidence/08-stand-state-2.png>).

## Задание 2

### Исходный запрос

Запрос из условия выполнен с `EXPLAIN ANALYZE` без изменений.

Скрипт: [02-before.sql](<indexes/02-before.sql>).

```sql
EXPLAIN ANALYZE
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id\G
```

План выполнения:

```text
EXPLAIN: -> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=2253..2253 rows=391 loops=1)
    -> Temporary table with deduplication  (cost=0..0 rows=0) (actual time=2253..2253 rows=391 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id,f.title )   (actual time=978..2172 rows=642000 loops=1)
            -> Sort: c.customer_id, f.title  (actual time=978..1004 rows=642000 loops=1)
                -> Stream results  (cost=10.8e+6 rows=16.7e+6) (actual time=0.361..778 rows=642000 loops=1)
                    -> Nested loop inner join  (cost=10.8e+6 rows=16.7e+6) (actual time=0.355..675 rows=642000 loops=1)
                        -> Nested loop inner join  (cost=9.12e+6 rows=16.7e+6) (actual time=0.35..568 rows=642000 loops=1)
                            -> Nested loop inner join  (cost=7.45e+6 rows=16.7e+6) (actual time=0.344..459 rows=642000 loops=1)
                                -> Inner hash join (no condition)  (cost=1.65e+6 rows=16.5e+6) (actual time=0.334..19.4 rows=634000 loops=1)
                                    -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.72 rows=16500) (actual time=0.149..2.7 rows=634 loops=1)
                                        -> Table scan on p  (cost=1.72 rows=16500) (actual time=0.142..1.84 rows=16044 loops=1)
                                    -> Hash
                                        -> Covering index scan on f using idx_title  (cost=103 rows=1000) (actual time=0.0243..0.135 rows=1000 loops=1)
                                -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.25 rows=1.01) (actual time=420e-6..599e-6 rows=1.01 loops=634000)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=250e-6 rows=1) (actual time=58.9e-6..76.5e-6 rows=1 loops=642000)
                        -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=250e-6 rows=1) (actual time=55.4e-6..72.9e-6 rows=1 loops=642000)
```

![EXPLAIN ANALYZE исходного запроса: 2253 мс](<indexes/evidence/02-before.png>)

### Узкие места

Время каждого узла плана включает время дочерних узлов, поэтому складывать их нельзя.

1. **Таблица `film` ни с чем не соединена.** В `WHERE` нет условия для `film`, поэтому в плане стоит `Inner hash join (no condition)`: каждый из 634 платежей за день сочетается со всеми 1000 фильмами, получается 634 000 строк. Это декартово произведение.
2. **Функция над колонкой в фильтре.** Из-за условия `date(p.payment_date) = '2005-07-30'` MySQL не может применить диапазонный поиск по `payment_date`. Таблица `payment` читается целиком (`Table scan on p`, 16044 строки), и фильтр оставляет 634. В исходной схеме индекса по `payment_date` вообще нет.
3. **Повторные обращения к другим таблицам.** Из-за размножения строк поиск в `rental` выполняется 634 000 раз, а в `customer` и `inventory` — по 642 000 раз.
4. **Лишняя таблица `inventory`.** Её колонки не используются ни в выводе, ни в фильтрах, но на каждую строку выполняется ещё один поиск по индексу.
5. **Оконная функция и `DISTINCT` по огромному промежуточному набору.** Перед `sum(...) over (partition by c.customer_id, f.title)` 642 000 строк сортируются (`Sort`, до 1004 мс). Затем оконная агрегация с буферизацией идёт по тем же 642 000 строкам (до 2172 мс). После неё `DISTINCT` через временную таблицу с удалением дубликатов сводит всё к 391 строке. Запрос завершается на 2253 мс.

### Оптимизация

Изменения в запросе:

- таблицы соединены явными `JOIN ... ON`;
- `film` убрана. Она не связана с остальными таблицами, а `title` не выводится. В этой базе у 1000 фильмов 1000 разных названий, поэтому сумма в каждой оконной секции `(customer_id, title)` равна сумме по клиенту, и `DISTINCT` оставлял одну строку на клиента. Проверка ниже показывает, что на этих данных результат не меняется;
- `inventory` убрана: `rental.inventory_id` объявлен как `NOT NULL` и ссылается внешним ключом на первичный ключ `inventory`, поэтому соответствующая запись всегда ровно одна, а её поля не нужны;
- `date(p.payment_date) = '2005-07-30'` заменено на полуинтервал суток: `p.payment_date >= '2005-07-30' AND p.payment_date < '2005-07-31'`. Такое условие может использовать индекс;
- оконный `SUM` заменён обычным `SUM` с `GROUP BY` по клиенту. `DISTINCT` оставлен, но теперь он работает с 391 агрегированной строкой. Он нужен, чтобы точно сохранить исходный вывод из двух столбцов: два разных клиента с одинаковыми фамилией, именем и суммой в исходном запросе дали бы одну строку.

Добавлен индекс. Скрипт: [03-create-index.sql](<indexes/03-create-index.sql>).

```sql
CREATE INDEX idx_hw1205_payment_date_amount ON payment (payment_date, amount);
ANALYZE TABLE payment;
SHOW INDEX FROM payment WHERE Key_name = 'idx_hw1205_payment_date_amount';
```

Первая колонка индекса, `payment_date`, обслуживает диапазон по дате. Колонка `amount` делает индекс покрывающим: все нужные из `payment` данные берутся из индекса без обращения к строкам таблицы. Для `rental` новый индекс не нужен: в Sakila уже есть индекс `rental_date (rental_date, inventory_id, customer_id)`, который покрывает поиск по дате аренды и даёт `customer_id`. Список индексов `payment` и `rental` — в [07-index-inventory.sql](<indexes/07-index-inventory.sql>) и [07-index-inventory.txt](<indexes/evidence/07-index-inventory.txt>).

![Создание индекса idx_hw1205_payment_date_amount](<indexes/evidence/03-create-index.png>)

### Запрос после оптимизации

Скрипт: [04-after.sql](<indexes/04-after.sql>).

```sql
EXPLAIN ANALYZE
SELECT DISTINCT CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
       SUM(p.amount) AS total_amount
FROM payment AS p
JOIN rental AS r ON r.rental_date = p.payment_date
JOIN customer AS c ON c.customer_id = r.customer_id
WHERE p.payment_date >= '2005-07-30' AND p.payment_date < '2005-07-31'
GROUP BY c.customer_id, c.last_name, c.first_name\G
```

План выполнения:

```text
EXPLAIN: -> Sort with duplicate removal: customer_name, total_amount  (actual time=1.47..1.48 rows=391 loops=1)
    -> Table scan on <temporary>  (actual time=1.36..1.38 rows=391 loops=1)
        -> Aggregate using temporary table  (actual time=1.36..1.36 rows=391 loops=1)
            -> Nested loop inner join  (cost=576 rows=642) (actual time=0.0367..1.01 rows=642 loops=1)
                -> Nested loop inner join  (cost=351 rows=642) (actual time=0.031..0.657 rows=642 loops=1)
                    -> Filter: ((p.payment_date >= TIMESTAMP'2005-07-30 00:00:00') and (p.payment_date < TIMESTAMP'2005-07-31 00:00:00'))  (cost=128 rows=634) (actual time=0.0257..0.113 rows=634 loops=1)
                        -> Covering index range scan on p using idx_hw1205_payment_date_amount over ('2005-07-30 00:00:00' <= payment_date < '2005-07-31 00:00:00')  (cost=128 rows=634) (actual time=0.0239..0.0739 rows=634 loops=1)
                    -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.25 rows=1.01) (actual time=527e-6..763e-6 rows=1.01 loops=634)
                -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=440e-6..457e-6 rows=1 loops=642)
```

![EXPLAIN ANALYZE оптимизированного запроса: 1.48 мс](<indexes/evidence/04-after.png>)

Сравнение планов:

| Показатель | До | После |
| --- | --- | --- |
| Время верхнего узла плана | 2253 мс | 1.48 мс |
| Чтение `payment` | полное сканирование, 16044 строки | покрывающий диапазонный поиск по индексу, 634 строки |
| Строк после декартова произведения с `film` | 634 000 | нет |
| Обращений к `rental` | 634 000 | 634 |
| Строк перед агрегацией | 642 000 | 642 |
| Строк в результате | 391 | 391 |

Оба времени получены по одному запуску на небольшом локальном стенде, поэтому это не нагрузочный тест. Сравниваются фактические значения `actual time` из `EXPLAIN ANALYZE`, а не оценки `cost`.

### Результат оптимизированного запроса

Для просмотра тот же запрос выполнен без `EXPLAIN ANALYZE` и с сортировкой по имени: [05-optimized-result.sql](<indexes/05-optimized-result.sql>).

```sql
SELECT DISTINCT CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
       SUM(p.amount) AS total_amount
FROM payment AS p
JOIN rental AS r ON r.rental_date = p.payment_date
JOIN customer AS c ON c.customer_id = r.customer_id
WHERE p.payment_date >= '2005-07-30' AND p.payment_date < '2005-07-31'
GROUP BY c.customer_id, c.last_name, c.first_name
ORDER BY customer_name, total_amount;
```

Запрос вернул 391 строку. Ниже — первый и последний снимки. Остальные: [2](<indexes/evidence/05-optimized-result-2.png>), [3](<indexes/evidence/05-optimized-result-3.png>), [4](<indexes/evidence/05-optimized-result-4.png>), [5](<indexes/evidence/05-optimized-result-5.png>), [6](<indexes/evidence/05-optimized-result-6.png>), [7](<indexes/evidence/05-optimized-result-7.png>), [8](<indexes/evidence/05-optimized-result-8.png>), [9](<indexes/evidence/05-optimized-result-9.png>). Полный вывод — в [05-optimized-result.txt](<indexes/evidence/05-optimized-result.txt>).

![Начало результата оптимизированного запроса](<indexes/evidence/05-optimized-result-1.png>)

![Окончание результата оптимизированного запроса](<indexes/evidence/05-optimized-result-10.png>)

### Проверка совпадения результатов

Скрипт: [06-equivalence.sql](<indexes/06-equivalence.sql>). Результаты исходного и оптимизированного запросов сохранены во временные таблицы `original_result` и `optimized_result` в сессии `root`; данные базы не менялись. Затем строки сравнивались в обе стороны через `LEFT JOIN ... IS NULL`.

| Проверка | Значение |
| --- | ---: |
| Строк в результате исходного запроса | 391 |
| Строк в результате оптимизированного запроса | 391 |
| Строк исходного результата, которых нет в оптимизированном | 0 |
| Строк оптимизированного результата, которых нет в исходном | 0 |
| Фильмов / разных названий в `film` | 1000 / 1000 |

Результаты совпадают.

![Проверка: по 391 строке, расхождений нет](<indexes/evidence/06-equivalence-1.png>)

![Проверка названий фильмов и соединения по времени](<indexes/evidence/06-equivalence-2.png>)

Вывод проверки — в [06-equivalence.txt](<indexes/evidence/06-equivalence.txt>).

**Замечание о смысле запроса.** Соединение `payment` и `rental` по совпадению времени (`p.payment_date = r.rental_date`) сохранено намеренно, как в исходном запросе. За 30 июля 2005 года 634 платежа дают 642 строки после такого соединения, и в 8 из них аренда имеет другой `rental_id`, чем у платежа. Значит, запрос суммирует платежи клиентов, у которых аренда началась в ту же секунду, что и платёж, а не платежи за конкретные аренды. Соединение по `p.rental_id = r.rental_id` точнее по смыслу, но изменит результат. Это уже другой запрос, а не оптимизация исходного, поэтому в решении его нет.

Индекс `idx_hw1205_payment_date_amount` оставлен в таблице `sakila.payment`.

## Задание 3*

Сравнение основано на документации PostgreSQL 18 (раздел `current`) и MySQL 8.0 с движком InnoDB.

В PostgreSQL шесть встроенных типов индексов: B-tree, Hash, GiST, SP-GiST, GIN и BRIN. Кроме того, PostgreSQL поддерживает частичные индексы, индексы по выражениям и неключевые столбцы `INCLUDE`.

**Есть в PostgreSQL, но нет в MySQL:**

- **GiST** — расширяемая инфраструктура индексов с классами операторов: геометрия, поиск ближайших соседей и другое. В MySQL для геометрии есть индексы `SPATIAL` (R-tree), но это специализированный индекс, а не расширяемый механизм вроде GiST.
- **SP-GiST** — инфраструктура для структур с разбиением пространства: quad-tree, k-d tree, radix tree. Аналога в MySQL нет. `SPATIAL` (R-tree) — другой метод.
- **GIN** — инвертированный индекс для составных значений, например массивов. В MySQL часть таких сценариев закрывают индексы `FULLTEXT` и многозначные индексы по JSON (с версии 8.0.17), но общего метода, как GIN, нет.
- **BRIN** — индекс сводок по диапазонам физических блоков. Полезен, когда значения коррелируют с порядком хранения строк. Аналога в MySQL нет.
- **Частичные индексы** (`CREATE INDEX ... WHERE условие`) индексируют только часть строк. В MySQL такого нет. Префиксный индекс `col(n)` их не заменяет: он индексирует начало значения во всех строках.
- **Неключевые столбцы `INCLUDE`.** В PostgreSQL в индекс можно добавить столбцы, которые хранятся в индексе, но не входят в ключ поиска; уникальность при этом проверяется только по ключу. В MySQL такого синтаксиса нет. Покрывающие индексы при этом в MySQL есть, только все столбцы входят в составной ключ. Так устроен индекс `(payment_date, amount)` из задания 2.

**Hash — с оговоркой.** В PostgreSQL hash-индекс можно создать явно, он поддерживает только сравнение на равенство. В InnoDB пользовательский hash-индекс создать нельзя: InnoDB сам строит адаптивный hash-индекс поверх часто используемых страниц B-tree. В MySQL в целом hash-индексы есть у движков `MEMORY` и `NDB`, поэтому верно говорить именно про InnoDB.

**Есть в обеих СУБД:** B-tree — основной тип индекса в обеих; индексы по выражениям — в MySQL с версии 8.0.13 (functional key parts) с ограничениями на допустимые выражения.

Источники:

- PostgreSQL: [Index Types](https://www.postgresql.org/docs/current/indexes-types.html), [Partial Indexes](https://www.postgresql.org/docs/current/indexes-partial.html), [Indexes on Expressions](https://www.postgresql.org/docs/current/indexes-expressional.html), [Index-Only Scans and Covering Indexes](https://www.postgresql.org/docs/current/indexes-index-only-scans.html).
- MySQL 8.0: [CREATE INDEX Statement](https://dev.mysql.com/doc/refman/8.0/en/create-index.html), [Adaptive Hash Index](https://dev.mysql.com/doc/refman/8.0/en/innodb-adaptive-hash.html), [Optimizing Spatial Analysis](https://dev.mysql.com/doc/refman/8.0/en/optimizing-spatial-analysis.html).
