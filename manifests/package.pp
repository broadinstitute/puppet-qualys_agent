# @summary Manage the Qualys agent's package installation
#
# Install or uninstall the Qualys agent package
#
class qualys_agent::package {

  if $qualys_agent::manage_package {
    # Force package remove if agent ensure is "absent"
    $ensure = $qualys_agent::ensure ? {
      present => $qualys_agent::package_ensure,
      absent  => 'absent',
    }
  if $qualys_agent::download_package {
    archive { "/tmp/$qualys_agent::package_filename":
      ensure       => present,
      source       => $qualys_agent::package_url,
      proxy_server => $qualys_agent::proxy,
    }

    $provider = $facts['osfamily'] ? {
      'RedHat' => yum,
      default => dpkg
    }

    package { 'qualys_agent':
      ensure   => $ensure,
      source   => "/tmp/$qualys_agent::package_filename",
      name     => $qualys_agent::package_name,
      provider => $provider


    }
  } else {
    package { 'qualys_agent':
      ensure => $ensure,
      name   => $qualys_agent::package_name,
    }
  }

    # Do not create an ordering dependency if we are removing the agent
    $package_dep = $qualys_agent::ensure ? {
      present => Package['qualys_agent'],
      absent  => undef,
    }
  } else {
    $package_dep = undef
  }

  # Fix permissions on all paths used by the agent as the package does not do this on install
  $agent_paths = [
    '/usr/local/qualys',
    '/etc/qualys',
    '/var/spool/qualys',
  ]

  if $qualys_agent::ensure != 'absent' {
    file { $agent_paths :
      ensure  => 'directory',
      group   => $qualys_agent::group,
      owner   => $qualys_agent::owner,
      require => [$package_dep, $qualys_agent::user::user_dep, $qualys_agent::user::group_dep],
      recurse => true,
    }
    file { $qualys_agent::log_file_dir :
      ensure  => 'directory',
      group   => $qualys_agent::log_group_final,
      owner   => $qualys_agent::log_owner_final,
      require => $package_dep,
      recurse => false,
    }
  }
}
