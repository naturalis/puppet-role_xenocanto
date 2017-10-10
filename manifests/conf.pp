# == Class role_xenocanto::conf
#
# All configurable settings
#
class role_xenocanto::conf (

  # ::web
  $git_repo_key_php,
  $git_repo_url          = 'ssh://git@github.com/xeno-canto/code.git',
  $git_repo_ensure       = 'latest',
  $git_repo_rev          = 'master',

  # ::db
  $mysql_root_password,
  $override_options,
  $users,
  $grants,
  $db_hash,

  $web_host            = '127.0.0.1',
  $db_host             = '127.0.0.1',
  $db_name             = 'xenocanto',

) {




}
