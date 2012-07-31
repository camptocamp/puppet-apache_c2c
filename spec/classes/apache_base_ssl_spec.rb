require 'spec_helper'

describe 'apache::base::ssl' do
  let(:pre_condition) { "
class concat::setup {}
define concat() {}
define concat::fragment($ensure='present', $target, $content) {}
  " }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should contain_apache__listen('443').with_ensure('present') }
      it { should contain_apache__namevhost('*:443').with_ensure('present') }

      it do should contain_file('/usr/local/sbin/generate-ssl-cert.sh').with(
        'mode'   => '0755',
        'source' => 'puppet:///modules/apache/generate-ssl-cert.sh'
      ) end
    end
  end
end
