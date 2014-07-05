require 'spec_helper'

describe 'apache_c2c::base::ssl' do
  let(:pre_condition) { "include ::apache_c2c" }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir    => '/foo',
        :lsbmajdistrelease => '6',
        :operatingsystem   => os,
        :osfamily          => os,
      } }

      it { should contain_apache_c2c__listen('443').with_ensure('present') }
      it { should contain_apache_c2c__namevhost('*:443').with_ensure('present') }

      it do should contain_file('/usr/local/sbin/generate-ssl-cert.sh').with(
        'mode'   => '0755',
        'source' => 'puppet:///modules/apache_c2c/generate-ssl-cert.sh'
      ) end
    end
  end
end
