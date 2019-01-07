# == Class: role_xenocanto::web
#
# This role creates the necessary configuration for the xeno canto webserver
#
class role_xenocanto::web (
) {
  # Install support packages
  ensure_packages($role_xenocanto::conf::web_packages)

  # Install Postfix mail server
  class { 'role_xenocanto::mail': }

  # Install PHP with FPM
  class { '::php':
    manage_repos => true,
    ensure     => present,
    fpm        => false,
    extensions => {
      mysql  => {},
      mcrypt => {},
      curl   => {},
    },
    settings   => {
        'PHP/max_execution_time'  => '-1',
        'PHP/max_input_time'      => '-1',
        'PHP/memory_limit'        => '-1',
        'PHP/post_max_size'       => $role_xenocanto::conf::php_post_max_size,
        'PHP/upload_max_filesize' => $role_xenocanto::conf::php_upload_max_filesize,
        'Date/date.timezone'      => 'Europe/Amsterdam',
    }
  }

  class { '::php::apache_config':
    settings   => {
        'PHP/max_execution_time'  => $role_xenocanto::conf::php_max_execution_time,
        'PHP/max_input_time'      => $role_xenocanto::conf::php_max_input_time,
        'PHP/memory_limit'        => $role_xenocanto::conf::php_memory_limit,
        'PHP/post_max_size'       => $role_xenocanto::conf::php_post_max_size,
        'PHP/upload_max_filesize' => $role_xenocanto::conf::php_upload_max_filesize,
        'Date/date.timezone'      => 'Europe/Amsterdam',
    }
  }

  # Install memcached for caching and user sessions
  class { 'memcached':
    max_memory  => 1024,
    user        => 'memcache',
    listen_ip   => '127.0.0.1',
    pidfile     => false,
    install_dev => true,
  }
  package { 'php-memcached':
    ensure      => latest,
    require     => Class['::php']
  }

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
  class { 'apache::mod::php': }


# letsencrypt
  if $role_xenocanto::conf::enable_ssl == true {
  # install letsencrypt certs only and crontab
    class { ::letsencrypt:
      repo           => 'https://github.com/certbot/certbot.git',
      install_method => 'vcs',
      version        => 'master',
      config         => {
        email  => $role_xenocanto::conf::letsencrypt_email,
        server => $role_xenocanto::conf::letsencrypt_server,
      }
    }
    create_resources('role_xenocanto::ssl', $role_xenocanto::conf::letsencrypt_hash,{})
  }

  # Create instance, make sure ssl certs are installed first.
  class { 'role_xenocanto::instances': }

  # Create log directory and logrotate config
  file { '/var/log/xeno-canto':
    ensure  => directory,
    mode    => '0660',
    owner   => 'www-data',
    group   => 'root'
  }

  file { '/etc/logrotate.d/xenocanto':
    mode    => '0600',
    source  => 'puppet:///modules/role_xenocanto/logrotate_xenocanto',
    require => File['/var/log/xeno-canto']
  }

  # clone repository and create symlink to docroot
  class { 'role_xenocanto::repo': }

  file { $role_xenocanto::conf::docroot:
    ensure  => link,
    target  => $role_xenocanto::conf::git_repo_dir,
    require => Class['role_xenocanto::repo']
  }

  file { $role_xenocanto::conf::datadirs:
    ensure  => directory,
    mode    => '0775',
    owner   => 'www-data',
    group   => 'root',
  }

  file { "${role_xenocanto::conf::docroot}/sounds":
    ensure  => link,
    target  => '/data/sounds',
    require => File[$role_xenocanto::conf::datadirs]
  }

  file { "${role_xenocanto::conf::docroot}/ranges":
    ensure  => link,
    target  => '/data/ranges',
    require => File[$role_xenocanto::conf::datadirs]
  }

  file { "${role_xenocanto::conf::docroot}/graphics":
    ensure  => link,
    target  => '/data/graphics',
    require => File[$role_xenocanto::conf::datadirs]
  }

  file { "${role_xenocanto::conf::git_repo_dir}/cache":
    ensure  => directory,
    owner   => 'www-data',
    group   => 'root',
    require => Class['role_xenocanto::repo']
  }


  file { "${role_xenocanto::conf::docroot}/settings.yml":
    ensure    => 'present',
    content   =>  template('role_xenocanto/settings.yml.erb'),
    mode      => '0644',
    require   => File[$role_xenocanto::conf::docroot]
  }

  file { "${role_xenocanto::conf::docroot}/config.php":
    ensure    => 'present',
    content   =>  template('role_xenocanto/config.php.erb'),
    mode      => '0644',
    require   => File[$role_xenocanto::conf::docroot]
  }

  # install sonogen and typefind
  file { '/usr/local/bin/sonogen':
    mode    => '0755',
    source  => 'puppet:///modules/role_xenocanto/sonogen',
  }

  file { '/usr/local/bin/soundprint':
    mode    => '0755',
    source  => 'puppet:///modules/role_xenocanto/soundprint',
  }

  # Crontabs for xeno-canto
  cron { 'update-stats cronjob':
    command => "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && cd ${::role_xenocanto::conf::git_repo_dir} && php ./tasks/update-stats.php >> ${::role_xenocanto::conf::cron_log}",
    user    => root,
    minute  => 0,
    hour    => '*/2',
    require => Class['role_xenocanto::repo']
  }

  cron { 'mail notifications cronjob':
    command => "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && cd ${::role_xenocanto::conf::git_repo_dir} && php ./tasks/mail_notifications.php >> ${::role_xenocanto::conf::cron_log}",
    user    => root,
    minute  => 1,
    ensure  => $role_xenocanto::conf::ensure_mailnotifications,
    hour    => 0,
    require => Class['role_xenocanto::repo']
  }

  cron { 'rotate-play-stats cronjob':
    command => "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && cd ${::role_xenocanto::conf::git_repo_dir} && php ./tasks/rotate-play-stats.php >> ${::role_xenocanto::conf::cron_log}",
    user    => root,
    minute  => 15,
    hour    => 20,
    require => Class['role_xenocanto::repo']
  }

  cron { 'generate-full-sonos cronjob':
    command => "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && cd ${::role_xenocanto::conf::git_repo_dir} && php ./tasks/generate-full-sonos.php >> ${::role_xenocanto::conf::cron_log}",
    user    => root,
    minute  => '*/5',
    require => Class['role_xenocanto::repo']
  }

  cron { 'NBA json export':
    command => "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && cd ${::role_xenocanto::conf::git_repo_dir} && php ./tasks/nba-export.php '/data/minio/nba' >> ${::role_xenocanto::conf::cron_log}",
    user    => root,
    minute  => 55,
    hour    => 1,
    weekday => 1,
    require => Class['role_xenocanto::repo']
  }


# install rsync user and setup keys 
  class { 'role_xenocanto::rsync': }

}


