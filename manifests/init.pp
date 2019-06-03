# Class: qualys_agent
# ===========================
#
# Manage an installation of the Qualys Cloud Agent
#
# Parameters
# ----------
#
# * `ensure`
# Ensure that the Qualys agent is present on the system, or absent.
#
# * `activation_id`
# The Activation ID you receive from Qualys for reporting back to their API (required)
#
# * `agent_group`
# The group that should run the agent (Default: undef)
#
# * `agent_user`
# The user that should run the agent (Default: undef)
#
# * `cmd_max_timeout`
# The CmdMaxTimeOut value in qualys-cloud-agent.conf (Default: 1800)
#
# * `cmd_stdout_size`
# The CmdStdOutSize value in qualys-cloud-agent.conf (Default: 1024)
#
# * `conf_dir`
# The directory where the qualys-cloud-agent.conf file will exist (Default: /etc/qualys/cloud-agent)
#
# * `customer_id`
# The Customer ID you receive from Qualys for reporting back to their API (required)
#
# * `log_dest_type`
# The log type (file or syslog) (Default: file)
#
# * `log_file_dir`
# The LogFileDir value in qualys-cloud-agent.conf
# The directory in which the log files should be written (Default: /var/log/qualys)
#
# * `log_level`
# The LogLevel value in qualys-cloud-agent.conf (Default: 3)
#
# * `package_name`
# The name of the package to install (Default: qualys-cloud-agent)
#
# * `process_priority`
# The ProcessPriority value in qualys-cloud-agent.conf (Default: 0)
#
# * `request_timeout`
# The RequestTimeOut value in qualys-cloud-agent.conf (Default: 600)
#
# * `service_enable`
# Boolean to determine whether the service is enabled or not (Default: true)
#
# * `service_ensure`
# Ensure that the Qualys agent is running on the system, or stopped (Default: running)
#
# * `service_name`
# The name of the Qualys agent service (Default: qualys-cloud-agent)
#
# * `sudo_command`
# The SudoCommand value in qualys-cloud-agent.conf (Default: sudo)
#
# * `sudo_user`
# The SudoUser value in qualys-cloud-agent.conf (Default: undef)
#
# * `use_audit_dispatcher`
# The UseAuditDispatcher value in qualys-cloud-agent.conf (Default: 1)
#
# * `use_sudo`
# The UseSudo value in qualys-cloud-agent.conf (Default: 0)
#
# * `user_group`
# The UserGroup value in qualys-cloud-agent.conf (Default: root)
#
# * `version`
# The version of the Qualys agent package to install (Default: undef)
#
# Examples
# --------
#
# @example
#    class { 'qualys_agent':
#      activation_id => 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
#      customer_id   => 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
#    }
#
# Authors
# -------
#
# Andrew Teixeira <teixeira@broadinstitute.org>
#
# Copyright
# ---------
#
# Copyright 2019 Broad Institute
#
class qualys_agent (
  Enum['absent', 'present'] $ensure,
  String $activation_id,
  Optional[String] $agent_group,
  Optional[String] $agent_user,
  Stdlib::Absolutepath $agent_user_homedir,
  Integer $cmd_max_timeout,
  Integer $cmd_stdout_size,
  Stdlib::Absolutepath $conf_dir,
  String $customer_id,
  Enum['file', 'syslog'] $log_dest_type,
  Stdlib::Absolutepath $log_file_dir,
  Integer $log_level,
  Boolean $manage_group,
  Boolean $manage_service,
  Boolean $manage_user,
  String $package_name,
  Integer $process_priority,
  Integer $request_timeout,
  Boolean $service_enable,
  Enum['running', 'stopped'] $service_ensure,
  String $service_name,
  String $sudo_command,
  Optional[String] $sudo_user,
  Integer $use_audit_dispatcher,
  Integer $use_sudo,
  Optional[String] $user_group,
  Optional[String] $version,
) {

  # Protect against an bad setting for log_file_dir
  if $::qualys_agent::log_file_dir == '/' {
    fail('The log file directory is set to /.  Installation cannot continue.')
  }

  if $::qualys_agent::agent_user {
    $owner = $::qualys_agent::agent_user
  } else {
    $owner = 'root'
  }

  contain 'qualys_agent::user'
  contain 'qualys_agent::package'
  contain 'qualys_agent::config'
  contain 'qualys_agent::service'

  Class['qualys_agent::user']
  -> Class['qualys_agent::package']
  -> Class['qualys_agent::config']
  -> Class['qualys_agent::service']
}
