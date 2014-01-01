#!/bin/bash
if [ ! -f /usr/share/nginx/www/install/install_cli.php ]; then
  #mysql has to be started this way as it doesn't work to call from /etc/init.d
  /usr/bin/mysqld_safe & 
  sleep 10s
  # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
  PRESTASHOP_DB="prestashop"
  MYSQL_PASSWORD=`pwgen -c -n -1 12`
  PRESTASHOP_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs. 
  echo mysql root password: $MYSQL_PASSWORD
  echo prestashop password: $PRESTASHOP_PASSWORD
  echo $MYSQL_PASSWORD > /mysql-root-pw.txt
  echo $PRESTASHOP_PASSWORD > /prestashop-db-pw.txt


  mysqladmin -u root password $MYSQL_PASSWORD 
  mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE prestashop; GRANT ALL PRIVILEGES ON prestashop.* TO 'prestashop'@'localhost' IDENTIFIED BY '$PRESTASHOP_PASSWORD'; FLUSH PRIVILEGES;"
  php /usr/share/nginx/www/install/index_cli.php --domain=localhost --db_server=localhost --db_name=$PRESTASHOP_DB --db_user=prestashop --db_password=$PRESTASHOP_PASSWORD
  sleep 10s
  killall mysqld
fi

# start all the services
/usr/local/bin/supervisord -n
