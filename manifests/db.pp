# == Class: role_xenocanto::db
#
class role_xenocanto::db {

  # Install MySQL
  class { '::role_mysql':
    mysql_root_password => undef,
    override_options    => undef,
    users               => undef,
    grants              => undef,
    db_hash             => undef,
  }

}
