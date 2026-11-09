#
# @summary Install and run the Qualys agent on Windows
#
# On Windows, the agent is configured through the options passed to the installer
# (`QualysCloudAgent.exe`), so no configuration file is managed.
#
# @api private
#
class qualys_agent::windows {
  assert_private()

  if $qualys_agent::ensure == 'present' {
    if $qualys_agent::manage_package {
      if $qualys_agent::package_source =~ Undef {
        fail('package_source must be set on Windows.  Installation cannot continue.')
      }
      if $qualys_agent::webservice_uri =~ Undef {
        fail('webservice_uri must be set on Windows.  Installation cannot continue.')
      }
      if $qualys_agent::package_download_dir =~ Undef {
        fail('package_download_dir must be set on Windows.  Installation cannot continue.')
      }

      # Fixed local name: the source may be a URL without a usable file name
      # (query string, download API), and the windows provider requires `.exe`.
      $installer = "${qualys_agent::package_download_dir}\\QualysCloudAgent.exe"

      file { 'qualys_installer':
        ensure => 'file',
        path   => $installer,
        source => $qualys_agent::package_source,
      }

      # Puppet cannot redact install_options (it is a parameter, not a property),
      # so the IDs are unwrapped here and passed to the installer in clear text.
      $base_options = [
        "CustomerId={${qualys_agent::customer_id.unwrap}}",
        "ActivationId={${qualys_agent::activation_id.unwrap}}",
        "WebServiceUri=${qualys_agent::webservice_uri}",
      ]
      $golden_image_option = $qualys_agent::golden_image ? {
        undef   => [],
        default => ["GoldenImage=${qualys_agent::golden_image}"],
      }

      package { 'qualys_agent':
        ensure          => $qualys_agent::package_ensure,
        name            => $qualys_agent::package_name,
        provider        => 'windows',
        source          => $installer,
        install_options => $base_options + $golden_image_option,
        require         => File['qualys_installer'],
      }
      $package_dep = Package['qualys_agent']
    } else {
      $package_dep = undef
    }

    if $qualys_agent::manage_service {
      service { 'qualys_agent':
        ensure    => $qualys_agent::service_ensure,
        enable    => $qualys_agent::service_enable,
        name      => $qualys_agent::service_name,
        subscribe => $package_dep,
      }
    }
  } elsif $qualys_agent::manage_package {
    # Uninstalling the package also removes the service
    package { 'qualys_agent':
      ensure   => 'absent',
      name     => $qualys_agent::package_name,
      provider => 'windows',
    }
  }
}
