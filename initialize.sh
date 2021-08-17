#!/bin/bash

PUBLIC_IP=$(wget -q -O - http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4)
DB_ADDRESS=$(consul kv get backend/db_address)
DB_USER=$(consul kv get backend/db_user)
DB_PASS=$(consul kv get backend/db_pass)

sed -i.backup "s/{{ DBHOST }}/$DB_ADDRESS/g" /etc/kamailio/definitions.cfg /etc/kamailio/kamctlrc
sed -i.backup "s/{{ DBUSER }}/$DB_USER/g" /etc/kamailio/definitions.cfg /etc/kamailio/kamctlrc
sed -i.backup "s/{{ DBPASS }}/$DB_PASS/g" /etc/kamailio/definitions.cfg /etc/kamailio/kamctlrc

sed -i.backup "s/{{ KAM_PRIVATE_IP }}/$PRIVATE_IP/g" /etc/kamailio/definitions.cfg
sed -i.backup "s/{{ KAM_PUBLIC_IP }}/$PUBLIC_IP/g" /etc/kamailio/definitions.cfg

echo "alias=$PUBLIC_IP" >> aliases.cfg
echo "alias=$PRIVATE_IP" >> aliases.cfg

SIP_DOMAIN=$(consul kv get voice/sip_domain 2> /dev/null) && if [[ "$?" -eq "0" ]]; then echo "alias=$SIP_DOMAIN" >> aliases.cfg; fi

kamdbctl create