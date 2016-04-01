#!/bin/bash

# get ownCloud config
cmd="setuser nobody /var/www/owncloud/occ config:system:get"
host=$($cmd dbhost)
db=$($cmd dbname)
user=$($cmd dbuser)
pass=$($cmd dbpassword)

# Export file
file=/tmp/owncloud-sqlbkp_$(date +"%Y%m%d").bak

# Export remote database
mysqldump --lock-tables -h $host -u $user -p${pass} $db > $file

# Drop and create database
mysql -uroot -e "DROP DATABASE ${db};"
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ${db};"

# Create user
mysql -uroot -e "GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'localhost' IDENTIFIED BY '${pass}';FLUSH PRIVILEGES;"

# Import remote database into local server
mysql -uroot $db < $file

# Remove export file
rm $file

php <<'EOS'
<?PHP
$config_file = "/config/config/config.php";

if (is_file($config_file)) {
  require_once($config_file);
} else {
  exit();
}

# Change values
$CONFIG['dbhost'] = 'localhost';

# Save file
file_put_contents($config_file, '<?PHP'.PHP_EOL.'$CONFIG = '.var_export($CONFIG, TRUE).PHP_EOL.'?>' );
?>
EOS
