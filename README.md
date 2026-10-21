# Домашнее задание к занятию «Расширенные возможности SQL» — Павел Логачев

## Задание 1

Работа выполнена в том же контейнере с MySQL `8.0.46`, что и задание `12-02-sql-ddl-dml`. Используется восстановленная ранее база `sakila`. Все запросы выполнены от имени `sys_temp` в консольном клиенте `mysql`.

Нужно одним запросом найти магазин, в котором обслуживается более 300 покупателей, и вывести фамилию и имя сотрудника этого магазина, город магазина и количество закреплённых за ним покупателей.

Скрипт: [01-store-customers.sql](<sql-part2/01-store-customers.sql>).

```sql
SELECT s.store_id, st.last_name, st.first_name, ci.city,
       cc.customer_count
FROM store AS s
JOIN (SELECT store_id, COUNT(*) AS customer_count
      FROM customer GROUP BY store_id HAVING COUNT(*) > 300) AS cc
  ON cc.store_id = s.store_id
JOIN staff AS st ON st.store_id = s.store_id
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS ci ON ci.city_id = a.city_id
ORDER BY s.store_id, st.staff_id;
```

Покупатели подсчитываются в подзапросе: таблица `customer` группируется по `store_id`, а условие `HAVING COUNT(*) > 300` оставляет только подходящий магазин. Подзапрос посчитан до присоединения сотрудников, поэтому соединение со `staff` не меняет число покупателей. Сотрудники выбираются по `staff.store_id`. Город берётся из адреса магазина, а не сотрудника.

Результат:

| store_id | last_name | first_name | city | customer_count |
| ---: | --- | --- | --- | ---: |
| 1 | Hillyer | Mike | Lethbridge | 326 |

Контрольный подсчёт по всем магазинам: в магазине 1 — 326 покупателей, в магазине 2 — 273, всего 599.

![Магазин 1: сотрудник Hillyer Mike, город Lethbridge, 326 покупателей](<sql-part2/evidence/01-store-customers.png>)

## Задание 2

Нужно получить количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

Скрипт: [02-long-films.sql](<sql-part2/02-long-films.sql>).

```sql
SELECT COUNT(*) AS films_above_average,
       (SELECT AVG(length) FROM film) AS average_length_minutes
FROM film WHERE length > (SELECT AVG(length) FROM film);
```

Сравнение строгое (`>`): фильмы, длительность которых равна средней, не учитываются. Для наглядности рядом выведена сама средняя длительность.

Результат:

| films_above_average | average_length_minutes |
| ---: | ---: |
| 489 | 115.2720 |

![489 фильмов длиннее средней продолжительности 115.2720 минуты](<sql-part2/evidence/02-long-films.png>)

## Задание 3

Нужно найти месяц с наибольшей суммой платежей и добавить к нему количество аренд за этот месяц.

Скрипт: [03-top-payment-month.sql](<sql-part2/03-top-payment-month.sql>).

```sql
WITH monthly_payments AS (
  SELECT CAST(DATE_FORMAT(payment_date, '%Y-%m-01') AS DATE) AS month_start,
         SUM(amount) AS total_amount
  FROM payment GROUP BY month_start
), ranked AS (
  SELECT month_start, total_amount,
         DENSE_RANK() OVER (ORDER BY total_amount DESC) AS revenue_rank
  FROM monthly_payments
)
SELECT DATE_FORMAT(m.month_start, '%Y-%m') AS payment_month,
       m.total_amount,
       (SELECT COUNT(*) FROM rental AS r
        WHERE r.rental_date >= m.month_start
          AND r.rental_date < m.month_start + INTERVAL 1 MONTH) AS rentals
FROM ranked AS m WHERE m.revenue_rank = 1
ORDER BY m.month_start;
```

Месяц определяется по году и месяцу `payment_date`, а не только по номеру месяца. Сумма платежей считается по одной таблице `payment`, без соединения с арендами, поэтому JOIN не может размножить платежи. Аренды подсчитываются отдельным подзапросом по `rental_date` за тот же месяц: с первого числа включительно до первого числа следующего месяца, не включая его. `DENSE_RANK` вернёт все месяцы, если максимальная сумма окажется одинаковой у нескольких. На этих данных такой месяц один.

Результат:

| payment_month | total_amount | rentals |
| --- | ---: | ---: |
| 2005-07 | 28368.91 | 6709 |

Суммы платежей по всем месяцам из контрольного запроса:

| Месяц | Сумма платежей | Количество платежей |
| --- | ---: | ---: |
| 2005-07 | 28368.91 | 6709 |
| 2005-08 | 24070.14 | 5686 |
| 2005-06 | 9629.89 | 2311 |
| 2005-05 | 4823.44 | 1156 |
| 2006-02 | 514.18 | 182 |

![Июль 2005 года: сумма платежей 28368.91, аренд 6709](<sql-part2/evidence/03-top-payment-month.png>)

## Задание 4*

Нужно посчитать количество продаж каждого продавца и добавить колонку «Премия»: «Да», если продаж больше 8000, иначе «Нет».

Продажей в решении считается платёж, который провёл сотрудник, то есть запись в `payment` с его `staff_id`.

Скрипт: [04-staff-bonus.sql](<sql-part2/04-staff-bonus.sql>).

```sql
SELECT s.staff_id, s.last_name, s.first_name,
       COUNT(p.payment_id) AS sales_count,
       CASE WHEN COUNT(p.payment_id) > 8000 THEN 'Да' ELSE 'Нет' END AS Премия
FROM staff AS s LEFT JOIN payment AS p ON p.staff_id = s.staff_id
GROUP BY s.staff_id, s.last_name, s.first_name
ORDER BY s.staff_id;
```

`LEFT JOIN` сохраняет в результате сотрудника, у которого нет ни одного платежа. Порог строгий: ровно 8000 продаж премии не дают.

Результат:

| staff_id | last_name | first_name | sales_count | Премия |
| ---: | --- | --- | ---: | --- |
| 1 | Hillyer | Mike | 8054 | Да |
| 2 | Stephens | Jon | 7990 | Нет |

Вместе 8054 + 7990 = 16044, это все платежи в базе.

Замечание: если считать продажами аренды (`rental.staff_id`), получится 8040 и 8004, и премию получили бы оба сотрудника.

![Продажи сотрудников и колонка «Премия»](<sql-part2/evidence/04-staff-bonus.png>)

## Задание 5*

Нужно найти фильмы, которые ни разу не брали в аренду.

Скрипт: [05-never-rented-films.sql](<sql-part2/05-never-rented-films.sql>).

```sql
SELECT f.film_id, f.title
FROM film AS f
WHERE NOT EXISTS (
  SELECT 1 FROM inventory AS i JOIN rental AS r ON r.inventory_id = i.inventory_id
  WHERE i.film_id = f.film_id
)
ORDER BY f.film_id;
```

Фильм попадает в результат, если ни для одного его экземпляра из `inventory` нет записи в `rental`. Фильм без экземпляров тоже попадает в результат: его тоже ни разу не брали в аренду.

Запрос вернул 42 фильма. Контрольный запрос показал, что у всех 42 нет ни одного экземпляра в `inventory`. Все фильмы, у которых экземпляры есть, хотя бы раз арендовали.

Список (`film_id` и название): 14 ALICE FANTASIA, 33 APOLLO TEEN, 36 ARGONAUTS TOWN, 38 ARK RIDGEMONT, 41 ARSENIC INDEPENDENCE, 87 BOONDOCK BALLROOM, 108 BUTCH PANTHER, 128 CATCH AMISTAD, 144 CHINATOWN GLADIATOR, 148 CHOCOLATE DUCK, 171 COMMANDMENTS EXPRESS, 192 CROSSING DIVORCE, 195 CROWDS TELEMARK, 198 CRYSTAL BREAKING, 217 DAZED PUNK, 221 DELIVERANCE MULHOLLAND, 318 FIREHOUSE VIETNAM, 325 FLOATS GARDEN, 332 FRANKENSTEIN STRANGER, 359 GLADIATOR WESTWARD, 386 GUMP DATE, 404 HATE HANDICAP, 419 HOCUS FRIDA, 495 KENTUCKIAN GIANT, 497 KILL BROTHERHOOD, 607 MUPPET MILE, 642 ORDER BETRAYED, 669 PEARL DESTINY, 671 PERDITION FARGO, 701 PSYCHO SHRUNK, 712 RAIDERS ANTITRUST, 713 RAINBOW SHOCK, 742 ROOF CHAMPION, 801 SISTER FREDDY, 802 SKY MIRACLE, 860 SUICIDES SILENCE, 874 TADPOLE PARK, 909 TREASURE COMMAND, 943 VILLAIN DESPERATE, 950 VOLUME HOUSE, 954 WAKE JAWS, 955 WALLS ARTIST.

Полный вывод в виде таблицы — в [05-never-rented-films.txt](<sql-part2/evidence/05-never-rented-films.txt>).

![Запрос фильмов, которые ни разу не брали в аренду, начало вывода](<sql-part2/evidence/05-never-rented-films-1.png>)

![Окончание списка: 42 фильма](<sql-part2/evidence/05-never-rented-films-2.png>)

---

Контрольные запросы, на которые ссылаются задания 1, 3, 4* и 5*, лежат в скрипте [06-validation.sql](<sql-part2/06-validation.sql>). Они считают покупателей по магазинам, суммы и количество платежей по месяцам, аренды по сотрудникам, а также фильмы без аренд и без экземпляров. Их вывод сохранён в [06-validation.txt](<sql-part2/evidence/06-validation.txt>), начало снято на [первом снимке](<sql-part2/evidence/06-validation-1.png>).

![Вывод контрольных запросов](<sql-part2/evidence/06-validation-2.png>)

Текстовые выводы всех запросов находятся в [каталоге evidence](<sql-part2/evidence/>).
