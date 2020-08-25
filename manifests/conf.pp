# == Class role_xenocanto::conf
#
# All configurable settings
#
class role_xenocanto::conf (
  # ::repo
  $git_repo_rootdirs     = ['/opt/git'],
  $git_repo_dir          = '/opt/git/xc',
  $git_repo_source       = 'https://gitlab.com/naturalis/bii/xeno-canto/xeno-canto.git',
  $git_repo_ensure       = 'latest',
  $git_repo_revision     = 'master',
  $git_repo_key,
  $git_repo_keyname      = 'github.com',

  # ::web
  $ensure_mailnotifications = 'present',  # set 'absent' for test. 
  $cron_log              = '/var/log/xeno-canto/cron.log',
  $datadirs              = ['/data','/data/sounds','/data/graphics','/data/ranges'],
  $web_packages          = ['locales-all',
                             'imagemagick',
                             'libgstreamer1.0-0',
                             'gstreamer1.0-plugins-base',
                             'gstreamer1.0-plugins-good',
                             'gstreamer1.0-plugins-ugly',
                             'libglibmm-2.4-1v5',
                             'libcairomm-1.0-1v5',
                             'libpangocairo-1.0-0',
                             'git'
                            ],
  $docroot               = '/var/www/htdocs',
  $enable_ssl            = false,
  $server_name           = 'test.xeno-canto.org',
  $recaptcha_site_key    = 'recaptcha_site_key',
  $recaptcha_secret_key  = 'recaptcha_secret_key',
  $google_analytics_tracking_id = 'UA-123456-1',
  $google_maps_api_key   = 'API key here',
  $google_maps_geocoding_key = 'Geocoding key',
  $minio_web_url         = 'https://acceptatie-xc-minio.naturalis.nl:8443/minio',
  $ssl_instances         = {'xeno-canto.org-nonssl' => {
                                 'serveraliases'        => '*.xeno-canto.org',
                                 'docroot'              => '/var/www/htdocs',
                                 'directories'          => [{ 'path' => '/var/www/htdocs',
                                 'options'              => '-Indexes +FollowSymLinks +MultiViews',
                                 'allow_override'       => 'All'}],
                                 'rewrites'             => [{'rewrite_rule' => ['^/?(.*) https://%{SERVER_NAME}/$1 [R,L]']}],
                                 'port'                 => 80,
                                 'serveradmin'          => 'admin@xeno-canto.org',
                                 'priority'             => 10,
                                 },
                                 'xeno-canto.org' => {
                                 'serveraliases'        => '*.xeno-canto.org',
                                 'docroot'              => '/var/www/htdocs',
                                 'directories'          => [{ 'path' => '/var/www/htdocs',
                                 'options'              => '-Indexes +FollowSymLinks +MultiViews',
                                 'allow_override'       => 'All'}],
                                 'port'                 => 443,
                                 'serveradmin'          => 'admin@xeno-canto.org',
                                 'priority'             => 10,
                                 'ssl'                  => true,
                                 'ssl_cert'             => '/etc/letsencrypt/live/test.xeno-canto.org/cert.pem',
                                 'ssl_key'              => '/etc/letsencrypt/live/test.xeno-canto.org/privkey.pem',
                                 'ssl_chain'            => '/etc/letsencrypt/live/test.xeno-canto.org/chain.pem',
                                 'additional_includes'  => '/etc/letsencrypt/options-ssl-apache.conf',
                                 },
                               },
  $instances                = { 'xeno-canto.org-nonssl' => {
                                 'serveraliases'        => '*.xeno-canto.org',
                                 'docroot'              => '/var/www/htdocs',
                                 'directories'          => [{ 'path' => '/var/www/htdocs',
                                 'options'              => '-Indexes +FollowSymLinks +MultiViews',
                                 'allow_override'       => 'All'}],
                                 'port'                 => 80,
                                 'serveradmin'          => 'admin@xeno-canto.org',
                                 'priority'             => 10,
                                 }
                               },

  # ::web php settings
  $php_max_execution_time      = 90,
  $php_max_input_time          = 300,
  $php_memory_limit            = '256M',
  $php_post_max_size           = '128M',
  $php_upload_max_filesize     = '128M',
  $config_environment          = 'prod',  # prod, debug or task

  # ::db
  $web_host              = '127.0.0.1',
  $db_host               = '127.0.0.1',
  $db_name               = 'xenocanto',
  $db_user               = 'xenocanto',
  $db_password,
  $mysql_root_password,
  $override_options,
  $users,
  $grants,
  $db_hash,

  # ::rsync
  $rsync_pub_key        = '',
  $rsync_priv_key       = '',
  $web_host_prod        = 'www.xeno-canto.org',
  Boolean $rsync_media  = false,
  $rsync_cron_hour      = '2',
  $rsync_cron_minute    = '30',
  $rsync_cron_weekday   = '6',

) {
}
