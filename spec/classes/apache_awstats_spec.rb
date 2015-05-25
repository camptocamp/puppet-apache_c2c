require 'spec_helper'

describe 'apache_c2c::awstats' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_package('awstats').with_ensure('installed') }

      it do should contain_file('/etc/awstats').with(
        'ensure'  => 'directory',
        'mode'    => '0755',
        'purge'   => 'true',
        'recurse' => 'true',
        'force'   => 'true'
      ) end

      case facts[:osfamily]
      when 'Debian'
        it do should contain_cron('update all awstats virtual hosts').with(
          'command' => '/usr/share/doc/awstats/examples/awstats_updateall.pl -awstatsprog=/usr/lib/cgi-bin/awstats.pl -confdir=/etc/awstats now > /dev/null',
          'user'    => 'root',
          'minute'  => [0,10,20,30,40,50]
        ) end

        it { should contain_file('/etc/cron.d/awstats').with_ensure('absent') }
      when 'RedHat'
        it do should contain_file('/usr/share/awstats/wwwroot/cgi-bin/').with(
          'seltype' => 'httpd_sys_script_exec_t',
          'mode'    => '0755',
          'recurse' => 'true'
        ) end

        it do should contain_file('/var/lib/awstats/').with(
          'seltype' => 'httpd_sys_script_ro_t',
          'recurse' => 'true'
        ) end

        it { should contain_file('/etc/httpd/conf.d/awstats.conf').with_ensure('absent') }
      end
    end
  end
end
