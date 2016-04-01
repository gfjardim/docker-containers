<?PHP
$config_file = "/config/config/config.php";

if (is_file($config_file)) {
  require_once($config_file);
}

# Change values
$CONFIG['memcache.local'] = '\OC\Memcache\APCu';
$CONFIG['datadirectory']  = '/config/data';
$CONFIG['updatechecker']  = false;

# mark as new installation
if (is_file("/config/make_new_install")) {
  $CONFIG['installed']        = false;
  unlink("/config/make_new_install");
}

$timezone = getenv('TZ') ? getenv('TZ') : 'UTC';
$CONFIG['logtimezone'] = $timezone;

$apps[0] = ['path'     => '/config/apps',
            'url'      => '/local_apps',
            'writable' => true];

$apps[1] = ['path'     => '/var/www/owncloud/apps',
            'url'      => '/apps',
            'writable' => true];

$CONFIG['apps_paths']  = $apps;

# Save file
file_put_contents($config_file, '<?PHP'.PHP_EOL.'$CONFIG = '.var_export($CONFIG, TRUE).PHP_EOL.'?>' );
?>