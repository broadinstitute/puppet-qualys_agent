# @summary Configure the Qualys agent
#
# Manage the main qualys-cloud-agent.conf configuration file.  This class also includes the `qagent_log` and
# `qagent_udc_log` subclasses to configure both log configuration files.
#
class qualys_agent::config {

  if $qualys_agent::log_dest_type == 'file' {
    $channel_name = 'c3'
  } else {
    $channel_name = 'c2'
  }

  if $qualys_agent::ensure == 'present' {
    $ensure = 'file'
  } else {
    $ensure = $qualys_agent::ensure
  }

  file { "${qualys_agent::conf_dir}/qualys-cloud-agent.conf":
    ensure  => $ensure,
    owner   => $::qualys_agent::agent_user,
    group   => $::qualys_agent::agent_group,
    mode    => '0600',
    content => template('qualys_agent/qualys-cloud-agent.conf.erb'),
  }

  include qualys_agent::config::qagent_log
  include qualys_agent::config::qagent_udc_log
}
