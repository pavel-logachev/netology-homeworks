# Домашнее задание к занятию «Очереди RabbitMQ» — Павел Логачев

## Стенд

Создал две VM в VirtualBox 7.2.16: Ubuntu 24.04.5, по 2 CPU и 3 ГБ RAM.

| VM | Узел | IP |
|---|---|---|
| `netology-rmq01` | `rabbit@rmq01` | `192.168.56.111` |
| `netology-rmq02` | `rabbit@rmq02` | `192.168.56.112` |

Установил RabbitMQ 3.12.1 и Erlang 25.3.2.8. Для `ha-mode: all` использовал RabbitMQ 3.12, поскольку в 4.x классическое зеркалирование удалено.

## Задание 1. Установка RabbitMQ

Установил RabbitMQ и включил `rabbitmq_management`. Открыл интерфейс на `http://192.168.56.111:15672/`.

![Management UI и доступные узлы](<rabbitmq/evidence/06-nodes-full.png>)

## Задание 2. Отправка и получение сообщений

В скриптах из условия изменил только IP подключения на `192.168.56.111`. Скрипты используют старый API pika, поэтому запускал их в окружении Python 3.9 с pika 0.13.1.

```bash
.venv39/bin/python producer.py; echo PRODUCER_EXIT=$?
```

Producer отправил `Hello Netology!` и завершился с кодом `0`. В UI очередь `hello` содержала одну готовую запись.

![Запуск producer](<rabbitmq/evidence/02-producer.png>)
![Очередь hello, Ready=1](<rabbitmq/evidence/02-hello-full.png>)

```bash
.venv39/bin/python consumer.py
```

Consumer получил сообщение. На снимке две строки, поскольку при проверке очереди я повторно запускал producer.

![Результат consumer](<rabbitmq/evidence/03-consumer.png>)

## Задание 3. HA-кластер

На обеих VM добавил имена и адреса в `/etc/hosts`. Проверил ping в обе стороны, потерь нет.

![hosts и ping на rmq01](<rabbitmq/evidence/04-hosts-rmq01.png>)
![hosts и ping на rmq02](<rabbitmq/evidence/05-hosts-rmq02.png>)

Объединил узлы через Ansible. Создал политику `ha-all` с шаблоном `.*` для всех очередей vhost `/`: `ha-mode: all`, `ha-sync-mode: automatic`. У очереди `hello` появился синхронизированный зеркальный узел `rabbit@rmq02`.

![Политика ha-all](<rabbitmq/evidence/07-policy-list-full.png>)
![Зеркало очереди hello](<rabbitmq/evidence/07-hello-mirror-full.png>)

На обеих VM выполнил `rabbitmqctl cluster_status`. Оба узла входят в Disk Nodes и Running Nodes; alarms и network partitions отсутствуют.

![cluster_status на rmq01](<rabbitmq/evidence/08-cluster-rmq01.png>)
[Остальной вывод rmq01: часть 2](<rabbitmq/evidence/08-cluster-rmq01-part2.png>), [часть 3](<rabbitmq/evidence/08-cluster-rmq01-part3.png>).

![cluster_status на rmq02](<rabbitmq/evidence/09-cluster-rmq02.png>)
[Остальной вывод rmq02: часть 2](<rabbitmq/evidence/09-cluster-rmq02-part2.png>), [часть 3](<rabbitmq/evidence/09-cluster-rmq02-part3.png>).

Повторно запустил producer с подключением к `.111`, затем на каждом узле выполнил `rabbitmqadmin get queue='hello'`.

![Producer в кластере](<rabbitmq/evidence/10-producer-ha.png>)
![get на rmq01](<rabbitmq/evidence/11-get-rmq01.png>)
![get на rmq02](<rabbitmq/evidence/12-get-rmq02.png>)

В настройках `rabbitmqadmin` указал адрес соответствующего узла и порт `15672`. По умолчанию `get` возвращает сообщение в очередь, поэтому на втором узле видно `redelivered=True`.

Остановил брокер, к которому подключался producer:

```bash
systemctl stop rabbitmq-server; systemctl is-active rabbitmq-server
```

![rmq01 inactive](<rabbitmq/evidence/13-stop-rmq01.png>)

В consumer заменил адрес на `192.168.56.112` и запустил его с первой VM. Он получил ранее отправленное сообщение со второго узла.

![Consumer после остановки rmq01](<rabbitmq/evidence/14-failover-consumer.png>)

После проверки восстановил первый брокер. Оба узла работают, очередь пуста: [проверка rmq01](<rabbitmq/evidence/final-rmq01.txt>), [проверка rmq02](<rabbitmq/evidence/final-rmq02.txt>).

## Задание 4*. Ansible

Подготовил playbook для установки RabbitMQ, объединения узлов из inventory и создания `ha-all`. Общий cookie хранится с правами `0400`, секретные задачи скрыты через `no_log`, перед `reset` проверяется отсутствие очередей и чужого многонодового кластера.

Проверил на двух узлах с Ansible core 2.16.3. Запускал от пользователя `ubuntu` на `rmq01`:

```bash
ansible-playbook -i inventory.ini playbook.yml -e @secrets.yml
```

Повторный прогон дал `changed=0`, `failed=0`, `unreachable=0` на обеих VM.

![Результат повторного прогона](<rabbitmq/evidence/15-ansible-repeat.png>)
[Журнал применения](<rabbitmq/evidence/ansible-apply.txt>) и [повторного запуска](<rabbitmq/evidence/ansible-repeat.txt>).

## Файлы

- [playbook.yml](<rabbitmq/playbook.yml>): установка, кластер и политика `ha-all`.
- [inventory.ini](<rabbitmq/inventory.ini>): адреса VM и параметры SSH.
- [producer.py](<rabbitmq/producer.py>): отправка на `.111`.
- [consumer.py](<rabbitmq/consumer.py>): получение с `.112`; для задания 2 адрес нужно вернуть на `.111`.
- [requirements.txt](<rabbitmq/requirements.txt>): `pika==0.13.1`.
- [create-vms.py](<rabbitmq/create-vms.py>): создание двух VM; требуется `pycdlib`.

Пароль `labadmin` передаётся через `secrets.yml` и в репозиторий не включён. `guest/guest` и старые версии использовал только для учебного стенда в host-only сети.
