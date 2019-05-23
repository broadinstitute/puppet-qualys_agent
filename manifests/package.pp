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
}
