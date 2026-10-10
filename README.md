# Домашнее задание к занятию «Операции с данными в SQL» — Павел Логачев

## Задание 1

Работа выполнена в том же контейнере с MySQL `8.0.46`, что и задание `12-02-sql-ddl-dml`. Используется восстановленная база `sakila`. Все запросы выполнены от имени `sys_temp` в консольном клиенте `mysql`.

Нужно получить уникальные названия районов, которые начинаются на `K`, заканчиваются на `a` и не содержат пробелов.

Скрипт: [01-districts.sql](<sql-operations/01-districts.sql>).

```sql
SELECT DISTINCT district
FROM address
WHERE district COLLATE utf8mb4_bin LIKE 'K%a'
  AND district NOT LIKE '% %'
ORDER BY district;
```

У столбца `district` используется регистронезависимое сопоставление `utf8mb4_0900_ai_ci`. Выражение `COLLATE utf8mb4_bin` задаёт проверку именно заглавной `K` в начале и строчной `a` в конце. На этих данных обычный `LIKE` без смены сопоставления возвращает те же семь значений.

Результат:

| district |
| --- |
| Kaduna |
| Kalmykia |
| Kanagawa |
| Karnataka |
| Kerala |
| Kitaa |
| Kütahya |

![Семь уникальных районов, соответствующих условиям](<sql-operations/evidence/01-districts.png>)

## Задание 2

Нужно получить платежи за период с 15 по 18 июня 2005 года включительно, сумма которых превышает `10.00`.

Скрипт: [02-payments.sql](<sql-operations/02-payments.sql>).

```sql
SELECT payment_id, customer_id, staff_id, rental_id, amount, payment_date
FROM payment
WHERE payment_date >= '2005-06-15 00:00:00'
  AND payment_date < '2005-06-19 00:00:00'
  AND amount > 10.00
ORDER BY payment_date, payment_id;
```

Верхняя граница задана как начало следующего дня и не включается в интервал. Поэтому запрос учитывает весь день 18 июня, а не только полночь.

Получено семь платежей. Значения `payment_id` в порядке вывода: `908`, `14620`, `13892`, `15313`, `7017`, `8272`, `12888`. У шести платежей сумма `10.99`, у платежа `8272` — `11.99`.

Платёж `12888` от `2005-06-18 08:33:23` включён в результат. При использовании `BETWEEN` с верхней границей `'2005-06-18'` он не попал бы в выборку.

![Платежи дороже 10.00 за 15–18 июня 2005 года включительно](<sql-operations/evidence/02-payments.png>)

## Задание 3

Нужно получить последние пять аренд фильмов.

Скрипт: [03-last-rentals.sql](<sql-operations/03-last-rentals.sql>).

```sql
SELECT rental_id, rental_date, inventory_id, customer_id, return_date, staff_id
FROM rental
ORDER BY rental_date DESC, rental_id DESC
LIMIT 5;
```

Основная сортировка — по дате аренды от новых записей к старым. При совпадении дат используется `rental_id DESC`, чтобы порядок был однозначным.

Результат:

| rental_id | rental_date | inventory_id | customer_id | return_date | staff_id |
| ---: | --- | ---: | ---: | --- | ---: |
| 15966 | 2006-02-14 15:16:03 | 4472 | 374 | `NULL` | 1 |
| 15894 | 2006-02-14 15:16:03 | 4416 | 168 | `NULL` | 1 |
| 15875 | 2006-02-14 15:16:03 | 3611 | 41 | `NULL` | 1 |
| 15867 | 2006-02-14 15:16:03 | 837 | 505 | `NULL` | 2 |
| 15862 | 2006-02-14 15:16:03 | 925 | 215 | `NULL` | 1 |

У всех пяти записей одинаковое значение `rental_date`, поэтому дополнительная сортировка по `rental_id` существенна.

![Последние пять аренд с дополнительной сортировкой по rental_id](<sql-operations/evidence/03-last-rentals.png>)

## Задание 4

Нужно одним запросом получить активных покупателей с именами Kelly или Willie, перевести фамилии и имена в нижний регистр и заменить `ll` на `pp` в именах.

Скрипт: [04-active-customers.sql](<sql-operations/04-active-customers.sql>).

```sql
SELECT LOWER(last_name) AS last_name,
       REPLACE(LOWER(first_name), 'll', 'pp') AS first_name
FROM customer
WHERE active = 1 AND first_name IN ('Kelly', 'Willie')
ORDER BY last_name, first_name;
```

`LOWER` применяется к фамилии и имени. Замена `ll` на `pp` выполняется только в имени, после перевода в нижний регистр.

Результат — четыре покупателя:

| last_name | first_name |
| --- | --- |
| howell | wippie |
| knott | keppy |
| markham | wippie |
| torres | keppy |

![Активные покупатели Kelly и Willie после преобразования имён и фамилий](<sql-operations/evidence/04-active-customers.png>)

## Задание 5*

Нужно разделить Email каждого покупателя на две колонки: часть до `@` и часть после `@`.

Скрипт: [05-email-split.sql](<sql-operations/05-email-split.sql>).

```sql
SELECT SUBSTRING_INDEX(email, '@', 1) AS email_local,
       SUBSTRING_INDEX(email, '@', -1) AS email_domain
FROM customer
ORDER BY customer_id;
```

В этой базе каждый Email содержит ровно один символ `@`, значений `NULL` нет. Полный запрос не содержит `LIMIT` и возвращает 599 строк — по одной для каждого покупателя.

Первая строка результата:

| email_local | email_domain |
| --- | --- |
| MARY.SMITH | sakilacustomer.org |

На скриншоте показаны только первые десять строк. Для него использована [версия запроса с LIMIT 10](<sql-operations/05-email-split-preview.sql>).

![Первые десять строк после разделения Email на две колонки](<sql-operations/evidence/05-email-split-preview.png>)

Все 599 строк сохранены в [полном текстовом выводе](<sql-operations/evidence/05-email-split.txt>).

## Задание 6*

Нужно доработать предыдущий запрос: сделать первую букву заглавной, остальные — строчными.

Преобразование выполнено отдельно для каждой из двух частей Email. Сначала адрес разделяется в CTE `email_parts`, затем первый символ каждой части переводится в верхний регистр, а оставшаяся строка — в нижний.

Скрипт: [06-email-capitalize.sql](<sql-operations/06-email-capitalize.sql>).

```sql
WITH email_parts AS (
  SELECT customer_id, SUBSTRING_INDEX(email, '@', 1) AS email_local,
         SUBSTRING_INDEX(email, '@', -1) AS email_domain
  FROM customer
)
SELECT CONCAT(UPPER(LEFT(email_local, 1)),
              LOWER(SUBSTRING(email_local, 2))) AS email_local,
       CONCAT(UPPER(LEFT(email_domain, 1)),
              LOWER(SUBSTRING(email_domain, 2))) AS email_domain
FROM email_parts
ORDER BY customer_id;
```

Полный запрос не содержит `LIMIT` и возвращает 599 строк.

Первая строка результата:

| email_local | email_domain |
| --- | --- |
| Mary.smith | Sakilacustomer.org |

Заглавной становится только первая буква каждой части: в `Mary.smith` буква после точки остаётся строчной.

На скриншоте показаны первые десять строк, полученные [версией запроса с LIMIT 10](<sql-operations/06-email-capitalize-preview.sql>).

![Первые десять строк с заглавной первой буквой каждой части Email](<sql-operations/evidence/06-email-capitalize-preview.png>)

Все 599 строк сохранены в [полном текстовом выводе](<sql-operations/evidence/06-email-capitalize.txt>).

Текстовые выводы всех запросов находятся в [каталоге evidence](<sql-operations/evidence/>).
