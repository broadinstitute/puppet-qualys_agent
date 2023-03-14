#
# @summary Configure the user and group to run the Qualys agent service
#
# Manage the system user and group that run the Qualys agent
#
class qualys_agent::user {
  # Only manage the group if it is set
  if ($qualys_agent::manage_group) and (! empty($qualys_agent::agent_group)) and ($qualys_agent::agent_group != 'root') {
    $gid = $qualys_agent::agent_group

    group { 'qualys_group':
      ensure => $qualys_agent::ensure,
      name   => $gid,
      system => true,
    }

    # Do not create an ordering dependency if we are removing the agent
    $group_dep = $qualys_agent::ensure ? {
      'present' => Group['qualys_group'],
      'absent'  => undef,
    }
  } else {
    $gid = undef
    $group_dep = undef
  }

  if ($qualys_agent::manage_user) and (! empty($qualys_agent::agent_user)) and ($qualys_agent::agent_user != 'root') {
    user { 'qualys_user':
      ensure   => $qualys_agent::ensure,
      comment  => 'Qualys Cloud Agent User',
      gid      => $gid,
      home     => $qualys_agent::agent_user_homedir,
      name     => $qualys_agent::agent_user,
      password => '*',
      system   => true,
      require  => $group_dep,
    }

    # Do not create an ordering dependency if we are removing the agent
    $user_dep = $qualys_agent::ensure ? {
      'present' => User[$qualys_agent::agent_user],
      'absent'  => undef,
    }
  } else {
    $user_dep = undef
  }
}
