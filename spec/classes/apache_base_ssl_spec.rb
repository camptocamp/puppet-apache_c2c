require 'spec_helper'

describe 'apache_c2c::base::ssl' do
  let(:pre_condition) { "include ::apache_c2c::ssl" }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_apache_c2c__listen('443').with_ensure('present') }
      it { should contain_apache_c2c__namevhost('*:443').with_ensure('present') }

      it do should contain_file('/usr/local/sbin/generate-ssl-cert.sh').with(
        'mode'   => '0755',
        'source' => 'puppet:///modules/apache_c2c/generate-ssl-cert.sh'
      ) end
    end
  end
end
