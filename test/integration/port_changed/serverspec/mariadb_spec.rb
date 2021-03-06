require 'spec_helper'

describe service('mysql') do
  it { should be_enabled   }
  it { should be_running   }
end

describe port('3307') do
  it { should be_listening }
end

includedir = '/etc/mysql/conf.d'
mysql_config_file = '/etc/mysql/my.cnf'
case os[:family]
when 'fedora', 'centos', 'redhat'
  includedir = '/etc/my.cnf.d'
  mysql_config_file = '/etc/my.cnf'
end

describe "verify the tuning attributes set in #{mysql_config_file}" do
  {
    query_cache_size: '64M',
    thread_cache_size: 128,
    max_connections: 100,
    wait_timeout: 600,
    max_heap_table_size: '32M',
    read_buffer_size: '2M',
    read_rnd_buffer_size: '1M',
    long_query_time: 10,
    key_buffer_size: '128M',
    max_allowed_packet: '16M',
    sort_buffer_size: '4M',
    myisam_sort_buffer_size: '512M'
  }.each do |attribute, value|
    describe command("grep -E \"^#{attribute}\\s+\" #{mysql_config_file}") do
      its(:stdout) { should match(/#{value}/) }
    end
  end
end

describe 'verify the tuning attributes set in ' + includedir + '/innodb.cnf' do
  {
    innodb_buffer_pool_size: '256M',
    innodb_flush_method: 'O_DIRECT',
    innodb_file_per_table: 1,
    innodb_open_files: 400
  }.each do |attribute, value|
    describe command("grep -E \"^#{attribute}\\s+\" " \
                     "#{includedir}/innodb.cnf") do
      its(:stdout) { should match(/#{value}/) }
    end
  end
end

describe 'verify the tuning attributes set in ' \
         + includedir + '/replication.cnf' do
  {
    max_binlog_size: '100M',
    expire_logs_days: 10
  }.each do |attribute, value|
    describe command("grep -E \"^#{attribute}\\s+\" " \
                     "#{includedir}/replication.cnf") do
      its(:stdout) { should match(/#{value}/) }
    end
  end
end

describe command('/usr/bin/mysql -u root -pgsql' \
                 ' -D mysql -r -B -N -e "SELECT 1"') do
  its(:stdout) { should match(/1/) }
end
