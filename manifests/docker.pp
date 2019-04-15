# == Class: role_xenocanto::docker
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
# === Copyright
#
# Apache2 license 2017.
#
class role_xenocanto::docker (
  $compose_version              = '1.17.1',
  $repo_source                  = 'https://github.com/naturalis/docker-xenocanto.git',
  $repo_ensure                  = 'latest',
  $repo_dir                     = '/opt/docker-xenocanto',
  $git_branch                   = 'master',
  $composer_allow_superuser     = '1',
  $minio_url                    = 'testxc-minio.naturalis.nl',
  $minio_access_key             = '12345',
  $minio_secret_key             = '12345678',
  $traefik_toml_file            = '/opt/traefik/traefik.toml',
  $traefik_acme_json            = '/opt/traefik/acme.json',
  $cert_file                    = $role_xenocanto::conf::letsencrypt_hash['xc']['letsencrypt_domains']['0'],
  $cert_key                     = $role_xenocanto::conf::letsencrypt_hash['xc']['letsencrypt_domains']['0'],
){

  include 'docker'
  include 'stdlib'

  Exec {
    path => '/usr/local/bin/',
    cwd  => $role_xenocanto::docker::repo_dir,
  }

  file { ['/data/minio','/data/minio/ranges','/data/minio/batch','/opt/traefik']:
    ensure              => directory,
    mode                => '0775',
    require             => Class['docker'],
  }

  file { $role_xenocanto::docker::repo_dir:
    ensure              => directory,
    mode                => '0770',
  }


  file { "${role_xenocanto::docker::repo_dir}/.env":
    ensure   => file,
    mode     => '0600',
    content  => template('role_xenocanto/env.erb'),
    require  => Vcsrepo[$role_xenocanto::docker::repo_dir],
    notify   => Exec['Restart containers on change'],
  }

  file { $traefik_toml_file :
    ensure   => file,
    content  => template('role_xenocanto/traefik.toml.erb'),
    require  => File['/opt/traefik'],
    notify   => Exec['Restart containers on change'],
  }


  class {'docker::compose': 
    ensure      => present,
    version     => $role_xenocanto::docker::compose_version,
    notify      => Exec['apt_update']
  }

  docker_network { 'web':
    ensure   => present,
  }

  ensure_packages(['git','python3'], { ensure => 'present' })

  vcsrepo { $role_xenocanto::docker::repo_dir:
    ensure    => $role_xenocanto::docker::repo_ensure,
    source    => $role_xenocanto::docker::repo_source,
    provider  => 'git',
    user      => 'root',
    revision  => 'master',
    require   => [Package['git'],File[$role_xenocanto::docker::repo_dir]]
  }

  docker_compose { "${role_xenocanto::docker::repo_dir}/docker-compose.yml":
    ensure      => present,
    require     => [
      Vcsrepo[$role_xenocanto::docker::repo_dir],
      Docker_network['web'],
      File["${role_xenocanto::docker::repo_dir}/.env"],
      File[$traefik_toml_file]
    ]
  }

  exec { 'Pull containers' :
    command  => 'docker-compose pull',
    schedule => 'everyday',
  }

  exec { 'Up the containers to resolve updates' :
    command  => 'docker-compose up -d',
    schedule => 'everyday',
    require  => Exec['Pull containers']
  }

  exec {'Restart containers on change':
    refreshonly => true,
    command     => 'docker-compose up -d',
    require     => Docker_compose["${role_xenocanto::docker::repo_dir}/docker-compose.yml"]
  }

  # deze gaat per dag 1 keer checken
  # je kan ook een range aan geven, bv tussen 7 en 9 's ochtends
  schedule { 'everyday':
     period  => daily,
     repeat  => 1,
     range => '5-7',
  }

}
