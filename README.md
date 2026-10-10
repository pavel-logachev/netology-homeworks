# Домашние задания Нетологии — Павел Логачев

Курс «DevOps-инженер с нуля». Каждая работа лежит в своей ветке; в README ветки — ход выполнения, команды и снимки экрана, рядом — конфигурации и скрипты.

| Занятие | Что сделано | Ветка |
|---|---|---|
| Операции с данными в SQL | Шесть SELECT-запросов к Sakila в MySQL 8.0: районы по шаблону, платежи > 10 за 15–18 июня 2005 года включительно, последние пять аренд, активные клиенты Kelly/Willie с нижним регистром и заменой ll→pp, разбиение email на два столбца и заглавная первая буква | [12-03-sql-operations](https://github.com/pavel-logachev/netology-homeworks/blob/12-03-sql-operations/README.md) |
| Работа с данными (DDL/DML) | MySQL 8.0.46 в Docker, sys_temp со всеми глобальными правами и переходом на mysql_native_password, восстановление Sakila (16 таблиц и 7 представлений), таблица первичных ключей через information_schema; INSERT/UPDATE/DELETE на sakila отозваны через partial_revokes: запись — ERROR 1142, чтение работает | [12-02-sql-ddl-dml](https://github.com/pavel-logachev/netology-homeworks/blob/12-02-sql-ddl-dml/README.md) |
| Базы данных | Отчёт Excel на 29 сотрудников разложен на семь таблиц PostgreSQL с ключами и ограничениями; схема в draw.io, создание и проверка структуры в PostgreSQL 18.6 в Docker | [12-01-databases](https://github.com/pavel-logachev/netology-homeworks/blob/12-01-databases/README.md) |
| Очереди RabbitMQ | Кластер RabbitMQ 3.12 из двух VM с зеркалированием очередей, producer и consumer на Python, проверка отказа одного узла, Ansible-playbook с повторным прогоном без изменений | [11-04-rabbitmq](https://github.com/pavel-logachev/netology-homeworks/blob/11-04-rabbitmq/README.md) |
