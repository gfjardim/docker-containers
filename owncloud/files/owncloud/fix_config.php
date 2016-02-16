<?PHP
$config_file = "/var/www/owncloud/config/config.php";
require_once($config_file);

# Change values
$CONFIG['memcache.local'] = '\OC\Memcache\APCu';

# Save file
file_put_contents($config_file, '<?PHP'.PHP_EOL.'$CONFIG = '.var_export($CONFIG, TRUE).PHP_EOL.'?>' );
?>