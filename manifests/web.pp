# == Class: role_xenocanto::web
#
# This role creates the necessary configuration for the xeno canto webserver
#
class role_xenocanto::web (
  $server_name = ['test.xeno-canto.org'],
  $dbuser = undef,
  $dbpass = undef,
  $dbname = 'forum',
  $dbhost = 'localhost',
  $sslenabled = false,
  $instancesssl                 = {'xeno-canto.org-nonssl' => {
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
  $instances                   = {'xeno-canto.org-nonssl' => {
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
) {

  # Install PHP with FPM
  class { '::php':
    manage_repos => true,
    ensure     => present,
    fpm        => true,
    extensions => {
      mysql  => {},
      mcrypt => {},
    },
  }

  # Install memcached for caching and user sessions
  class { 'memcached': }

  class { 'apache':
      default_mods              => true,
      mpm_module                => 'prefork',
  }

  # install apache mods
  class { 'apache::mod::rewrite': }
  class { 'apache::mod::headers': }
  class { 'apache::mod::expires': }
  class { 'apache::mod::proxy': }
  class { 'apache::mod::proxy_http': }
  class { 'apache::mod::cache': }
  class { 'apache::mod::ssl': }

  # Create Apache Virtual host
  create_resources('apache::vhost', $role_xenocanto::web::instances)
}
