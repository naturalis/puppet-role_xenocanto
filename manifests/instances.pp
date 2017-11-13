# Create all virtual hosts from hiera
class role_xenocanto::instances (
)
{
  create_resources('apache::vhost', $role_xenocanto::conf::instances)
  if ($role_xenocanto::conf::enable_ssl == true) {
    create_resources('apache::vhost', $role_xenocanto::conf::ssl_instances)
  }
}
