# == Class role_xenocanto::conf
#
# All configurable settings
#
class role_xenocanto::conf (
  # ::repo
  $git_repo_rootdirs     = ['/opt/git'],
  $git_repo_dir          = '/opt/git/xc',
  $git_repo_source       = 'ssh://git@github.com/naturalis/xc.git',
  $git_repo_ensure       = 'latest',
  $git_repo_revision     = 'master',
  $git_repo_key,

  # ::web
  $web_packages          =  ['locale-all','imagemagick'],
  $enables_ssl           = false,
  $enable_letsencrypt    = false,
  $server_name           = 'test.xeno-canto.org',
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
  $instances                = { "${::role_xenocanto::conf::server_name}-nonssl" => {
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


  # ::db
  $web_host              = '127.0.0.1',
  $db_host               = '127.0.0.1',
  $db_name               = 'xenocanto',
  $db_password,
  $mysql_root_password,
  $override_options,
  $users,
  $grants,
  $db_hash,
) {
}
