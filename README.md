# Домашнее задание к занятию «Работа с данными (DDL/DML)» — Павел Логачев

## Задание 1

### Запуск MySQL и создание пользователя

Для работы использован Docker-контейнер из образа `mysql:8.0`. Запрос `SELECT VERSION()` вернул версию `8.0.46`. Команды выполнены в консольном клиенте `mysql`; на скриншотах показан вывод терминала.

Создана учётная запись `sys_temp@localhost` и получен список пользователей. Пароль в скриптах — временный пароль локального учебного контейнера.

Скрипт: [01-users.sql](<sql-ddl-dml/01-users.sql>).

```sql
SELECT VERSION() AS mysql_version;
CREATE USER 'sys_temp'@'localhost' IDENTIFIED BY 'NetologyTempLocal_2026';
SELECT User, Host, plugin FROM mysql.user ORDER BY User, Host;
```

В списке шесть учётных записей: `mysql.infoschema`, `mysql.session`, `mysql.sys`, `root@%`, `root@localhost` и `sys_temp@localhost`.

При создании у `sys_temp` использовался плагин `caching_sha2_password`. На скриншоте список пользователей показан уже после переключения на `mysql_native_password`; команда переключения приведена ниже.

![Версия MySQL 8.0.46 и список из шести учётных записей](<sql-ddl-dml/evidence/01-users-version.png>)

### Выдача прав и смена плагина аутентификации

Пользователю `sys_temp@localhost` выданы все глобальные привилегии с правом их передачи. Затем плагин аутентификации изменён на `mysql_native_password`.

Скрипт: [02-grant-all.sql](<sql-ddl-dml/02-grant-all.sql>).

```sql
GRANT ALL PRIVILEGES ON *.* TO 'sys_temp'@'localhost' WITH GRANT OPTION;
SHOW GRANTS FOR 'sys_temp'@'localhost'\G
ALTER USER 'sys_temp'@'localhost' IDENTIFIED WITH mysql_native_password
  BY 'NetologyTempLocal_2026';
SELECT User, Host, plugin FROM mysql.user WHERE User = 'sys_temp';
```

После `GRANT ALL PRIVILEGES` команда `SHOW GRANTS` вернула две строки: глобальные статические привилегии и глобальные динамические привилегии. В обеих строках указан `WITH GRANT OPTION`.

![Глобальные привилегии sys_temp после GRANT ALL PRIVILEGES](<sql-ddl-dml/evidence/02-all-grants.png>)

### Повторное подключение и восстановление Sakila

После смены плагина выполнено повторное подключение от имени `sys_temp`. Значения `USER()` и `CURRENT_USER()` совпали: `sys_temp@localhost`.

![Подключение от имени sys_temp и плагин mysql_native_password](<sql-ddl-dml/evidence/03-sys-temp-login.png>)

При выполнении работы ссылка на [ZIP-архив из задания](<https://downloads.mysql.com/docs/sakila-db.zip>) возвращала HTTP 403. Вместо неё использован тот же официальный архив в формате [tar.gz](<https://downloads.mysql.com/docs/sakila-db.tar.gz>). Файлы схемы и данных Sakila 1.5 восстановлены без изменений.

Скрипт [03-restore.sql](<sql-ddl-dml/03-restore.sql>) выполнен от имени `sys_temp`:

```sql
SELECT USER() AS connected_as, CURRENT_USER() AS authenticated_as;
SOURCE /tmp/sakila-db/sakila-schema.sql;
SOURCE /tmp/sakila-db/sakila-data.sql;
USE sakila;
SHOW FULL TABLES;
SELECT TABLE_TYPE, COUNT(*) AS objects
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila'
GROUP BY TABLE_TYPE ORDER BY TABLE_TYPE;
SELECT (SELECT COUNT(*) FROM customer) AS customers,
       (SELECT COUNT(*) FROM rental) AS rentals,
       (SELECT COUNT(*) FROM payment) AS payments;
```

Восстановление завершилось без ошибок. Список таблиц и представлений получен командой `SHOW FULL TABLES`.

![Список таблиц и представлений базы sakila](<sql-ddl-dml/evidence/04-sakila-tables.png>)

В базе 23 объекта: 16 базовых таблиц (`BASE TABLE`) и 7 представлений (`VIEW`).

Контрольные количества строк:

| Таблица | Количество строк |
| --- | ---: |
| `customer` | 599 |
| `rental` | 16044 |
| `payment` | 16044 |

![Количество базовых таблиц, представлений и строк в контрольных таблицах](<sql-ddl-dml/evidence/05-sakila-counts.png>)

## Задание 2

Получен список первичных ключей всех базовых таблиц `sakila`. Представления исключены условием `TABLE_TYPE = 'BASE TABLE'`. Для составных ключей перечислены все столбцы в порядке их включения в ключ.

Скрипт: [04-primary-keys.sql](<sql-ddl-dml/04-primary-keys.sql>).

```sql
SELECT t.TABLE_NAME AS table_name,
       GROUP_CONCAT(k.COLUMN_NAME ORDER BY k.ORDINAL_POSITION
                    SEPARATOR ', ') AS primary_key_columns
FROM information_schema.TABLES AS t
JOIN information_schema.TABLE_CONSTRAINTS AS c
  ON c.TABLE_SCHEMA = t.TABLE_SCHEMA AND c.TABLE_NAME = t.TABLE_NAME
 AND c.CONSTRAINT_TYPE = 'PRIMARY KEY'
JOIN information_schema.KEY_COLUMN_USAGE AS k
  ON k.CONSTRAINT_SCHEMA = c.CONSTRAINT_SCHEMA
 AND k.TABLE_NAME = c.TABLE_NAME AND k.CONSTRAINT_NAME = c.CONSTRAINT_NAME
WHERE t.TABLE_SCHEMA = 'sakila' AND t.TABLE_TYPE = 'BASE TABLE'
GROUP BY t.TABLE_NAME ORDER BY t.TABLE_NAME;
```

Результат — 16 таблиц:

| Таблица | Первичный ключ |
| --- | --- |
| `actor` | `actor_id` |
| `address` | `address_id` |
| `category` | `category_id` |
| `city` | `city_id` |
| `country` | `country_id` |
| `customer` | `customer_id` |
| `film` | `film_id` |
| `film_actor` | `actor_id`, `film_id` |
| `film_category` | `film_id`, `category_id` |
| `film_text` | `film_id` |
| `inventory` | `inventory_id` |
| `language` | `language_id` |
| `payment` | `payment_id` |
| `rental` | `rental_id` |
| `staff` | `staff_id` |
| `store` | `store_id` |

![Запрос первичных ключей и результат для 16 базовых таблиц](<sql-ddl-dml/evidence/06-primary-keys.png>)

Таблица также сохранена отдельно: [primary-keys.md](<sql-ddl-dml/primary-keys.md>).

## Задание 3*

У пользователя `sys_temp@localhost` отозваны права `INSERT`, `UPDATE` и `DELETE` для базы `sakila`.

В задании 1 права были выданы глобально — на `*.*`. Чтобы отозвать такие права только для одной базы, использован механизм частичного отзыва привилегий MySQL 8.0: включён параметр `partial_revokes`, затем выполнен `REVOKE`.

Скрипт [05-revoke-dml.sql](<sql-ddl-dml/05-revoke-dml.sql>) выполнен от имени `root`:

```sql
SET PERSIST partial_revokes = ON;
REVOKE INSERT, UPDATE, DELETE ON sakila.* FROM 'sys_temp'@'localhost';
SHOW GRANTS FOR 'sys_temp'@'localhost'\G
SELECT @@GLOBAL.partial_revokes AS partial_revokes;
```

Значение `@@GLOBAL.partial_revokes` — `1`. В выводе `SHOW GRANTS` появилась третья строка:

```sql
REVOKE INSERT, UPDATE, DELETE ON `sakila`.* FROM `sys_temp`@`localhost`
```

![Частичный отзыв DML-привилегий и итоговый список прав sys_temp](<sql-ddl-dml/evidence/07-revoked-grants.png>)

Результат проверен от имени `sys_temp` скриптами [06-check-read.sql](<sql-ddl-dml/06-check-read.sql>) и [07-check-denied.sql](<sql-ddl-dml/07-check-denied.sql>):

- `INSERT`, `UPDATE` и `DELETE` в базе `sakila` завершаются ошибкой `ERROR 1142` — выполнение команды запрещено.
- `SELECT` из `customer` доступен; проверка количества строк возвращает `599`.

Ограничение касается трёх указанных DML-привилегий в `sakila`; остальные права из задания 1 сохранены.

![INSERT, UPDATE и DELETE запрещены, чтение customer доступно](<sql-ddl-dml/evidence/08-dml-denied-read-allowed.png>)

Текстовые протоколы выполнения сохранены в [каталоге evidence](<sql-ddl-dml/evidence/>).
