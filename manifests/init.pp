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
# * `hostid_path`
# The full filesystem path to the hostid file (Default: /etc/qualys/hostid)
#
# * `hostid_search_dir`
# The HostIdSearchDir value in qualys-cloud-agent.conf (Default: undef)
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
# * `manage_group`
# Boolean to determine whether the group is managed by Puppet or not (Default: true)
#
# * `manage_package`
# Boolean to determine whether the package is managed by Puppet or not (Default: true)
#
# * `manage_service`
# Boolean to determine whether the service is managed by Puppet or not (Default: true)
#
# * `manage_user`
# Boolean to determine whether the user is managed by Puppet or not (Default: true)
#
# * `package_ensure`
# The "ensure" value for the Qualys agent package. This value can be "installed", "absent",
# or a version number if you want to specify a specific package version numer. (Default: installed)
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
# The UserGroup value in qualys-cloud-agent.conf (Default: undef)
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
  Stdlib::Absolutepath $hostid_path,
  Optional[Stdlib::Absolutepath] $hostid_search_dir,
  Enum['file', 'syslog'] $log_dest_type,
  Stdlib::Absolutepath $log_file_dir,
  Integer $log_level,
  Boolean $manage_group,
  Boolean $manage_package,
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
) {

  # Protect against an bad setting for filesystem paths
  if $::qualys_agent::agent_user_homedir == '/' {
    fail('agent_user_homedir is set to /.  Installation cannot continue.')
  }
  if $::qualys_agent::conf_dir == '/' {
    fail('conf_dir is set to /.  Installation cannot continue.')
  }
  if $::qualys_agent::hostid_path == '/' {
    fail('hostid_path is set to /.  Installation cannot continue.')
  }
  if $::qualys_agent::hostid_search_dir == '/' {
    fail('hostid_path is set to /.  Installation cannot continue.')
  }
  if $::qualys_agent::log_file_dir == '/' {
    fail('log_file_dir is set to /.  Installation cannot continue.')
  }

  if $::qualys_agent::agent_user {
    $owner = $::qualys_agent::agent_user
  } else {
    $owner = 'root'
  }

  if $::qualys_agent::user_group {
    $group = $::qualys_agent::user_group
  } else {
    $group = 'root'
  }

  contain 'qualys_agent::user'
  contain 'qualys_agent::package'
  contain 'qualys_agent::config'
  contain 'qualys_agent::service'
}
