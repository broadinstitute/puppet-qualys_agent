require 'spec_helper'

describe 'qualys_agent' do
  on_supported_os.each do |os, os_facts|
    next if os_facts[:os]['family'] == 'windows'

    context "on #{os}" do
      let(:facts) { os_facts }

      context 'without activation_id' do
        it do
          is_expected.not_to compile
        end
      end

      context 'without customer_id' do
        it do
          is_expected.not_to compile
        end
      end

      context 'with correct activation_id and customer_id' do
        let(:environment) { 'unittest' }

        dirnames = ['/usr/local/qualys', '/etc/qualys', '/var/spool/qualys']

        context 'with default values for all parameters' do
          it do
            is_expected.to contain_class('qualys_agent')
          end
        end

        context 'with ensure set to "value"' do
          let(:params) do
            { ensure: 'value' }
          end

          it do
            is_expected.not_to compile
          end
        end

        context 'with log_dest_type set to "internet"' do
          let(:params) do
            { log_dest_type: 'internet' }
          end

          it do
            is_expected.not_to compile
          end
        end

        context 'with service_ensure set to "awesome"' do
          let(:params) do
            { service_ensure: 'awesome' }
          end

          it do
            is_expected.not_to compile
          end
        end

        context 'agent_user_homedir set to /' do
          let(:params) do
            { agent_user_homedir: '/' }
          end

          it do
            is_expected.to compile.and_raise_error(%r{agent_user_homedir})
          end
        end

        context 'hostid_path set to /' do
          let(:params) do
            { hostid_path: '/' }
          end

          it do
            is_expected.to compile.and_raise_error(%r{hostid_path})
          end
        end

        context 'hostid_search_dir set to /' do
          let(:params) do
            { hostid_search_dir: '/' }
          end

          it do
            is_expected.to compile.and_raise_error(%r{hostid_search_dir})
          end
        end

        context 'log_file_dir set to /' do
          let(:params) do
            { log_file_dir: '/' }
          end

          it do
            is_expected.to compile.and_raise_error(%r{log_file_dir})
          end
        end

        context 'correct resources are created with all defaults' do
          config_result = %r{ActivationId=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
CmdMaxTimeOut=1800
CmdStdOutSize=1024
CustomerId=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
LogFileDir=/var/log/qualys
LogLevel=3
ProcessPriority=0
RequestTimeOut=600
SudoCommand=sudo
SudoUser=root
UseAuditDispatcher=1
UserGroup=
UseSudo=0}
          it do
            is_expected.to compile.with_all_deps
          end

          # Classes
          it do
            is_expected.to contain_class('qualys_agent::user')
          end
          it do
            is_expected.to contain_class('qualys_agent::package')
          end
          it do
            is_expected.to contain_class('qualys_agent::config')
          end
          it do
            is_expected.to contain_class('qualys_agent::service')
          end
          it do
            is_expected.to contain_class('qualys_agent::config::qagent_log')
          end
          it do
            is_expected.to contain_class('qualys_agent::config::qagent_udc_log')
          end
          # User
          it do
            is_expected.not_to contain_group('qualys_group')
          end
          it do
            is_expected.not_to contain_user('qualys_user')
          end
          # Package
          it do
            is_expected.to contain_package('qualys_agent')
              .with(ensure: 'installed', name: 'qualys-cloud-agent')
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(
              ensure: 'directory',
              group: 'root',
              owner: 'root',
              recurse: false,
              require: 'Package[qualys_agent]',
            )
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(
              ensure: 'file',
              group: 'root',
              mode: '0600',
              owner: 'root',
              require: 'File[/var/log/qualys]',
            )
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(
              ensure: 'file',
              group: 'root',
              mode: '0600',
              owner: 'root',
              require: 'File[/var/log/qualys]',
            )
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(
                ensure: 'directory',
                group: 'root',
                owner: 'root',
                recurse: true,
                require: ['Package[qualys_agent]'],
              )
            end
          end

          # Config
          it do
            is_expected.to contain_file('qualys_config').with(
              ensure: 'file',
              group: 'root',
              mode: '0600',
              path: '/etc/qualys/cloud-agent/qualys-cloud-agent.conf',
              owner: 'root',
              show_diff: true,
              require: ['Package[qualys_agent]'],
              content: config_result,
            )
          end
          it do
            is_expected.to contain_file('qualys_properties').with(
              ensure: 'file',
              group: 'root',
              mode: '0600',
              path: '/etc/qualys/cloud-agent/qualys-cloud-agent.properties',
              owner: 'root',
              show_diff: true,
              require: ['Package[qualys_agent]'],
              content: config_result,
            )
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(
              ensure: 'file',
              group: 'root',
              mode: '0660',
              path: '/etc/qualys/hostid',
              owner: 'root',
              require: ['Package[qualys_agent]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_log_config')
              .with(
                ensure: 'file',
                group: 'root',
                mode: '0600',
                path: '/etc/qualys/cloud-agent/qagent-log.conf',
                owner: 'root',
                require: ['Package[qualys_agent]'],
              )
              .with_content(%r{logging.channels.c3.path: /var/log/qualys/qualys-cloud-agent.log})
              .with_content(%r{logging.loggers.l1.channel: c3})
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config')
              .with(
                ensure: 'file',
                group: 'root',
                mode: '0600',
                path: '/etc/qualys/cloud-agent/qagent-udc-log.conf',
                owner: 'root',
                require: ['Package[qualys_agent]'],
              )
              .with_content(%r{logging.channels.c3.path: /var/log/qualys/qualys-udc-scan.log})
              .with_content(%r{logging.loggers.l1.channel: c3})
          end

          # Service
          it do
            is_expected.to contain_service('qualys_agent')
              .with(
                ensure: 'running',
                enable: true,
                name: 'qualys-cloud-agent',
                subscribe: [
                  'File[qualys_config]',
                  'File[qualys_env]',
                  'File[qualys_log_config]',
                  'File[qualys_udc_log_config]',
                  'Package[qualys_agent]',
                ],
              )
          end
        end

        context 'agent_group set to "newgrp"' do
          let(:params) do
            { agent_group: 'newgrp' }
          end

          it do
            # User
            is_expected.to contain_group('qualys_group').with(
              ensure: 'present',
              name: 'newgrp',
              system: true,
            )
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(
              group: 'newgrp',
              require: 'Package[qualys_agent]',
            )
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(group: 'newgrp')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(group: 'newgrp')
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(
                group: 'newgrp',
                require: ['Package[qualys_agent]', 'Group[qualys_group]'],
              )
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(
              group: 'newgrp',
              content: %r{UserGroup=newgrp},
              require: ['Package[qualys_agent]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_properties').with(
              group: 'newgrp',
              content: %r{UserGroup=newgrp},
              require: ['Package[qualys_agent]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(
              group: 'newgrp',
              require: ['Package[qualys_agent]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(
              group: 'newgrp',
              require: ['Package[qualys_agent]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(
              group: 'newgrp',
              require: ['Package[qualys_agent]', 'Group[qualys_group]'],
            )
          end
        end

        context 'agent_user set to "newuser"' do
          let(:params) do
            { agent_user: 'newuser' }
          end

          it do
            # User
            is_expected.to contain_user('qualys_user').with(
              ensure: 'present',
              comment: 'Qualys Cloud Agent User',
              gid: nil,
              home: '/usr/local/qualys',
              name: 'newuser',
              password: '*',
              system: true,
              require: nil,
            )
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(
              owner: 'newuser',
              require: 'Package[qualys_agent]',
            )
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(owner: 'newuser')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(owner: 'newuser')
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(
                owner: 'newuser',
                require: ['Package[qualys_agent]', 'User[newuser]'],
              )
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(
              owner: 'newuser',
              content: %r{User=newuser},
              require: ['Package[qualys_agent]', 'User[newuser]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_properties').with(
              owner: 'newuser',
              content: %r{User=newuser},
              require: ['Package[qualys_agent]', 'User[newuser]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(
              owner: 'newuser',
              require: ['Package[qualys_agent]', 'User[newuser]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(
              owner: 'newuser',
              require: ['Package[qualys_agent]', 'User[newuser]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(
              owner: 'newuser',
              require: ['Package[qualys_agent]', 'User[newuser]'],
            )
          end
        end

        context 'agent_group set to "newgrp" and agent_user set to "newuser"' do
          let(:params) do
            {
              agent_group: 'newgrp',
              agent_user: 'newuser',
            }
          end

          it do
            # User
            is_expected.to contain_group('qualys_group').with(
              ensure: 'present',
              name: 'newgrp',
              system: true,
            )
          end
          it do
            is_expected.to contain_user('qualys_user').with(
              ensure: 'present',
              comment: 'Qualys Cloud Agent User',
              gid: 'newgrp',
              home: '/usr/local/qualys',
              name: 'newuser',
              password: '*',
              system: true,
              require: 'Group[qualys_group]',
            )
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(
              group: 'newgrp',
              owner: 'newuser',
              require: 'Package[qualys_agent]',
            )
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(
              group: 'newgrp',
              owner: 'newuser',
            )
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(
              group: 'newgrp',
              owner: 'newuser',
            )
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(
                group: 'newgrp',
                owner: 'newuser',
                require: ['Package[qualys_agent]', 'User[newuser]', 'Group[qualys_group]'],
              )
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(
              group: 'newgrp',
              owner: 'newuser',
              content: %r{User=newuser},
              require: ['Package[qualys_agent]', 'User[newuser]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_properties').with(
              group: 'newgrp',
              owner: 'newuser',
              content: %r{User=newuser},
              require: ['Package[qualys_agent]', 'User[newuser]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(
              group: 'newgrp',
              owner: 'newuser',
              require: ['Package[qualys_agent]', 'User[newuser]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(
              group: 'newgrp',
              owner: 'newuser',
              require: ['Package[qualys_agent]', 'User[newuser]', 'Group[qualys_group]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(
              group: 'newgrp',
              owner: 'newuser',
              require: ['Package[qualys_agent]', 'User[newuser]', 'Group[qualys_group]'],
            )
          end
        end

        context 'agent_user_homedir set "/tmp/agent"' do
          let(:params) do
            {
              agent_user: 'newuser',
              agent_user_homedir: '/tmp/agent',
            }
          end

          it do
            is_expected.to contain_user('qualys_user').with(home: '/tmp/agent', name: 'newuser')
          end
        end

        context 'custom configuration file values' do
          let(:params) do
            {
              cmd_max_timeout: 3600,
              cmd_stdout_size: 512,
              hostid_search_dir: '/tmp/hostidpath',
              log_file_dir: '/tmp/logs',
              log_level: 5,
              process_priority: 5,
              request_timeout: 300,
              sudo_command: 'othersudo',
              sudo_user: 'someuser',
              use_audit_dispatcher: 0,
              use_sudo: 1,
              webservice_uri: 'https://localhost/CloudAgent/',
            }
          end

          custom_config = %r{ActivationId=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
CmdMaxTimeOut=3600
CmdStdOutSize=512
CustomerId=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
HostIdSearchDir=/tmp/hostidpath
LogFileDir=/tmp/logs
LogLevel=5
ProcessPriority=5
RequestTimeOut=300
ServerUri=https://localhost/CloudAgent/
SudoCommand=othersudo
SudoUser=someuser
UseAuditDispatcher=0
UserGroup=
UseSudo=1}

          it do
            is_expected.to contain_file('/tmp/logs').with(
              group: 'root',
              owner: 'root',
              require: ['Package[qualys_agent]'],
            )
          end

          it do
            is_expected.to contain_file('qualys_config').with(content: custom_config)
          end

          it do
            is_expected.to contain_file('qualys_properties').with(content: custom_config)
          end
        end

        context 'conf_dir set to "/tmp/conf/dir"' do
          let(:params) do
            { conf_dir: '/tmp/conf/dir' }
          end

          it do
            is_expected.to contain_file('qualys_config').with(path: '/tmp/conf/dir/qualys-cloud-agent.conf')
          end
          it do
            is_expected.to contain_file('qualys_properties').with(path: '/tmp/conf/dir/qualys-cloud-agent.properties')
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(path: '/tmp/conf/dir/qagent-log.conf')
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(path: '/tmp/conf/dir/qagent-udc-log.conf')
          end
        end

        context 'hostid_path set to "/tmp/dir/hostid"' do
          let(:params) do
            { hostid_path: '/tmp/dir/hostid' }
          end

          it do
            is_expected.to contain_file('qualys_hostid').with(path: '/tmp/dir/hostid')
          end
        end

        context 'log_dest_type set to "syslog"' do
          let(:params) do
            { log_dest_type: 'syslog' }
          end

          it do
            is_expected.to contain_file('qualys_log_config').with(content: %r{logging.loggers.l1.channel: c2})
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(content: %r{logging.loggers.l1.channel: c2})
          end
        end

        context 'package_name set to "qualys-new-agent"' do
          let(:params) do
            { package_name: 'qualys-new-agent' }
          end

          it do
            is_expected.to contain_package('qualys_agent').with(ensure: 'installed', name: 'qualys-new-agent')
          end
        end

        context 'service_name set to "qualys-new-agent"' do
          let(:params) do
            { service_name: 'qualys-new-agent' }
          end

          it do
            is_expected.to contain_service('qualys_agent').with(name: 'qualys-new-agent')
          end
        end

        context 'service disabled and service stopped' do
          let(:params) do
            {
              service_enable: false,
              service_ensure: 'stopped',
            }
          end

          it do
            is_expected.to contain_service('qualys_agent').with(ensure: 'stopped', enable: false)
          end
        end

        context 'agent_group set to "newgrp" with manage_group set to false' do
          let(:params) do
            { agent_group: 'newgrp', manage_group: false }
          end

          it do
            is_expected.not_to contain_group('qualys_group')
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(
              group: 'newgrp',
              require: 'Package[qualys_agent]',
            )
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(group: 'newgrp')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(group: 'newgrp')
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(group: 'newgrp', require: ['Package[qualys_agent]'])
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(
              group: 'newgrp',
              content: %r{UserGroup=newgrp},
              require: ['Package[qualys_agent]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_properties').with(
              group: 'newgrp',
              content: %r{UserGroup=newgrp},
              require: ['Package[qualys_agent]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(group: 'newgrp', require: ['Package[qualys_agent]'])
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(group: 'newgrp', require: ['Package[qualys_agent]'])
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(
              group: 'newgrp',
              require: ['Package[qualys_agent]'],
            )
          end
        end

        context 'manage_package set to false' do
          let(:params) do
            { manage_package: false }
          end

          it do
            is_expected.not_to contain_package('qualys_agent')
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(require: nil)
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log')
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(require: [])
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(require: [])
          end
          it do
            is_expected.to contain_file('qualys_properties').with(require: [])
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(require: [])
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(require: [])
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(require: [])
          end
          it do
            is_expected.to contain_service('qualys_agent').with(
              subscribe: [
                'File[qualys_config]',
                'File[qualys_env]',
                'File[qualys_log_config]',
                'File[qualys_udc_log_config]',
              ],
            )
          end
        end

        context 'manage_service set to false' do
          let(:params) do
            { manage_service: false }
          end

          it do
            is_expected.not_to contain_service('qualys_agent')
          end
        end

        context 'agent_user set to "newuser" with manage_user set to false' do
          let(:params) do
            { agent_user: 'newuser', manage_user: false }
          end

          it do
            is_expected.not_to contain_user('qualys_user')
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(owner: 'newuser', require: 'Package[qualys_agent]')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(owner: 'newuser')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(owner: 'newuser')
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(owner: 'newuser', require: ['Package[qualys_agent]'])
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(
              owner: 'newuser',
              content: %r{User=newuser},
              require: ['Package[qualys_agent]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_properties').with(
              owner: 'newuser',
              content: %r{User=newuser},
              require: ['Package[qualys_agent]'],
            )
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(owner: 'newuser', require: ['Package[qualys_agent]'])
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(owner: 'newuser', require: ['Package[qualys_agent]'])
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(
              owner: 'newuser',
              require: ['Package[qualys_agent]'],
            )
          end
        end

        context 'log_group set to "newgroup"' do
          let(:params) do
            { log_group: 'newgroup' }
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(group: 'newgroup')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(group: 'newgroup')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(group: 'newgroup')
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(group: 'root')
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(group: 'root')
          end
          it do
            is_expected.to contain_file('qualys_properties').with(group: 'root')
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(group: 'root')
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(group: 'root')
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(group: 'root')
          end
        end

        context 'log_owner set to "newuser"' do
          let(:params) do
            { log_owner: 'newuser' }
          end

          it do
            is_expected.to contain_file('/var/log/qualys').with(owner: 'newuser')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(owner: 'newuser')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(owner: 'newuser')
          end

          dirnames.each do |directory|
            it do
              is_expected.to contain_file(directory).with(owner: 'root')
            end
          end
          it do
            is_expected.to contain_file('qualys_config').with(owner: 'root')
          end
          it do
            is_expected.to contain_file('qualys_properties').with(owner: 'root')
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(owner: 'root')
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(owner: 'root')
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(owner: 'root')
          end
        end

        context 'log file mode set to 0644' do
          let(:params) do
            { log_mode: '0644' }
          end

          it do
            is_expected.to contain_file('/var/log/qualys/qualys-cloud-agent.log').with(mode: '0644')
          end
          it do
            is_expected.to contain_file('/var/log/qualys/qualys-udc-scan.log').with(mode: '0644')
          end
        end

        context 'package_ensure set to "1.0.0"' do
          let(:params) do
            { package_ensure: '1.0.0' }
          end

          it do
            is_expected.to contain_package('qualys_agent').with(ensure: '1.0.0', name: 'qualys-cloud-agent')
          end
        end

        context 'qualys_agent::ensure set to absent forces all resources to absent' do
          let(:params) do
            {
              ensure: 'absent',
              agent_group: 'newgrp',
              agent_user: 'newuser',
              package_ensure: '1.0.0',
              service_ensure: 'running',
              service_enable: true,
            }
          end

          it do
            is_expected.to compile.with_all_deps
          end

          it do
            is_expected.to contain_class('qualys_agent::user')
          end
          it do
            is_expected.to contain_class('qualys_agent::package')
          end
          it do
            is_expected.to contain_class('qualys_agent::config')
          end
          it do
            is_expected.to contain_class('qualys_agent::service')
          end
          it do
            is_expected.to contain_class('qualys_agent::config::qagent_log')
          end
          it do
            is_expected.to contain_class('qualys_agent::config::qagent_udc_log')
          end
          it do
            is_expected.to contain_group('qualys_group').with(ensure: 'absent')
          end
          it do
            is_expected.to contain_user('qualys_user').with(ensure: 'absent')
          end
          it do
            is_expected.to contain_package('qualys_agent').with(ensure: 'absent')
          end

          # Will not manage these files/directories when "absent"
          it do
            is_expected.not_to contain_file('/var/log/qualys')
          end
          it do
            is_expected.not_to contain_file('/var/log/qualys/qualys-cloud-agent.log')
          end
          it do
            is_expected.not_to contain_file('/var/log/qualys/qualys-udc-scan.log')
          end

          dirnames.each do |directory|
            it do
              is_expected.not_to contain_file(directory)
            end
          end

          it do
            is_expected.to contain_file('qualys_config').with(ensure: 'absent')
          end
          it do
            is_expected.to contain_file('qualys_properties').with(ensure: 'absent')
          end
          it do
            is_expected.to contain_file('qualys_hostid').with(ensure: 'absent')
          end
          it do
            is_expected.to contain_file('qualys_log_config').with(ensure: 'absent')
          end
          it do
            is_expected.to contain_file('qualys_udc_log_config').with(ensure: 'absent')
          end
          it do
            is_expected.to contain_service('qualys_agent').with(ensure: 'stopped', enable: false)
          end
        end
        context 'when the agent is already configured' do
          let(:facts) { os_facts.merge(qualys: { hostid: '00000000-0000-0000-0000-000000000000' }) }

          it do
            is_expected.not_to contain_file('qualys_properties')
          end
        end
        context 'when setting extra environment variables' do
          let(:params) do
            { extra_env: { 'LD_PRELOAD' => '/usr/libexec/kcare/kpatch_package.so.qualys' } }
          end

          it do
            is_expected.to contain_file('qualys_env').with_content(%r{^LD_PRELOAD=/usr/libexec/kcare/kpatch_package\.so\.qualys$})
          end
        end
      end
    end
  end

  on_supported_os.each do |os, os_facts|
    next unless os_facts[:os]['family'] == 'windows'

    context "on #{os}" do
      let(:facts) { os_facts }

      context 'without activation_id' do
        it do
          is_expected.to compile.and_raise_error(%r{activation_id})
        end
      end

      context 'with correct activation_id and customer_id' do
        let(:environment) { 'unittest' }
        let(:base_params) do
          {
            package_source: 'puppet:///modules/profile/QualysCloudAgent.exe',
            webservice_uri: 'https://qagpublic.qg1.apps.qualys.eu/CloudAgent/',
          }
        end
        let(:params) { base_params }
        let(:install_options) do
          [
            'CustomerId={XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}',
            'ActivationId={XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}',
            'WebServiceUri=https://qagpublic.qg1.apps.qualys.eu/CloudAgent/',
          ]
        end

        context 'with default values for all parameters' do
          it do
            is_expected.to compile.with_all_deps
          end
          it do
            is_expected.to contain_class('qualys_agent::windows')
          end
          it do
            is_expected.not_to contain_class('qualys_agent::user')
          end
          it do
            is_expected.not_to contain_class('qualys_agent::package')
          end
          it do
            is_expected.not_to contain_class('qualys_agent::config')
          end
          it do
            is_expected.not_to contain_class('qualys_agent::service')
          end
          it do
            is_expected.to contain_file('qualys_installer').with(
              ensure: 'file',
              path: 'C:\\Windows\\Temp\\QualysCloudAgent.exe',
              source: 'puppet:///modules/profile/QualysCloudAgent.exe',
            )
          end
          it do
            is_expected.to contain_package('qualys_agent').with(
              ensure: 'installed',
              name: 'Qualys Cloud Security Agent',
              provider: 'windows',
              source: 'C:\\Windows\\Temp\\QualysCloudAgent.exe',
              install_options: install_options,
            ).that_requires('File[qualys_installer]')
          end
          it do
            is_expected.to contain_service('qualys_agent').with(
              ensure: 'running',
              enable: true,
              name: 'QualysAgent',
            ).that_subscribes_to('Package[qualys_agent]')
          end
        end

        context 'with a package_source using a query string' do
          let(:params) { base_params.merge(package_source: 'https://bucket.example.com/qualys/QualysCloudAgent_6.1.exe?X-Amz-Signature=abc') }

          it do
            is_expected.to contain_file('qualys_installer').with(
              path: 'C:\\Windows\\Temp\\QualysCloudAgent.exe',
              source: 'https://bucket.example.com/qualys/QualysCloudAgent_6.1.exe?X-Amz-Signature=abc',
            )
          end
        end

        context 'with package_download_dir set' do
          let(:params) { base_params.merge(package_download_dir: 'D:\\sources') }

          it do
            is_expected.to contain_package('qualys_agent').with_source('D:\\sources\\QualysCloudAgent.exe')
          end
        end

        context 'with Sensitive activation_id and customer_id' do
          let(:params) do
            base_params.merge(
              activation_id: sensitive('XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'),
              customer_id: sensitive('XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'),
            )
          end

          it do
            is_expected.to contain_package('qualys_agent').with_install_options(install_options)
          end
        end

        context 'with golden_image set to true' do
          let(:params) { base_params.merge(golden_image: true) }

          it do
            is_expected.to contain_package('qualys_agent').with_install_options(install_options + ['GoldenImage=true'])
          end
        end

        context 'with golden_image set to false' do
          let(:params) { base_params.merge(golden_image: false) }

          it do
            is_expected.to contain_package('qualys_agent').with_install_options(install_options + ['GoldenImage=false'])
          end
        end

        context 'with package_ensure set to a version' do
          let(:params) { base_params.merge(package_ensure: '6.1.0.28') }

          it do
            is_expected.to contain_package('qualys_agent').with_ensure('6.1.0.28')
          end
        end

        context 'with service_ensure set to stopped and service_enable set to false' do
          let(:params) { base_params.merge(service_ensure: 'stopped', service_enable: false) }

          it do
            is_expected.to contain_service('qualys_agent').with(ensure: 'stopped', enable: false)
          end
        end

        context 'with manage_service set to false' do
          let(:params) { base_params.merge(manage_service: false) }

          it do
            is_expected.to contain_package('qualys_agent')
          end
          it do
            is_expected.not_to contain_service('qualys_agent')
          end
        end

        context 'with manage_package set to false' do
          let(:params) { { manage_package: false } }

          it do
            is_expected.to compile.with_all_deps
          end
          it do
            is_expected.not_to contain_package('qualys_agent')
          end
          it do
            is_expected.not_to contain_file('qualys_installer')
          end
          it do
            is_expected.to contain_service('qualys_agent').with_ensure('running')
          end
        end

        context 'without package_source' do
          let(:params) { base_params.merge(package_source: :undef) }

          it do
            is_expected.to compile.and_raise_error(%r{package_source must be set on Windows})
          end
        end

        context 'without webservice_uri' do
          let(:params) { base_params.merge(webservice_uri: :undef) }

          it do
            is_expected.to compile.and_raise_error(%r{webservice_uri must be set on Windows})
          end
        end

        context 'with ensure set to absent' do
          let(:params) { { ensure: 'absent' } }

          it do
            is_expected.to compile.with_all_deps
          end
          it do
            is_expected.to contain_package('qualys_agent').with(
              ensure: 'absent',
              name: 'Qualys Cloud Security Agent',
              provider: 'windows',
            )
          end
          it do
            is_expected.not_to contain_file('qualys_installer')
          end
          it do
            is_expected.not_to contain_service('qualys_agent')
          end
        end
      end
    end
  end
end
