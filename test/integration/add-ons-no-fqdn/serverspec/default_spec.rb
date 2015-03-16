require_relative './spec_helper'

describe 'chef-server' do
  describe package('opscode-manage') do
    it { should be_installed }
  end

  describe command('opscode-manage-ctl test') do
    its(:exit_status) { should eq 0 }
  end
end
