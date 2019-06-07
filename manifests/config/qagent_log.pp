# @summary Configure the Qualys agent
#
# Manage the main qagent-log.conf configuration file
class qualys_agent::config::qagent_log {

  file { 'qualys_log_config':
    ensure  => $qualys_agent::config::ensure,
    content => epp('qualys_agent/qagent-log.conf.epp', {
      channel_name => $qualys_agent::config::channel_name,
      log_path     => "${qualys_agent::log_file_dir}/qualys-cloud-agent.log",
    }),
    group   => $qualys_agent::group,
    mode    => '0600',
    path    => "${qualys_agent::conf_dir}/qagent-log.conf",
    owner   => $qualys_agent::owner,
    require => $qualys_agent::config::requires,
  }

}
