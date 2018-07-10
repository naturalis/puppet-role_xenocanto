# == Class: role_xenocanto::ssl
#
# ssl code for enabline ssl with or without letsencrypt
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
define role_xenocanto::ssl (
  $letsencrypt_domains,
  $cert_file            = "/etc/letsencrypt/live/${letsencrypt_domains[0]}/cert.pem",
  $cert_name            = $title,
  $cert_renew_days      = '30', # don't set this higher than 30 due to --keep-until-renewal option
  $cert_warning_days    = '14',
  $cert_critical_days   = '7',
  $webservice           = 'apache2',
)
{

  class { 'apache::mod::ssl':
    ssl_compression => false,
    ssl_options     => [ 'StdEnvVars' ],
  }

# install letsencrypt certs only without crontab
  letsencrypt::certonly { $title:
    domains                 => $letsencrypt_domains,
    manage_cron             => false,
    webservice              => $webservice,
    plugin                  => 'standalone',
    require                 => Class['::letsencrypt']
  }

# create check script from template
  file { "/usr/local/sbin/chkcert_${title}.sh":
    mode    => '0755',
    content => template('role_xenocanto/checkcert.sh.erb'),
  }

# create command for renewal of certificate
  $command_start = "${letsencrypt::venv_path}/bin/letsencrypt --text --agree-tos --non-interactive certonly -a standalone --expand --keep-until-expiring "
  $command_domains = inline_template('-d <%= @letsencrypt_domains.join(" -d ")%>')
  $command = "${command_start}${command_domains}${command_end}"


  exec { "letsencrypt renew cert ${title}":
    command     => "service ${webservice} stop && ${command} && service ${webservice} start",
    path        => ['/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin','/snap/bin',],
    environment => "VENV_PATH=${letsencrypt::venv_path}",
    require     => Class['letsencrypt'],
    onlyif      => "/usr/local/sbin/chkcert_${title}.sh | grep renew 2>/dev/null"
  }

# export check so sensu monitoring can make use of it
  @sensu::check { "Check certificate ${title}":
    command => "/usr/local/sbin/chkcert_${title}.sh sensu",
    tag     => 'central_sensu',
}


}

