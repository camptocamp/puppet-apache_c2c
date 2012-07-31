require 'spec_helper'

describe 'apache' do
  let(:pre_condition) { "
class concat::setup {}
define concat() {}
define concat::fragment($ensure='present', $target, $content) {}
  " }

  OSES.each do |os|
    describe "When on #{os}" do
      if ['Debian', 'Ubuntu'].include? os
        let(:facts) { {
          :operatingsystem   => os,
        } }

        it { should include_class('apache::debian') }
      elsif ['RedHat', 'CentOS'].include? os
        # NOTE: RHEL4 is not supported
        ['5', '6'].each do |release|
          describe "with release #{release}" do
            let(:facts) { {
              :operatingsystem   => os,
              :lsbmajdistrelease => release,
            } }

            it { should include_class('apache::redhat') }
          end
        end
      end
    end
  end

  describe 'When on unknown OS' do
    let(:facts) { {
      :operatingsystem => 'Fedora',
    } }

    it do
      expect {
        should include_class('apache::debian')
      }.to raise_error(Puppet::Error, /Unsupported operatingsystem Fedora/)
    end
  end
end
