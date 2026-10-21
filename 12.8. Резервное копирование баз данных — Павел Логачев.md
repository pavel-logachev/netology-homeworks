# 12.8. Резервное копирование баз данных — Павел Логачев

Команды из заданий 2 и 3 я выполнил на настоящих серверах в Docker Desktop: PostgreSQL 18.6 (образ `postgres:18.6`) и MySQL 8.0.46 (образ `mysql:8.0`: исходный сервер и отдельный сервер для восстановления). Скрипты лежат в папках `backup/postgresql/` и `backup/mysql/`, логи с реальным выводом и снимки терминала — в `backup/evidence/`. Время в логах и в именах архивов указано в UTC.

Стенд был одноразовым: после проверки контейнеры, тома и сеть удалены ([cleanup.txt](backup/evidence/cleanup.txt)). Поэтому сами файлы резервных копий (`demo.dump`, `full.sql`, `binlog.000005`) в репозиторий не попали, остались только логи и скриншоты.

## Задание 1. Резервное копирование

Схему копирования выбирают по двум требованиям: RPO — сколько последних данных допустимо потерять, и RTO — за какое время нужно вернуть сервис. Если копия снимается раз в сутки, в худшем случае в неё не попадают почти сутки изменений. Время восстановления зависит от объёма базы и от отработанной процедуры восстановления. Частые копии журналов сокращают окно потерь, но быстрого переключения сами по себе не дают: для него нужна отдельная схема (см. 1.3*).

### 1.1. Восстановление данных в полном объёме за предыдущий день

Для этого подходит ежедневное полное резервное копирование:

- раз в сутки снимается полная копия базы: логический дамп (`pg_dump`, `mysqldump`) или физическая копия. Момент снимка выбирают относительно границы суток, например сразу после её окончания, чтобы в копию вошёл весь предыдущий день;
- несколько поколений копий хранятся на отдельном носителе, не зависящем от сервера БД;
- при восстановлении база возвращается ровно в то состояние, в котором была в момент снимка. Изменения, сделанные между двумя копиями, из такого дампа не восстановить.

Если база большая и делать полную копию каждый день дорого, полную копию можно снимать реже, а в остальные дни делать одну из двух видов частичных копий:

- инкрементную — изменения с момента предыдущей копии. Для восстановления нужны полная копия и вся цепочка инкрементов после неё;
- дифференциальную — изменения с момента последней полной копии. Для восстановления нужны полная копия и последняя дифференциальная.

Документация: [PostgreSQL 18: SQL Dump](https://www.postgresql.org/docs/18/backup-dump.html), [MySQL 8.0: Backup and Recovery Types](https://dev.mysql.com/doc/refman/8.0/en/backup-types.html), [MySQL Enterprise Backup 8.0: Making a Differential or Incremental Backup](https://dev.mysql.com/doc/mysql-enterprise-backup/8.0/en/mysqlbackup.incremental.html).

### 1.2. Восстановление данных за час до предполагаемой поломки

Копировать базу раз в час для этого недостаточно: такая копия вернёт состояние на момент последнего снимка, а не на произвольный момент «за час до сбоя». Нужно восстановление на момент времени (point-in-time recovery, PITR). Для него нужны базовая копия, снятая раньше целевого момента, и непрерывная цепочка журналов изменений от этой копии до целевого момента. Целевое время задают вместе с часовым поясом и проверяют, на какой границе транзакции остановится восстановление.

- **PostgreSQL.** Физическая базовая копия (`pg_basebackup`) и непрерывное архивирование WAL. На сервере настраивают `wal_level = replica` (или выше), `archive_mode = on` и `archive_command`. При восстановлении задают `restore_command`, создают файл `recovery.signal` и указывают цель `recovery_target_time`. Дамп `pg_dump` или `pg_dumpall` не может служить основой для проигрывания WAL. Документация: [Continuous Archiving and Point-in-Time Recovery](https://www.postgresql.org/docs/18/continuous-archiving.html), [recovery_target_time](https://www.postgresql.org/docs/18/runtime-config-wal.html#GUC-RECOVERY-TARGET-TIME).
- **MySQL.** Полная копия и бинарные журналы начиная с координаты, записанной в этой копии. При проигрывании журналов время ограничивают ключом `mysqlbinlog --stop-datetime` (время понимается в локальном часовом поясе процесса `mysqlbinlog`) или задают точные позиции событий. Документация: [Point-in-Time Recovery Using Binary Log](https://dev.mysql.com/doc/refman/8.0/en/point-in-time-recovery-binlog.html), [mysqlbinlog --stop-datetime](https://docs.oracle.com/cd/E17952_01/mysql-8.0-en/mysqlbinlog.html#option_mysqlbinlog_stop-datetime).

На практике в задании 3 проверено восстановление MySQL из полной копии и бинарного журнала до конца закрытого файла журнала. Остановку по времени (`--stop-datetime`) и PITR в PostgreSQL я не выполнял: здесь они описаны по документации.

### 1.3.* Моментальное переключение на работающую базу данных

Такой кейс возможен, если заранее работает реплика — копия базы, которая постоянно синхронизируется с основной. Переключение состоит из нескольких шагов: обнаружить отказ, повысить реплику до основного сервера (promotion), не допустить одновременной работы двух основных серверов (fencing против split-brain) и перенаправить или переподключить клиентов. Буквально нулевой задержки при этом не бывает. Восстановиться из резервной копии «моментально» тоже нельзя: быстро переключиться можно только на уже запущенную реплику.

- **PostgreSQL.** Ядро поддерживает резервные (standby) серверы и их повышение, но внешнего детектора отказов и оркестратора в нём нет ([Failover](https://www.postgresql.org/docs/18/warm-standby-failover.html)). При асинхронной репликации могут потеряться транзакции, которые ещё не дошли до реплики. Синхронная репликация защищает от этого, но увеличивает задержку ([High Availability, Load Balancing, and Replication](https://www.postgresql.org/docs/18/high-availability.html)). Пример средства автоматического переключения — Patroni с распределённым хранилищем конфигурации etcd, Consul или ZooKeeper ([документация Patroni](https://patroni.readthedocs.io/en/latest/)). Patroni — отдельный проект, в поставку PostgreSQL он не входит.
- **MySQL.** Group Replication в режиме single-primary сама выбирает новый основной сервер. Чтобы клиенты попадали на него, нужен MySQL Router, коннектор или балансировщик. InnoDB Cluster объединяет Group Replication, MySQL Shell и MySQL Router в одно решение высокой доступности ([Group Replication](https://dev.mysql.com/doc/refman/8.0/en/group-replication.html)).

Отказоустойчивый кластер не заменяет резервные копии (подробнее в 3.1*). В этой работе кластер высокой доступности не разворачивался, ответ основан на документации.

## Задание 2. PostgreSQL

### 2.1. Резервирование и восстановление БД (pg_dump / pg_restore)

PostgreSQL 18.6 работал в одноразовом контейнере. Подключение шло через локальный Unix-сокет под пользователем `postgres` без пароля (`trust`); такая настройка допустима только на учебном стенде. Скрипт [01-setup.sh](backup/postgresql/01-setup.sh) создал тестовую базу `demo`: 2 клиента и 3 платежа на сумму 2100.50 ([pg-setup.txt](backup/evidence/pg-setup.txt)).

**Резервная копия** ([02-backup.sh](backup/postgresql/02-backup.sh)):

```bash
pg_dump -Fc -d demo -f /backups/demo.dump
pg_dumpall --globals-only --no-role-passwords -f /backups/globals.sql
```

- `-Fc` — custom-формат. Такой архив по умолчанию сжат, восстанавливают его утилитой `pg_restore`, а не `psql`.
- `pg_dump` сохраняет одну базу, но не сохраняет роли и табличные пространства кластера. Их выгружает `pg_dumpall --globals-only`. Ключ `--no-role-passwords` исключает хеши паролей, поэтому после восстановления пароли ролей нужно задать отдельно.

Получились файлы `demo.dump` размером 4.4K и `globals.sql` размером 526 байт. По выводу `pg_restore --list` в архиве есть таблицы, последовательности, данные и ограничения ([pg-backup.txt](backup/evidence/pg-backup.txt)).

![Терминал: pg_dump и pg_dumpall, размеры и SHA-256 файлов, содержимое архива по pg_restore --list](<backup/evidence/pg-01-backup.png>)

**Восстановление** ([03-restore.sh](backup/postgresql/03-restore.sh)). Скрипт удаляет базу, создаёт её заново пустой из шаблона `template0` и восстанавливает в неё архив:

```bash
dropdb demo
createdb -T template0 demo
pg_restore --exit-on-error -d demo /backups/demo.dump
```

Есть и другой вариант — `pg_restore` с ключом `-C` (`--create`): тогда базу создаёт сам `pg_restore`, ключ `-d` указывает служебную базу для первого подключения, а имя восстанавливаемой базы берётся из архива. Этот вариант я не запускал.

После восстановления в базе снова 2 клиента и 3 платежа на сумму 2100.50. Упорядоченная выгрузка строк после восстановления совпадает с выгрузкой, сделанной до копирования: `diff` пустой ([pg-before.txt](backup/evidence/pg-before.txt), [pg-after.txt](backup/evidence/pg-after.txt)). Скрипт также вывел 10 ограничений (у всех `convalidated = t`), 3 индекса, владельца таблиц `postgres` и значения последовательностей 2 и 3 ([pg-restore.txt](backup/evidence/pg-restore.txt)). Их я сверил с исходной схемой вручную, автоматического сравнения метаданных не было. Загрузку `globals.sql` я не проверял: роль `postgres` на стенде уже существовала.

На скриншоте — повторный прогон того же восстановления в компактном виде ([05-restore-summary.sh](backup/postgresql/05-restore-summary.sh), [pg-restore-summary.txt](backup/evidence/pg-restore-summary.txt)):

![Терминал: dropdb, createdb и pg_restore, таблицы customers и payments после восстановления, 3 платежа на 2100.50, пустой diff и PASS](<backup/evidence/pg-02-restore.png>)

Документация: [pg_dump](https://www.postgresql.org/docs/18/app-pgdump.html), [pg_restore](https://www.postgresql.org/docs/18/app-pgrestore.html), [pg_dumpall](https://www.postgresql.org/docs/18/app-pg-dumpall.html).

### 2.1.* Автоматизация процесса

Да, процесс можно автоматизировать. Встроенного планировщика в PostgreSQL нет: в документации описаны клиентские утилиты, а запускать их по расписанию нужно внешними средствами. Я написал скрипт [backup.sh](backup/postgresql/backup.sh) для ежедневного запуска через cron. Скрипт делает следующее:

- выставляет `umask 077`, чтобы архивы были доступны только владельцу;
- создаёт блокировку `mkdir "$BACKUP_DIR/.backup-lock"`, чтобы два запуска не пересеклись. При выходе `trap` снимает блокировку и удаляет временный файл;
- называет архив по дате и времени UTC: `demo_${stamp}.dump`;
- пишет дамп во временный файл `.partial`, проверяет его через `pg_restore --list` и только после успешной проверки переименовывает в итоговый;
- после успешного дампа удаляет архивы старше срока хранения.

Основные команды скрипта:

```bash
pg_dump -Fc -d demo -f "$tmp"
pg_restore --list "$tmp" >/dev/null
mv -- "$tmp" "$final"
find "$BACKUP_DIR" -maxdepth 1 -type f -name 'demo_*.dump' -mtime +"$RETENTION_DAYS" -print -delete
```

В скрипте `RETENTION_DAYS=7`. Условие `-mtime +7` удаляет файлы, которым 8 полных суток и больше, а не ровно 7: `find` округляет возраст файла вниз до целых суток.

Строка расписания из [crontab.txt](backup/postgresql/crontab.txt) запускает скрипт ежедневно в 02:00 по часовому поясу демона cron:

```
0 2 * * * PGUSER=postgres /bin/bash /opt/backup/backup.sh >> /backups/backup.log 2>&1
```

В стандартном контейнере PostgreSQL демона cron нет, поэтому строку я только записал: cron не устанавливался и не запускался. Сам скрипт я запустил вручную тестом [04-automation-test.sh](backup/postgresql/04-automation-test.sh) ([pg-automation.txt](backup/evidence/pg-automation.txt)):

- перед запуском в каталоге копий лежали два тестовых файла: один с датой изменения 10 дней назад, другой свежий;
- скрипт создал архив `demo_20261021T101310_555065349Z.dump` (4.4K, права `-rw-------`), удалил старый тестовый файл и оставил свежий;
- новый архив восстановлен в отдельную базу `demo_auto`: `diff` строк с исходными данными пустой, в базе 3 платежа на сумму 2100.50.

![Терминал: запуск backup.sh, удалённый старый файл, созданный архив, восстановление в demo_auto, 3 платежа на 2100.50 и PASS](<backup/evidence/pg-03-automation.png>)

Для рабочей схемы этого мало. Копии нужно дополнительно переносить на другой сервер или в отдельное хранилище, следить за неудачными запусками, работой архиватора и свободным местом и регулярно проводить пробное восстановление. Если нужно восстанавливать базу на произвольный момент времени, одних дампов недостаточно: дополнительно к ним нужны физические базовые копии (`pg_basebackup`) и непрерывное архивирование WAL (см. 1.2).

Документация: [SQL Dump](https://www.postgresql.org/docs/18/backup-dump.html), [Continuous Archiving and Point-in-Time Recovery](https://www.postgresql.org/docs/18/continuous-archiving.html).

## Задание 3. MySQL

### 3.1. Инкрементное резервное копирование

Официальная документация MySQL описывает инкрементное копирование через бинарный журнал:

1. На сервере включён бинарный журнал.
2. Полная копия записывает координату журнала, с которой начинаются последующие изменения.
3. Журнал переключают на новый файл командой `FLUSH LOGS` или `FLUSH BINARY LOGS`, после чего копируют все закрытые файлы журнала с предыдущей границы. Это и есть инкремент. Последний, активный файл не копируют.
4. Для восстановления сначала загружают полную копию, затем проигрывают журналы через `mysqlbinlog | mysql`. Одних файлов журнала без полной копии недостаточно.

Документация: [Database Backup Methods](https://dev.mysql.com/doc/refman/8.0/en/backup-methods.html), [mysqldump](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html).

**Стенд** ([01-setup.sh](backup/mysql/01-setup.sh), [mysql-setup.txt](backup/evidence/mysql-setup.txt)). Исходный сервер `nt-bkp-mysql` (`server_id` 108): бинарный журнал включён, формат `ROW`, GTID выключен. Сервер для восстановления `nt-bkp-mysql-restore` (`server_id` 109) создан пустым, базы `demo` на нём нет. Пароль root передаётся через переменную окружения и option-файлы `/root/source.cnf` и `/root/target.cnf` с доступом только для владельца, в репозиторий и логи он не попадает. В исходной базе `demo` 2 клиента и 2 платежа. В образе `mysql:8.0` (8.0.46) нет утилиты `mysqlbinlog`, поэтому скрипт [00-client-tools.sh](backup/mysql/00-client-tools.sh) извлекает её из официального RPM-пакета `mysql-community-client-8.0.46`.

**Шаг 1. Полная копия** ([02-full-backup.sh](backup/mysql/02-full-backup.sh)):

```bash
mysqldump --defaults-extra-file=/root/source.cnf --single-transaction --source-data=2 --flush-logs --set-gtid-purged=OFF --databases demo > /backups/full.sql
```

- `--single-transaction` даёт согласованный снимок таблиц InnoDB (для MyISAM и MEMORY не подходит). Во время дампа нельзя параллельно выполнять DDL.
- `--source-data=2` (ключ появился в 8.0.26) записывает в дамп координаты бинарного журнала в виде комментария. В версии 8.0.46 координаты выводятся в старом синтаксисе: `-- CHANGE MASTER TO MASTER_LOG_FILE='binlog.000005', MASTER_LOG_POS=157;`.
- `--flush-logs` переключает бинарный журнал на новый файл при создании дампа. В этом прогоне инкремент начался с файла `binlog.000005`, позиция 157.

Получился файл `full.sql` размером 3.2K. На момент копии в исходной базе было 2 платежа на сумму 2000.50 ([mysql-full.txt](backup/evidence/mysql-full.txt)).

![Терминал: mysqldump, координата binlog.000005 и позиция 157, SHOW MASTER STATUS, 2 платежа на 2000.50](<backup/evidence/mysql-01-full.png>)

**Шаг 2. Инкремент** ([03-incremental.sh](backup/mysql/03-incremental.sh)). После полной копии в исходной базе одной транзакцией добавлены клиент Boris и два платежа (100.00 и 500.00), а платёж 2 изменён с 750.50 на 800.50. Стало 4 платежа на сумму 2650.50. Затем журнал переключён и закрытый файл скопирован:

```sql
FLUSH BINARY LOGS;
```

```bash
cp "/var/lib/mysql/$start_file" /backups/incremental/
```

Здесь `$start_file` — файл из координаты полной копии, `binlog.000005`. После `FLUSH BINARY LOGS` активным стал `binlog.000006`, а закрытый `binlog.000005` (744 байта) скопирован в `/backups/incremental/` ([mysql-incremental.txt](backup/evidence/mysql-incremental.txt)). В стенде между копиями закрылся ровно один файл. В рабочей схеме копируют все закрытые файлы журнала с предыдущей границы, кроме активного.

![Терминал: 4 платежа на 2650.50, список бинарных журналов до binlog.000006, копирование binlog.000005 размером 744 байта](<backup/evidence/mysql-02-incremental.png>)

**Шаг 3. Восстановление на отдельном сервере** ([04-restore.sh](backup/mysql/04-restore.sh)):

```bash
mysql --defaults-extra-file=/root/target.cnf < /backups/full.sql
mysqlbinlog --start-position="$start_pos" "/backups/incremental/$start_file" | mysql --defaults-extra-file=/root/target.cnf --binary-mode
```

После загрузки одной полной копии на сервере 2 платежа на сумму 2000.50. После проигрывания журнала с позиции 157 — 3 клиента и 4 платежа на сумму 2650.50. SHA-256 упорядоченной выгрузки строк на исходном сервере и на сервере восстановления совпадает: `c0c34938a4403fb46966e20c6ecd394037927b44724df287d8a3ca4c90b1245f` ([mysql-restore.txt](backup/evidence/mysql-restore.txt), [mysql-expected.txt](backup/evidence/mysql-expected.txt), [mysql-restored.txt](backup/evidence/mysql-restored.txt)).

На скриншоте — повторный прогон ([05-restore-summary.sh](backup/mysql/05-restore-summary.sh), [mysql-restore-summary.txt](backup/evidence/mysql-restore-summary.txt)). На сервере восстановления база `demo` удалена, полная копия загружена командой `source /backups/full.sql`, затем журнал проигран с координатами этого прогона:

```bash
mysqlbinlog --start-position=157 /backups/incremental/binlog.000005 | mysql --defaults-extra-file=/root/target.cnf --binary-mode
```

Результат тот же: 4 платежа на сумму 2650.50, хеши выгрузок совпадают.

![Терминал: сервер 109, загрузка full.sql — 2 платежа на 2000.50, mysqlbinlog с позиции 157 — 4 платежа на 2650.50, совпадение SHA-256 и PASS](<backup/evidence/mysql-03-restore.png>)

Есть и физические инкрементные копии, которые сохраняют изменённые страницы данных. Их я не запускал:

- MySQL Enterprise Backup (лицензируемый продукт): `mysqlbackup --incremental --incremental-base=dir:/backup/base --incremental-backup-dir=/backup/inc backup` ([документация](https://dev.mysql.com/doc/mysql-enterprise-backup/8.0/en/mysqlbackup.incremental.html));
- Percona XtraBackup: `xtrabackup --backup --target-dir=/backup/inc --incremental-basedir=/backup/base`. Совместимость версии XtraBackup с версией сервера нужно проверять отдельно ([документация](https://docs.percona.com/percona-xtrabackup/8.0/create-incremental-backup.html)).

### 3.1.* Когда реплика выгоднее обычного резервного копирования

Реплика даёт преимущество, когда нужно:

- **быстро переключиться при отказе.** Реплика — уже работающий сервер с актуальными данными, и не нужно ждать восстановления из копии;
- **разгрузить основной сервер от чтения.** Отчёты и другие запросы только на чтение можно выполнять на реплике ([Using Replication for Scale-Out](https://dev.mysql.com/doc/refman/8.0/en/replication-solutions-scaleout.html));
- **снимать резервные копии без нагрузки на основной сервер** и без его остановки: копию делают с реплики ([Using Replication for Backups](https://dev.mysql.com/doc/refman/8.0/en/replication-solutions-backups.html));
- **защититься от части ошибок пользователей.** Отложенная реплика (`CHANGE REPLICATION SOURCE TO SOURCE_DELAY=N`, с версии 8.0.23) применяет изменения с задержкой. Пока ошибочная транзакция до неё не дошла, на реплике можно посмотреть прежнее состояние данных без загрузки резервной копии ([Delayed Replication](https://dev.mysql.com/doc/refman/8.0/en/replication-delayed.html)).

Но реплика не заменяет резервное копирование:

- ошибочные `DELETE` и `DROP` тоже реплицируются;
- обычная реплика не хранит независимых копий за прошлые даты, и вернуться к состоянию «на вчера» по ней нельзя;
- общий сбой или компрометация могут затронуть и основной сервер, и реплику;
- при асинхронной репликации реплика отстаёт от основного сервера. От величины отставания зависят свежесть данных на ней и объём потерь при переключении ([PostgreSQL: High Availability](https://www.postgresql.org/docs/18/high-availability.html) — тот же принцип).

Поэтому реплика нужна для доступности и распределения нагрузки, а для восстановления данных всё равно нужны отдельные резервные копии, журналы изменений и регулярные проверки восстановления.
