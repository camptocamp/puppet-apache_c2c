require 'spec_helper'

describe 'apache::awstats' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should contain_package('awstats').with_ensure('installed') }

      it do should contain_file('/etc/awstats').with(
        'ensure'  => 'directory',
        'source'  => 'puppet:///modules/apache/etc/awstats',
        'mode'    => '0755',
        'purge'   => 'true',
        'recurse' => 'true',
        'force'   => 'true'
      ) end

      if (os =~ /Debian|Ubuntu/)
        it do should contain_cron('update all awstats virtual hosts').with(
          'command' => '/usr/share/doc/awstats/examples/awstats_updateall.pl -awstatsprog=/usr/lib/cgi-bin/awstats.pl -confdir=/etc/awstats now > /dev/null',
          'user'    => 'root',
          'minute'  => [0,10,20,30,40,50]
        ) end

        it { should contain_file('/etc/cron.d/awstats').with_ensure('absent') }
      end

      if (os =~ /RedHat|CentOS/)
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
