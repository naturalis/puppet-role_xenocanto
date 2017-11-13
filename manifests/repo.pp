# == Class: role_xenocanto::repo
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_xenocanto::repo (
){


# ensure git package for repo checkouts, conflicts with letsencrypt so only when letsencrypt is disabled.



  if ( $role_xenocanto::conf::enable_letsencrypt == false ) {
    package { 'git':
      ensure => installed,
    }
  }

  file { $role_xenocanto::conf::git_repo_rootdirs:
    ensure    => directory,
  }

  file { '/root/.ssh':
    ensure    => directory,
  }->
  file { "/root/.ssh/${role_xenocanto::conf::git_repo_keyname}":
    ensure    => 'present',
    content   => $role_xenocanto::conf::git_repo_key,
    mode      => '0600',
  }->
  file { '/root/.ssh/config':
    ensure    => 'present',
    content   =>  template('role_xenocanto/sshconfig.erb'),
    mode      => '0600',
  }->
  file{ '/usr/local/sbin/known_hosts.sh' :
    ensure    => 'present',
    mode      => '0700',
    source    => 'puppet:///modules/role_xenocanto/known_hosts.sh',
  }->
  exec{ 'add_known_hosts' :
    command   => '/usr/local/sbin/known_hosts.sh',
    path      => '/sbin:/usr/bin:/usr/local/bin/:/bin/',
    provider  => shell,
    user      => 'root',
    unless    => 'test -f /root/.ssh/known_hosts'
  }->
  file{ '/root/.ssh/known_hosts':
    mode      => '0600',
  }->
  vcsrepo { $role_xenocanto::conf::git_repo_dir:
    ensure    => $role_xenocanto::conf::git_repo_ensure,
    provider  => git,
    source    => $role_xenocanto::conf::git_repo_source,
    user      => 'root',
    revision  => $role_xenocanto::conf::git_repo_revision,
    require   => [File[$role_xenocanto::conf::git_repo_rootdirs],Package['git']],
  }

}

