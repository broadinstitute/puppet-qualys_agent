#
# @summary Manage an installation of the Qualys Cloud Agent
#
# @example
#    class { 'qualys_agent':
#      activation_id => 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
#      customer_id   => 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
#    }
#
# @param ensure
#   Ensure that the Qualys agent is present on the system, or absent.
#
# @param activation_id
#   The Activation ID you receive from Qualys for reporting back to their API (required)
#
# @param agent_group
#   The group that should run the agent.  This also will be the UserGroup setting in the configuration file. (Default: `undef`)
#
# @param agent_user
#   The user that should run the agent (Default: `undef`)
#
# @param agent_user_homedir
#   The fully qualified path to the agent user's home directory (Default: `/usr/local/qualys`)
#
# @param cmd_max_timeout
#   The CmdMaxTimeOut value in qualys-cloud-agent.conf (Default: `1800`)
#
# @param cmd_stdout_size
#   The CmdStdOutSize value in qualys-cloud-agent.conf (Default: `1024`)
#
# @param conf_dir
#   The directory where the qualys-cloud-agent.conf file will exist (Default: `/etc/qualys/cloud-agent`)
#
# @param customer_id
#   The Customer ID you receive from Qualys for reporting back to their API (required)
#
# @param env_dir
#   The directory in which to place the environment variable file qualys-cloud-agent.  (Default: `/etc/sysconfig`)
#
# @param hostid_path
#   The full filesystem path to the hostid file (Default: `/etc/qualys/hostid`)
#
# @param hostid_search_dir
#   The HostIdSearchDir value in qualys-cloud-agent.conf (Default: `undef`)
#
# @param https_proxy
#   The https proxy to be used for all commands performed by the Cloud Agent. (Default: `undef`)
#
# @param log_dest_type
#   The log type (file or syslog) (Default: `file`)
#
# @param log_file_dir
#   The LogFileDir value in qualys-cloud-agent.conf
#   The directory in which the log files should be written (Default: `/var/log/qualys`)
#
# @param log_group
#   The group that should own files in the log directory (Default: `$agent_group`)
#
# @param log_level
#   The LogLevel value in qualys-cloud-agent.conf (Default: `3`)
#
# @param log_mode
#   The file mode for log files in $log_file_dir (Default: `0600`)
#
# @param log_owner
#   The user that should own files in the log directory (Default: `$agent_user`)
#
# @param manage_group
#   Boolean to determine whether the group is managed by Puppet or not (Default: `true`)
#
# @param manage_package
#   Boolean to determine whether the package is managed by Puppet or not (Default: `true`)
#
# @param manage_service
#   Boolean to determine whether the service is managed by Puppet or not (Default: `true`)
#
# @param manage_user
#   Boolean to determine whether the user is managed by Puppet or not (Default: `true`)
#
# @param package_ensure
#   The "ensure" value for the Qualys agent package. This value can be "installed", "absent",
#   or a version number if you want to specify a specific package version numer. (Default: `installed`)
#
# @param package_name
#   The name of the package to install (Default: `qualys-cloud-agent`)
#
# @param process_priority
#   The ProcessPriority value in qualys-cloud-agent.conf (Default: `0`)
#
# @param qualys_https_proxy
#   The https proxy to be used by the Cloud Agent to communicate with qualys cloud platform. (Default: `undef`)
#
# @param request_timeout
#   The RequestTimeOut value in qualys-cloud-agent.conf (Default: `600`)
#
# @param service_enable
#   Boolean to determine whether the service is enabled or not (Default: `true`)
#
# @param service_ensure
#   Ensure that the Qualys agent is running on the system, or stopped (Default: `running`)
#
# @param service_name
#   The name of the Qualys agent service (Default: `qualys-cloud-agent`)
#
# @param sudo_command
#   The SudoCommand value in qualys-cloud-agent.conf (Default: `sudo`)
#
# @param sudo_user
#   The SudoUser value in qualys-cloud-agent.conf (Default: `undef`)
#
# @param use_audit_dispatcher
#   The UseAuditDispatcher value in qualys-cloud-agent.conf (Default: `1`)
#
# @param use_sudo
#   The UseSudo value in qualys-cloud-agent.conf (Default: `0`)
#
# @param webservice_uri
#   The ServerUri value in qualys-cloud-agent.conf (Default: `undef`)
#
class qualys_agent (
  Integer $log_level,
  String $log_mode,
  Boolean $manage_group,
  Boolean $manage_package,
  Boolean $manage_service,
  Boolean $manage_user,
  String $package_ensure,
  String $package_name,
  Integer $process_priority,
  Integer $request_timeout,
  Boolean $service_enable,
  String $service_name,
  String $sudo_command,
  String $sudo_user,
  Integer $use_audit_dispatcher,
  Integer $use_sudo,
  Stdlib::Absolutepath $log_file_dir,
  Enum['running', 'stopped'] $service_ensure,
  Optional[String] $webservice_uri,
  Optional[String] $agent_group,
  Optional[String] $agent_user,
  Optional[Stdlib::Absolutepath] $hostid_search_dir,
  Optional[String] $https_proxy,
  Optional[String] $log_group,
  Optional[String] $log_owner,
  Optional[String] $qualys_https_proxy,
  Enum['absent', 'present'] $ensure,
  Variant[String[1], Sensitive[String[1]]] $activation_id,
  Stdlib::Absolutepath $agent_user_homedir,
  Integer $cmd_max_timeout,
  Integer $cmd_stdout_size,
  Stdlib::Absolutepath $conf_dir,
  Variant[String[1], Sensitive[String[1]]] $customer_id,
  Stdlib::Absolutepath $env_dir,
  Stdlib::Absolutepath $hostid_path,
  Enum['file', 'syslog'] $log_dest_type = 'file',
) {
  # Protect against an bad setting for filesystem paths
  if $qualys_agent::agent_user_homedir == '/' {
    fail('agent_user_homedir is set to /.  Installation cannot continue.')
  }
  if $qualys_agent::conf_dir == '/' {
    fail('conf_dir is set to /.  Installation cannot continue.')
  }
  if $qualys_agent::hostid_path == '/' {
    fail('hostid_path is set to /.  Installation cannot continue.')
  }
  if $qualys_agent::hostid_search_dir == '/' {
    fail('hostid_search_dir is set to /.  Installation cannot continue.')
  }
  if $qualys_agent::log_file_dir == '/' {
    fail('log_file_dir is set to /.  Installation cannot continue.')
  }

  if $qualys_agent::agent_group {
    $group = $qualys_agent::agent_group
  } else {
    $group = 'root'
  }

  if $qualys_agent::agent_user {
    $owner = $qualys_agent::agent_user
  } else {
    $owner = 'root'
  }

  if $qualys_agent::log_group {
    $log_group_final = $qualys_agent::log_group
  } else {
    $log_group_final = $group
  }

  if $qualys_agent::log_owner {
    $log_owner_final = $qualys_agent::log_owner
  } else {
    $log_owner_final = $owner
  }

  contain 'qualys_agent::user'
  contain 'qualys_agent::package'
  contain 'qualys_agent::config'
  contain 'qualys_agent::service'
}
