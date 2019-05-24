# @summary Manage the Qualys agent's package installation
#
# Install or uninstall the Qualys agent package
#
class qualys_agent::package {

  if $::qualys_agent::ensure == 'present' {
    if $::qualys_agent::version {
      $ensure = $::qualys_agent::version
    } else {
      $ensure = $::qualys_agent::ensure
    }
  } else {
    $ensure = $::qualys_agent::ensure
  }
  package { 'qualys_agent':
    ensure => $ensure,
    name   => $::qualys_agent::package_name,
  }

  # Fix permissions on all paths used by the agent as the package does not do this on install
  $agent_paths = [
    '/usr/local/qualys',
    '/etc/qualys',
    '/var/spool/qualys',
    $::qualys_agent::log_file_dir,
  ]

  file { $agent_paths :
    ensure  => 'directory',
    group   => $::qualys_agent::agent_group,
    owner   => $::qualys_agent::agent_user,
    require => User[$::qualys_agent::agent_user],
    recurse => true,
  }
}
