# qualys_agent

![checks](https://github.com/broadinstitute/puppet-qualys_agent/workflows/checks/badge.svg?branch=main)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/broadinstitute/qualys_agent.svg)](https://forge.puppet.com/broadinstitute/qualys_agent)
[![Puppet Forge](https://img.shields.io/puppetforge/v/broadinstitute/qualys_agent.svg)](https://forge.puppet.com/broadinstitute/qualys_agent)
[![Puppet Forge](https://img.shields.io/puppetforge/f/broadinstitute/qualys_agent.svg)](https://forge.puppet.com/broadinstitute/qualys_agent)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![codecov](https://codecov.io/gh/broadinstitute/puppet-qualys_agent/branch/main/graph/badge.svg)](https://codecov.io/gh/broadinstitute/puppet-qualys_agent)

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
qualys_agent::activation_id: 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
qualys_agent::agent_user: 'qualys_auth'
qualys_agent::customer_id: 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
qualys_agent::sudo_user: 'qualys_auth'
qualys_agent::use_sudo: 1
```

This turns on the use of sudo, but it also sets the `User` and `SudoUser` variables in the configuration file, which are both necessary to make the service run as a non-root user.

## Reference

[REFERENCE.md](REFERENCE.md) (generated with Puppet Strings)

## Limitations

This has currently only been tested extensively on RedHat-based systems.

## Contributors
