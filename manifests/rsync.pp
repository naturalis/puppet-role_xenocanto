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

  # Add authorized ssh keys
  $rsync_ssh_options = [
    'command="rsync --config=/home/rsync/.rsyncd.conf --server --daemon ."',
    'no-agent-forwarding',
    'no-port-forwarding',
    'no-pty',
    'no-user-rc',
    'no-X11-forwarding'
  ]

  $rsync_ssh_defaults = {
    'ensure'  => present,
    'user'    => 'rsync',
    'type'    => 'ssh-rsa',
    'options' => $rsync_ssh_options,
  }

  $rsync_keys = {
    'rsync' => {
      key     => $::role_xenocanto::conf::rsync_pub_key,
    },
  }

  create_resources(ssh_authorized_key, $rsync_keys, $rsync_ssh_defaults)
}
