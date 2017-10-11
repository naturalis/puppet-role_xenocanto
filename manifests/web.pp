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

  # Create Apache Virtual host
  create_resources('apache::vhost', $role_xenocanto::web::instances)

  # Check out scripts repo
  vcsrepo { 'xenocanto git repo':
    path     => $::role_xenocanto::conf::git_repo_dir,
    ensure   => present,
    provider => git,
    source   => $::role_xenocanto::conf::git_repo_url,
    revision => $::role_xenocanto::conf::git_repo_rev,
    user     => 'root',
    require  => [
      File['/root/.ssh/id_rsa'],
      Sshkey['xenocanto'],
    ]
  }



  # Create log directory and logrotate config
  file { '/var/log/xenocanto':
    ensure  => directory,
    mode    => '0660',
    owner   => 'www-data',
    group   => 'root'
  }

  file { '/etc/logrotate.d/xenocanto':
    mode    => '0600',
    source  => 'puppet:///modules/role_xenocanto/logrotate_xenocanto',
    require => File['/var/log/xenocanto']
  }

  class { 'role_xenocanto::repo': }

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

  cron { 'rotate-play-stats cronjob':
    command => "/usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin cd ${::role_xenocanto::conf::git_repo_dir}; php ./tasks/generate-full-sonos.php > /dev/null",
    user    => root,
    minute  => '*/5',
    require => Class['role_xenocanto::repo']
  }




}



