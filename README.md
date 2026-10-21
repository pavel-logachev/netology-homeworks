# Домашнее задание к занятию «Репликация и масштабирование. Часть 1» — Павел Логачев

Задания 2 и 3* выполнены на MySQL 8.0.46 (образ `mysql:8.0`) в Docker. Подняты две независимые пары серверов, в обеих включены GTID и binlog в формате ROW. Всё, что нужно для повторения, лежит в папке [replication](replication/):

- [master-slave/](replication/master-slave/) — Compose, конфигурации и SQL к заданию 2;
- [master-master/](replication/master-master/) — то же к заданию 3*;
- [start-lab.ps1](replication/start-lab.ps1) — запуск обеих пар и клиентского контейнера;
- [docker-compose.evidence.yml](replication/docker-compose.evidence.yml) — клиентский контейнер `nt-repl-client` с веб-терминалом, из которого сняты скриншоты;
- [verify-lab.ps1](replication/verify-lab.ps1) — итоговая автоматическая проверка, её вывод в [assertions.txt](replication/evidence/assertions.txt);
- [evidence/](replication/evidence/) — скриншоты; рядом с каждым PNG лежит текстовая копия того же вывода (`.txt`);
- [terminal/](replication/terminal/) — вспомогательные функции и команды клиентского терминала.

## Задание 1

> На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия. Ответить в свободной форме.

**Master-slave (в документации MySQL — source → replica)**

- Запись принимает только один сервер — master. Slave получает изменения из его бинарного журнала и применяет у себя, поток данных идёт в одну сторону.
- Slave подходят для чтения, аналитики, резервного копирования и географического распределения данных: эта нагрузка уходит с master.
- По умолчанию репликация в MySQL асинхронная. Если master подтвердил commit, это ещё не значит, что slave его применил, поэтому возможны отставание и чтение устаревших данных со slave.
- Чтобы на slave не писали напрямую, его переводят в `read_only` / `super_read_only` (так сделано в задании 2).
- Сама схема не переключает роли автоматически. При отказе master нужно выбрать новый source, убедиться, что он применил свой relay log, перенастроить на него остальные реплики и перенаправить клиентов. Реплики при этом могут отставать друг от друга по-разному.

**Master-master**

- Два сервера реплицируют друг друга, и каждый одновременно source и replica для соседа. По сути это две обычные асинхронные связи в противоположных направлениях. Запись принимают оба узла.
- У каждого сервера должен быть уникальный `server_id`. Чтобы ключи `AUTO_INCREMENT` не совпадали, задают `auto_increment_increment` и `auto_increment_offset`: каждый узел получает свою последовательность (в задании 3* у одного нечётные id, у другого чётные).
- Эти параметры отвечают только за генерацию `AUTO_INCREMENT`. Конфликты `UPDATE`/`DELETE` или уникальных ключей, когда одни и те же данные меняют на обоих узлах, они не разрешают. Это приходится решать на стороне приложения: заранее распределять, какие данные пишутся на каком узле, маршрутизировать записи и координировать конфликтующие изменения.
- С GTID у реплицированной транзакции сохраняется её идентификатор, а транзакция с уже выполненным GTID при повторном получении пропускается. Так события не ходят по кругу, но разные транзакции, конфликтующие по данным, GTID не согласует.
- Это не Group Replication и не синхронный кластер. Отставание возможно в обе стороны. Два узла для записи сами по себе не гарантируют линейного масштабирования записи и не заменяют процедуру переключения: изоляцию отказавшего узла (fencing), маршрутизацию клиентов и проверку актуальности данных.

**Коротко**

| | Master-slave | Master-master |
|---|---|---|
| Кто принимает запись | только master | оба узла |
| Направление репликации | одно: master → slave | два встречных канала |
| `AUTO_INCREMENT` | обычный | разнесён через `auto_increment_increment` / `auto_increment_offset` |
| Конфликты записи | между узлами не возникают, пишет один сервер | возможны, их разрешение — задача приложения |
| Типичное применение | масштабирование чтения, аналитика, резервные копии | две точки записи при заранее разделённых или согласованных изменениях |
| Общее | асинхронная репликация, возможна задержка, автоматического failover нет | то же |

Источники (официальное руководство MySQL 8.0):

- [Chapter 19 Replication](https://dev.mysql.com/doc/refman/8.0/en/replication.html)
- [Replication Source Options and Variables](https://dev.mysql.com/doc/refman/8.0/en/replication-options-source.html)
- [GTID Format and Storage](https://dev.mysql.com/doc/refman/8.0/en/replication-gtids-concepts.html)
- [Switching Sources During Failover](https://dev.mysql.com/doc/refman/8.0/en/replication-solutions-switch.html)

## Задание 2

> Выполните конфигурацию master-slave репликации, примером можно пользоваться из лекции. Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.

### Стенд

Два контейнера из [master-slave/docker-compose.yml](replication/master-slave/docker-compose.yml): `nt-repl-master` (`server_id` 101) и `nt-repl-replica` (`server_id` 102). Порты опубликованы только на `127.0.0.1` (13310 и 13311), данные хранятся в именованных томах.

Конфигурация master — [master.cnf](replication/master-slave/conf/master.cnf):

```ini
[mysqld]
log_bin=mysql-bin
relay_log=relay-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
log_replica_updates=ON
skip_replica_start=ON
sync_binlog=1
innodb_flush_log_at_trx_commit=1
server-id=101
read_only=OFF
super_read_only=OFF
```

[replica.cnf](replication/master-slave/conf/replica.cnf) отличается тремя строками:

```ini
server-id=102
read_only=ON
super_read_only=ON
```

Docker Desktop не получил общего доступа к папке проекта (file sharing), поэтому конфигурации не монтируются в контейнеры, а копируются в них. [start-lab.ps1](replication/start-lab.ps1) поднимает обе пары, кладёт каждый `.cnf` через `docker cp` в `/etc/mysql/conf.d/replication.cnf`, ставит права 444 и перезапускает `mysqld`. Одного `docker compose up` для повторения недостаточно, нужен этот скрипт; если контейнер пересоздан, конфигурацию нужно скопировать заново. Скрипт также запускает клиентский контейнер с веб-терминалом ttyd. Путь к бинарнику ttyd передаётся параметром `-TtydBinary`, сам бинарник в репозиторий не входит.

Пароли `nt-repl-only` и `nt-repl-lab-only` придуманы для одноразового учебного стенда. TLS для репликации не настраивался.

### Настройка

SQL-файлы выполнялись из клиентского контейнера утилитой `mysql` под `root`:

1. На master — [01-user.sql](replication/master-slave/sql/01-user.sql): пользователь `repl` с правом `REPLICATION SLAVE`. Учётная запись создаётся при `sql_log_bin=0` и в binlog не попадает.
2. На replica — [02-replica.sql](replication/master-slave/sql/02-replica.sql):

```sql
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='nt-repl-master', SOURCE_PORT=3306,
  SOURCE_USER='repl', SOURCE_PASSWORD='nt-repl-only',
  SOURCE_AUTO_POSITION=1, GET_SOURCE_PUBLIC_KEY=1,
  SOURCE_CONNECT_RETRY=2;
START REPLICA;
```

Позиция определяется по GTID (`SOURCE_AUTO_POSITION=1`), поэтому имя файла binlog и смещение указывать не нужно.

Конфигурация master: содержимое `master.cnf` и фактические значения переменных `mysqld` — версия 8.0.46, `server_id` 101, `read_only` / `super_read_only` = 0 / 0, `log_bin` = 1, формат ROW, `gtid_mode` и `enforce_gtid_consistency` = ON.

![Конфигурация и переменные master](<replication/evidence/config-master.png>)

Конфигурация replica: те же параметры binlog и GTID, `server_id` 102, `read_only` / `super_read_only` = 1 / 1.

![Конфигурация и переменные replica](<replication/evidence/config-replica.png>)

На этих скриншотах показана копия `.cnf` из клиентского контейнера, а значения переменных запрошены у самих серверов. Совпадение файлов внутри серверов с файлами из репозитория отдельно проверил [verify-lab.ps1](replication/verify-lab.ps1): он прочитал `/etc/mysql/conf.d/*.cnf` в каждом из четырёх контейнеров и сравнил с `.cnf` в репозитории. Результат — в [assertions.txt](replication/evidence/assertions.txt).

Текст выполненных `01-user.sql` и `02-replica.sql`, права пользователя (`` GRANT REPLICATION SLAVE ON *.* TO `repl`@`%` ``) и состояние канала на replica: `Source_Host` = `nt-repl-master`, `Replica_IO_Running` / `Replica_SQL_Running` = Yes / Yes, `Seconds_Behind_Source` = 0, `Last_IO_Errno` и `Last_SQL_Errno` = 0, `Source_Server_Id` = 101, `Auto_Position` = 1. Снимок сделан после первой записи на master, поэтому GTID-наборы здесь `…:1-3`.

![Пользователь репликации и канал на replica](<replication/evidence/ms-channel-config.png>)

### Проверка

На master выполнен [03-write-master.sql](replication/master-slave/sql/03-write-master.sql): создана база `replication_demo` с таблицей `messages` (InnoDB) и записаны две строки. На скриншоте — текст скрипта, таблица на master, затем `WAIT_FOR_EXECUTED_GTID_SET` на replica (вернула 0, то есть replica применила все транзакции master) и та же таблица на replica: строки 1 «Hello from Pavel Logachev» и 2 «GTID replication works» совпадают.

![База и таблица созданы на master и появились на replica](<replication/evidence/ms-verify.png>)

Ещё одна запись на master — [05-write-master.sql](replication/master-slave/sql/05-write-master.sql): `LAST_INSERT_ID()` = 3, ожидание GTID на replica вернуло 0, и на обоих серверах одинаковые три строки, третья — «Live terminal check».

![Новая строка на master появилась на replica](<replication/evidence/ms-live-write.png>)

Попытка записи на replica под `root` — [04-write-replica.sql](replication/master-slave/sql/04-write-replica.sql). Сервер с `read_only` / `super_read_only` = 1 / 1 отклонил её с ошибкой `ERROR 1290 (HY000) ... --super-read-only option`, клиент завершился с кодом 1, в таблице по-прежнему 3 строки.

![Запись на replica отклонена](<replication/evidence/ms-readonly.png>)

Итоговое состояние. `SHOW MASTER STATUS` на master: файл `mysql-bin.000001`, позиция 1403, `Executed_Gtid_Set` = `a722a296-cd38-11f1-926f-aafb724e3047:1-4`. На replica: оба потока Yes / Yes, отставание 0, ошибок нет, `Source_Server_Id` = 101, `Retrieved_Gtid_Set` и `Executed_Gtid_Set` совпадают с набором master (`…:1-4`), `Auto_Position` = 1. Полный вывод `SHOW REPLICA STATUS\G` — в [full-status-replica.txt](replication/evidence/full-status-replica.txt).

![Состояние binlog на master и канала на replica](<replication/evidence/ms-status.png>)

Итог: master работает в режиме записи, replica — только на чтение и получает все изменения master. Репликация асинхронная, нулевое отставание — снимок на момент проверки. Переключение при отказе master и восстановление после сбоя не проверялись.

## Задание 3*

> Выполните конфигурацию master-master репликации. Произведите проверку. Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.

### Стенд

Отдельная пара из [master-master/docker-compose.yml](replication/master-master/docker-compose.yml): `nt-repl-mm1` (`server_id` 201) и `nt-repl-mm2` (`server_id` 202). Порты опубликованы только на `127.0.0.1` (13312 и 13313). Конфигурации доставляются тем же [start-lab.ps1](replication/start-lab.ps1), что и в задании 2.

[mm1.cnf](replication/master-master/conf/mm1.cnf):

```ini
[mysqld]
log_bin=mysql-bin
relay_log=relay-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
log_replica_updates=ON
skip_replica_start=ON
sync_binlog=1
innodb_flush_log_at_trx_commit=1
server-id=201
auto_increment_increment=2
auto_increment_offset=1
read_only=OFF
super_read_only=OFF
```

[mm2.cnf](replication/master-master/conf/mm2.cnf) отличается двумя строками:

```ini
server-id=202
auto_increment_offset=2
```

Оба узла доступны для записи. При шаге 2 mm1 выдаёт нечётные id, mm2 — чётные.

### Настройка

1. На каждом узле отдельно — [01-user.sql](replication/master-master/sql/01-user.sql): пользователь `repl` с правом `REPLICATION SLAVE`, создаётся при `sql_log_bin=0`, поэтому не реплицируется на соседний узел.
2. На mm1 — [02-mm1.sql](replication/master-master/sql/02-mm1.sql), источник — mm2:

```sql
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='nt-repl-mm2', SOURCE_PORT=3306,
  SOURCE_USER='repl', SOURCE_PASSWORD='nt-repl-only',
  SOURCE_AUTO_POSITION=1, GET_SOURCE_PUBLIC_KEY=1,
  SOURCE_CONNECT_RETRY=2;
START REPLICA;
```

3. На mm2 — [02-mm2.sql](replication/master-master/sql/02-mm2.sql), то же со встречным источником `SOURCE_HOST='nt-repl-mm1'`.
4. Только на mm1 — [03-schema-mm1.sql](replication/master-master/sql/03-schema-mm1.sql): база `circular_demo` и таблица `messages`. На mm2 они попали через репликацию.

Конфигурация mm1: `server_id` 201, `read_only` / `super_read_only` = 0 / 0, ROW, GTID ON, `auto_increment_increment` = 2, `auto_increment_offset` = 1.

![Конфигурация и переменные mm1](<replication/evidence/config-mm1.png>)

Конфигурация mm2: `server_id` 202, `read_only` / `super_read_only` = 0 / 0, ROW, GTID ON, `auto_increment_increment` = 2, `auto_increment_offset` = 2.

![Конфигурация и переменные mm2](<replication/evidence/config-mm2.png>)

Пользователь репликации на обоих узлах: текст `01-user.sql` и `SHOW GRANTS` на mm1 и mm2 — `` GRANT REPLICATION SLAVE ON *.* TO `repl`@`%` ``.

![Пользователь repl на mm1 и mm2](<replication/evidence/mm-users.png>)

Встречные каналы и схема: текст `02-mm1.sql`, `02-mm2.sql` и `03-schema-mm1.sql`, затем `WAIT_FOR_EXECUTED_GTID_SET` в обе стороны (mm1 → mm2 и mm2 → mm1), оба раза 0.

![Встречные каналы репликации и создание схемы на mm1](<replication/evidence/mm-channel-config.png>)

### Проверка

Записи поочерёдно на обоих узлах — [04-write-mm1.sql](replication/master-master/sql/04-write-mm1.sql), [05-write-mm2.sql](replication/master-master/sql/05-write-mm2.sql), [06-write-mm1.sql](replication/master-master/sql/06-write-mm1.sql), [07-write-mm2.sql](replication/master-master/sql/07-write-mm2.sql). Ожидание GTID в обе стороны вернуло 0, и на mm1 и mm2 видны одинаковые строки: id 1 и 3 с `origin` = mm1, id 2 и 4 с `origin` = mm2.

![Записи с обоих узлов видны на mm1 и mm2](<replication/evidence/mm-verify-writes.png>)

Ещё по одной записи на каждом узле — [08-write-mm1.sql](replication/master-master/sql/08-write-mm1.sql) и [09-write-mm2.sql](replication/master-master/sql/09-write-mm2.sql). На mm1 `LAST_INSERT_ID()` = 5, после ожидания GTID (0) строка 5 «third odd id» прочитана на mm2. На mm2 `LAST_INSERT_ID()` = 6, после ожидания (0) строка 6 «third even id» прочитана на mm1.

![Запись на mm1 видна на mm2, запись на mm2 — на mm1](<replication/evidence/mm-live-write.png>)

Итоговое состояние mm1: `server_id` 201, `read_only` / `super_read_only` = 0 / 0, шаг 2, смещение 1, в таблице 6 строк. Канал от mm2: `Source_Host` = `nt-repl-mm2`, `Source_Server_Id` = 202, Yes / Yes, отставание 0, ошибок нет, `Auto_Position` = 1. `Executed_Gtid_Set` = `b37ee112-cd38-11f1-ae30-76834bed9ef9:1-5, b3a5601d-cd38-11f1-b380-ca90ba484ced:1-3`. Полный статус — [full-status-mm1.txt](replication/evidence/full-status-mm1.txt).

![Состояние mm1](<replication/evidence/mm-status-mm1.png>)

Итоговое состояние mm2: `server_id` 202, `read_only` / `super_read_only` = 0 / 0, шаг 2, смещение 2, те же 6 строк. Канал от mm1: `Source_Host` = `nt-repl-mm1`, `Source_Server_Id` = 201, Yes / Yes, отставание 0, ошибок нет, `Auto_Position` = 1, тот же `Executed_Gtid_Set`, что на mm1. Полный статус — [full-status-mm2.txt](replication/evidence/full-status-mm2.txt).

![Состояние mm2](<replication/evidence/mm-status-mm2.png>)

Итоговая проверка [verify-lab.ps1](replication/verify-lab.ps1) по всем четырём серверам завершилась строкой `PASS` ([assertions.txt](replication/evidence/assertions.txt)):

- файлы конфигурации внутри серверов совпадают с файлами из репозитория;
- все каналы Yes / Yes, номера ошибок 0, `Auto_Position` = 1;
- данные master и replica совпадают;
- на mm1 и mm2 одинаковые строки с id 1–6;
- у replica `read_only` / `super_read_only` = 1 / 1.

Итог: оба узла принимают запись и получают изменения друг друга, ключи `AUTO_INCREMENT` не пересекаются (mm1 — 1, 3, 5; mm2 — 2, 4, 6). Записи делались поочерёдно. Одновременные конфликтующие изменения одних и тех же строк, переключение при отказе и восстановление после сбоя не проверялись. Обе связи асинхронные, нулевое отставание — снимок на момент проверки.
