# == Class: role_xenocanto::web
#
# This role creates the necessary configuration for the xeno canto webserver
#
class role_xenocanto::web (
) {
  # Install support packages
  package { $role_xenocanto::conf::web_packages:
    ensure      => installed,
  }

  # Install Postfix mail server
  class { 'role_xenocanto::mail': }

  # Install PHP with FPM
  class { '::php':
    manage_repos => true,
    ensure     => present,
    fpm        => true,
    extensions => {
      mysql  => {},
      mcrypt => {},
      curl   => {},
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
  class { 'apache::mod::php': }

  # Create Apache Virtual host
  create_resources('apache::vhost', $role_xenocanto::conf::instances)

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
    command => "/usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin cd ${::role_xenocanto::conf::git_repo_dir}; php ./tasks/update-stats.php > /dev/null",
    user    => root,
    minute  => 0,
    hour    => '*/2',
    require => Class['role_xenocanto::repo']
  }

  cron { 'mail notifications cronjob':
    command => "/usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin cd ${::role_xenocanto::conf::git_repo_dir}; php ./tasks/mail_notifications.php > /dev/null",
    user    => root,
    minute  => 1,
    hour    => 0,
    require => Class['role_xenocanto::repo']
  }

  cron { 'rotate-play-stats cronjob':
    command => "/usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin cd ${::role_xenocanto::conf::git_repo_dir}; php ./tasks/rotate-play-stats.php > /dev/null",
    user    => root,
    minute  => 15,
    hour    => 20,
    require => Class['role_xenocanto::repo']
  }

  cron { 'generate-full-sonos cronjob':
    command => "/usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin cd ${::role_xenocanto::conf::git_repo_dir}; php ./tasks/generate-full-sonos.php > /dev/null",
    user    => root,
    minute  => '*/5',
    require => Class['role_xenocanto::repo']
  }

}



