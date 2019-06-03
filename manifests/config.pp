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

  file { 'qualys_config':
    ensure    => $ensure,
    content   => epp('qualys_agent/qualys-cloud-agent.conf.epp', {
      activation_id        => $::qualys_agent::activation_id,
      cmd_max_timeout      => $::qualys_agent::cmd_max_timeout,
      cmd_stdout_size      => $::qualys_agent::cmd_stdout_size,
      customer_id          => $::qualys_agent::customer_id,
      log_file_dir         => $::qualys_agent::log_file_dir,
      log_level            => $::qualys_agent::log_level,
      process_priority     => $::qualys_agent::process_priority,
      request_timeout      => $::qualys_agent::request_timeout,
      sudo_command         => $::qualys_agent::sudo_command,
      use_audit_dispatcher => $::qualys_agent::use_audit_dispatcher,
      use_sudo             => $::qualys_agent::use_sudo,
      user                 => $::qualys_agent::agent_user,
      user_group           => $::qualys_agent::user_group,
    }),
    group     => $::qualys_agent::agent_group,
    mode      => '0600',
    name      => "${qualys_agent::conf_dir}/qualys-cloud-agent.conf",
    owner     => $::qualys_agent::owner,
    show_diff => true,
    notify    => Service['qualys_agent'],
    require   => [
      Package['qualys_agent'],
      User['qualys_user'],
    ],
  }

  include qualys_agent::config::qagent_log
  include qualys_agent::config::qagent_udc_log
}
