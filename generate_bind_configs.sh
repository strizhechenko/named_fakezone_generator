#!/bin/bash

set -eu

file=$1
ip=$2
zones=/etc/named.reductor.zones
DOMAIN_TMPLT=/opt/named_fakezone_generator/reductor_named_domain.tmplt

# удаляем сгенерированные в прошлый раз зоны, префикс чтобы не трогать чужие зоны при этом
cleanup() {
	> $zones
	mkdir -p /etc/named/
	rm -f /etc/named/reductor_*
	rm -f $file.processed
}

# с кириллическими доменами пока что проблема, вообще здесь избавляемся от дублирования из-за fqdn/www.
process_list() {
	grep -v "[а-я]" | sed 's/\.$//' | sed -e 's/^www\.//' | sort -u
}

# генерируем всё необходимое для блокировки одного конкретного домена
create_config() {
	local domain=$1
	local ip=$2
	echo 'zone "'$domain'" { type master; file "/etc/named/reductor_'$domain'.conf"; };' >> $zones
	m4 -D__domain__=$domain -D__ip__=$ip $DOMAIN_TMPLT > "/etc/named/reductor_$domain.conf"
}

main() {
	cleanup
	process_list < $file > $file.processed
	if [ ! -s $file.processed ]; then
		echo "Empty $file.processed, fail"
		exit 1
	fi
	while read domain; do
		create_config $domain $ip
	done < $file.processed
	# стараемся залить данные "мягко", но сервер может лежать, тогда поднимаем его
	# вообще спорный момент, в теории можно убрать || service named restart
	rndc reload || service named restart
}

main
