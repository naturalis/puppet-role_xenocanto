# manifest for rsync functionality
class role_xenocanto::rsync (
) {
  # Create rsync group to allow dependencies
  group { 'rsync':
    ensure => present,
    gid    => '3001',
  }

  # Create special rsync user for backup sync
  user { 'rsync':
    ensure     => present,
    groups     => [ 'rsync','www-data' ],
    managehome => true,
  }

  file { '/home/rsync/.ssh':
    ensure => directory,
    owner  => 'rsync',
    group  => 'rsync',
    mode   => '0700',
  }

  file { '/home/rsync/.rsyncd.conf':
    ensure => present,
    owner  => 'rsync',
    group  => 'rsync',
    mode   => '0644',
    source => 'puppet:///modules/role_xenocanto/rsyncd.conf',
  }

  $rsync_ssh_defaults = {
    'ensure'  => present,
    'user'    => 'rsync',
    'type'    => 'ssh-rsa',
  }

  $rsync_keys = {
    'rsync' => {
      key     => $::role_xenocanto::conf::rsync_pub_key,
    },
  }

  if ($::role_xenocanto::conf::rsync_media == true){
    cron { 'rsync media':
      command => '/usr/local/sbin/rsync_media.sh',
      user    => root,
      hour    => $::role_xenocanto::conf::rsync_cron_hour,
      minute  => $::role_xenocanto::conf::rsync_cron_minute,
      weekday => $::role_xenocanto::conf::rsync_cron_weekday
    }

    # Script to rsync media files from production to test
    file { '/usr/local/sbin/rsync_media.sh':
      content => template('role_xenocanto/rsync_media.erb'),
      mode   => '0755',
    }

    # Rsync data at schedules time
    file { '/etc/logrotate.d/rsync_media':
      source => 'puppet:///modules/role_xenocanto/rsync_logrotate',
      mode   => '0644',
    }

    # Place rsync ssh private key
    file { '/home/rsync/.ssh/id_rsa':
      mode    => '0600',
      owner   => 'rsync',
      content => $::role_xenocanto::conf::rsync_priv_key,
      require => File['/home/rsync/.ssh'],
    }
  }

  create_resources(ssh_authorized_key, $rsync_keys, $rsync_ssh_defaults)
}
