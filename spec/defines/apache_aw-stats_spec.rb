require 'spec_helper'

describe 'apache_c2c::aw-stats' do
  let(:title) { 'foo' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:pre_condition) { 'include ::apache_c2c' }
      let(:facts) { {
        :concat_basedir    => '/foo',
        :lsbmajdistrelease => '6',
        :operatingsystem   => os,
        :osfamily          => os,
      } }

      it { should contain_class('apache_c2c::params') }

      it { should contain_file('/etc/awstats/awstats.foo.conf').with_ensure('present') }

      it do should contain_file("#{VARS[os]['root']}/foo/conf/awstats.conf").with(
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'source'  => VARS[os]['awstats_tmpl']
      ) end
    end
  end
end
