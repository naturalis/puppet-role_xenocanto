# == Class: role_xenocanto::db
#
class role_xenocanto::db {

  # Include conf file with parameter settings
  include role_xenocanto::conf

  # Install MySQL
  class { '::role_mysql':
    mysql_root_password => $role_xenocanto::conf::mysql_root_password,
    override_options    => $role_xenocanto::conf::override_options,
    users               => $role_xenocanto::conf::users,
    grants              => $role_xenocanto::conf::grants,
    db_hash             => $role_xenocanto::conf::db_hash,
  }

}
