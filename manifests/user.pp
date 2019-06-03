# @summary Configure the user and group to run the Qualys agent service
#
# Manage the system user and group that run the Qualys agent
#
class qualys_agent::user {

  if $::qualys_agent::manage_group {
    # Only manage the group if it is set
    if $::qualys_agent::user_group {
      $qualys_group = $::qualys_agent::user_group

      group { 'qualys_group':
        ensure => $::qualys_agent::ensure,
        name   => $qualys_group,
        system => true,
      }

      $group_req = Group['qualys_group']
    } else {
      $qualys_group = undef
      $group_req = undef
    }
  } else {
    $qualys_group = undef
    $group_req = undef
  }

  if $::qualys_agent::manage_user {
    if $::qualys_agent::agent_user && ($::qualys_agent::agent_user != 'root') {
      user { 'qualys_user':
        ensure   => $::qualys_agent::ensure,
        comment  => 'Qualys Cloud Agent User',
        gid      => $qualys_group,
        home     => $::qualys_agent::agent_user_homedir,
        name     => $::qualys_agent::agent_user,
        password => '*',
        system   => true,
        before   => Package['qualys_agent'],
        require  => $group_req,
      }
    }
  }

}
