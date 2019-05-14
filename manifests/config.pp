# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include qualys_agent::config
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
