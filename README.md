# qualys_agent

[![CircleCI](https://circleci.com/gh/broadinstitute/puppet-qualys_agent/tree/main.svg?style=svg)](https://circleci.com/gh/broadinstitute/puppet-qualys_agent)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/broadinstitute/qualys_agent.svg)](https://forge.puppet.com/broadinstitute/qualys_agent)
[![Puppet Forge](https://img.shields.io/puppetforge/v/broadinstitute/qualys_agent.svg)](https://forge.puppet.com/broadinstitute/qualys_agent)
[![Puppet Forge](https://img.shields.io/puppetforge/f/broadinstitute/qualys_agent.svg)](https://forge.puppet.com/broadinstitute/qualys_agent)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

## Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Setup requirements](#setup-requirements)
    * [Installation](#installation)
4. [Usage](#usage)
    * [Puppet Manifest](#puppet-manifest)
    * [With Hiera](#with-hiera)
    * [Running as a user other than root](#running-as-a-user-other-than-root)
5. [Reference](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Release Notes](#release-notes)
8. [Contributors](#contributors)

## Overview

Install and configure the Qualys Cloud Agent on a system.

## Module Description

This module will install the Qualys Cloud Agent from a repository and keep the required configuration files updated.

## Setup

### Setup Requirements

Due to the nature of Qualys' distribution methods, making the actual package available in a repository is outside the scope of this module.  In most cases, you can create your own custom Yum, Apt, etc. repository and serve out the `qualys-cloud-agent` package you can download from the Qualys interface.

### Installation

No trailing slashes should be provided for any paths.

#### Puppet Forge

``` sh
puppet module install broadinstitute-qualys_agent
```

#### Puppetfile

```ruby
mod 'broadinstitute/qualys_agent'
```

## Usage

### Puppet Manifest

```puppet
class { 'qualys_agent':
  activation_id => 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
  customer_id   => 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
}
```

### With Hiera

```yaml
---
classes:
  - qualys_agent
qualys_agent::activation_id: 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
qualys_agent::customer_id: 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
```

### Running as a user other than root

The configuration is a little tricky if you want to run as a non-root user.  To do so, you need to set several options in the configuration together.  An example is configured below:

```yaml
qualys_agent::activation_id: 00000000-0000-0000-0000-000000000000
qualys_agent::agent_user: 'qualys_auth'
qualys_agent::customer_id: 00000000-0000-0000-0000-000000000000
qualys_agent::sudo_user: 'qualys_auth'
qualys_agent::use_sudo: 1
```

This turns on the use of sudo, but it also sets the `User` and `SudoUser` variables in the configuration file, which are both necessary to make the service run as a non-root user.

## Reference

### Class: `qualys_agent`

#### `ensure`

Ensure that the Qualys agent is present on the system, or absent. **Default: true**

#### `activation_id`

The Activation ID you receive from Qualys for reporting back to their API **(required)** **Default: undef**

#### `agent_group`

The group that should run the agent.  This also will be the UserGroup setting in the configuration file. **Default: undef**

#### `agent_user`

The user that should run the agent. **Default: undef**

#### `cmd_max_timeout`

The CmdMaxTimeOut value in `qualys-cloud-agent.conf`. **Default: 1800**

#### `cmd_stdout_size`

The CmdStdOutSize value in `qualys-cloud-agent.conf`. **Default: 1024**

#### `conf_dir`

The directory where the `qualys-cloud-agent.conf` file will exist. **Default: /etc/qualys/cloud-agent**

#### `customer_id`

The Customer ID you receive from Qualys for reporting back to their API. **(required)** **Default: undef**

#### `env_dir`

The directory containing the environment variable file `qualys-cloud-agent`. **Default: /etc/sysconfig**

#### `hostid_path`

The full filesystem path to the hostid file. **Default: /etc/qualys/hostid**

#### `hostid_search_dir`

The HostIdSearchDir value in `qualys-cloud-agent.conf`. **Default: undef**

#### `https_proxy`

The https proxy to be used for all commands performed by the Cloud Agent. **Default: undef**

#### `log_dest_type`

The log type (file or syslog). **Default: file**

#### `log_file_dir`

The LogFileDir value in `qualys-cloud-agent.conf`.
The directory in which the log files should be written. **Default: /var/log/qualys**

#### `log_level`

The LogLevel value in `qualys-cloud-agent.conf`. **Default: 3**

#### `manage_group`

Boolean to determine whether the group is managed by Puppet or not. **Default: true**

#### `manage_package`

Boolean to determine whether the package is managed by Puppet or not. **Default: true**

#### `manage_service`

Boolean to determine whether the service is managed by Puppet or not. **Default: true**

#### `manage_user`

Boolean to determine whether the user is managed by Puppet or not. **Default: true**

#### `package_ensure`

The "ensure" value for the Qualys agent package. This value can be "installed", "absent", or a version number if you want to specify a specific package version numer. **Default: installed**

#### `package_name`

The name of the package to install. **Default: qualys-cloud-agent**

#### `process_priority`

The ProcessPriority value in `qualys-cloud-agent.conf`. **Default: 0**

#### `qualys_https_proxy`

The https proxy to be used by the Cloud Agent to communicate with qualys cloud platform. **Default: undef**

#### `request_timeout`

The RequestTimeOut value in `qualys-cloud-agent.conf`. **Default: 600**

#### `service_enable`

Boolean to determine whether the service is enabled or not. **Default: true**

#### `service_ensure`

Ensure that the Qualys agent is running on the system, or stopped. **Default: running**

#### `service_name`

The name of the Qualys agent service. **Default: qualys-cloud-agent**

#### `sudo_command`

The SudoCommand value in `qualys-cloud-agent.conf`. **Default: sudo**

#### `sudo_user`

The SudoUser value in `qualys-cloud-agent.conf`. **Default: undef**

#### `use_audit_dispatcher`

The UseAuditDispatcher value in `qualys-cloud-agent.conf`. **Default: 1**

#### `use_sudo`

The UseSudo value in `qualys-cloud-agent.conf`. **Default: 0**

## Limitations

This has currently only been tested extensively on RedHat-based systems.

## Contributors
