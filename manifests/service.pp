# @summary Configure the Qualys agent service
#
# Manage the system service that runs the Qualys agent
#
class qualys_agent::service {

  if $::qualys_agent::manage_service {
    service { 'qualys_agent':
      ensure  => $::qualys_agent::service_ensure,
      enable  => $::qualys_agent::service_enable,
      name    => $::qualys_agent::service_name,
      require => [
        Package['qualys_agent'],
        File['qualys_config'],
        File['qualys_log_config'],
        File['qualys_udc_log_config'],
      ],
    }
  }
}
