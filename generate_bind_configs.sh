#!/bin/bash

set -eu

file=$1
ip=$2
zones=/etc/named.reductor.zones
DOMAIN_TMPLT=/opt/named_fakezone_generator/reductor_named_domain.tmplt

cleanup() {
	> $zones
	mkdir -p /etc/named/
	rm -f /etc/named/reductor_*
	rm -f $file.processed
}

process_list() {
	grep -v [а-я] | sed 's/\.$//' | sed -e 's/^www\.//' | sort -u
}

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
	rndc reload || service named restart
}

main
