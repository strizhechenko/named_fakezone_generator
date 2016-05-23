# Named fakezone generator

Генератор зон для named/bind9 для списка доменов, которые необходимо перекидывать на заглушку, настроенную по гайду https://github.com/carbonsoft/reductor_blockpages

## Использование

Допишите в конец файла /etc/named.conf:

    include "/etc/named.reductor.zones";

Запустите:

    ./generate_bind_configs.sh <путь до файла со списком доменов> <ip адрес заглушки>

## Автоматизация

Если всё устраивает - добавьте вызов в крон, например так:

    */20 * * * * root /opt/named_fakezone_generator/generate_bind_configs.sh /tmp/reductor.https.resolv 10.50.140.73

Не забудьте добавить запись, которая периодически забирает файл https.resolv с Carbon Reductor. Это можно сделать следующим образом:

Если SSH ключи отсутствуют, генерируем их:

    ssh-keygen

Затем добавляем их на Carbon Reductor:

    ssh-copy-id root@<ip адрес carbon reductor>

Проверяем что scp не запрашивает пароль и выкачивает файл:

    scp root@<ip адрес carbon reductor>:/usr/local/Reductor/lists/https.resolv /tmp/reductor.https.resolv

## Принцип действия

Генерирует следующие файлы:

Список сгенерированных зон:

    zones=/etc/named.reductor.zones

Файлы зон:

    /etc/named/reductor_<домен который необходимо редиректить>.conf

