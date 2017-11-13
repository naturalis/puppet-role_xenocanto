# == Class: role_xenocanto::ssl
#
# ssl code for enabline ssl with or without letsencrypt
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
#
class role_xenocanto::ssl (
)
{

# Install modssl when ssl is enabled
  if ($role_xenocanto::conf::enable_ssl == true) {
    class { 'apache::mod::ssl':
      ssl_compression => false,
      ssl_options     => [ 'StdEnvVars' ],
    }
  }

# install letsencrypt certs only and crontab
  if ($role_xenocanto::conf::enable_letsencrypt == true) {
    class { ::letsencrypt:
      install_method => 'vcs',
      config => {
        email  => $role_xenocanto::conf::letsencrypt_email,
        server => $role_xenocanto::conf::letsencrypt_server,
      }
    }
    letsencrypt::certonly { 'letsencrypt_cert':
      domains       => $role_xenocanto::conf::letsencrypt_domains,
      manage_cron   => true,
      cron_before_command => 'service apache2 stop',
      cron_success_command => 'service apache2 start',
    }
  }
}

