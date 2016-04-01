#!/bin/bash

start_mysql(){
  /usr/bin/mysqld_safe --skip-syslog --datadir=/config/db > /dev/null 2>&1 &
  RET=1
  while [[ RET -ne 0 ]]; do
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
    sleep 1
  done
}

if [[ ! -f /tmp/.mysql_configured ]]; then
  # Tweak my.cnf
  sed -i -e "s#\(log_error.*=\).*#\1 /config/db/mysql_safe.log#g" /etc/mysql/my.cnf
  sed -i -e "s/\(user.*=\).*/\1 nobody/g" /etc/mysql/my.cnf

  # InnoDB engine to use 1 file per table, vs everything in ibdata.
  echo '[mysqld]' > /etc/mysql/conf.d/innodb_file_per_table.cnf
  echo 'innodb_file_per_table' >> /etc/mysql/conf.d/innodb_file_per_table.cnf

  # If databases do not exist create them
  if [ -f "/config/db/mysql/user.MYD" ]; then
    echo "Database exists."
  else
    echo "Creating database."
    /usr/bin/mysql_install_db --datadir=/config/db >/dev/null 2>&1
  fi
  start_mysql
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
  mysqladmin -u root shutdown
  touch /tmp/.mysql_configured
fi

echo "Starting MariaDB..."
/usr/bin/mysqld_safe --skip-syslog --datadir=/config/db