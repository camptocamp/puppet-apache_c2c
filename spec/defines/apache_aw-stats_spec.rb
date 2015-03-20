require 'spec_helper'

describe 'apache_c2c::aw-stats' do
  let(:title) { 'foo' }

  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_class('apache_c2c::params') }

      it { should contain_file('/etc/awstats/awstats.foo.conf').with_ensure('present') }

      case facts[:osfamily]
      when 'Debian'
        it { should contain_file('/var/www/foo/conf/awstats.conf').with(
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'source'  => 'puppet:///modules/apache_c2c/awstats.deb.conf',
        ) }
      else
        it { should contain_file('/var/www/vhosts/foo/conf/awstats.conf').with(
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'source'  => 'puppet:///modules/apache_c2c/awstats.rh.conf',
        ) }
      end
    end
  end
end
