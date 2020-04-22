# Class: qualys_agent::config::qagent_udc_log
#
# Manage the main qagent-udc-log.conf configuration file
#
class qualys_agent::config::qagent_udc_log {

  file { 'qualys_udc_log_config':
    ensure  => $qualys_agent::config::ensure,
    content => epp('qualys_agent/qagent-log.conf.epp', {
      channel_name => $qualys_agent::config::channel_name,
      log_path     => "${qualys_agent::log_file_dir}/qualys-udc-scan.log",
    }),
    group   => $qualys_agent::group,
    mode    => '0600',
    path    => "${qualys_agent::conf_dir}/qagent-udc-log.conf",
    owner   => $qualys_agent::owner,
    require => $qualys_agent::config::requires,
  }

  if $qualys_agent::ensure != 'absent' {
    file { "${qualys_agent::log_file_dir}/qualys-udc-scan.log" :
      ensure  => $qualys_agent::config::ensure,
      group   => $qualys_agent::log_group_final,
      mode    => $qualys_agent::log_mode,
      owner   => $qualys_agent::log_owner_final,
      require => File[$qualys_agent::log_file_dir],
    }
  }
}
