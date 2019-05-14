# Class: qualys_agent
# ===========================
#
# Full description of class qualys_agent here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'qualys_agent':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
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
  String $agent_user,
  Integer $cmd_max_timeout,
  Integer $cmd_stdout_side,
  Stdlib::Absolutepath $conf_dir,
  String $customer_id,
  Enum['file', 'syslog'] $log_dest_type,
  Stdlib::Absolutepath $log_file_dir,
  Integer $log_level,
  Integer $process_priority,
  Integer $request_timeout,
  String $sudo_command,
  String $sudo_user,
  Integer $use_audit_dispatcher,
  Integer $use_sudo,
  Optional[String] $user_group,
) {
  contain 'qualys_agent::config'

  Class['qualys_agent::package'] -> Class['qualys_agent::config']
}
