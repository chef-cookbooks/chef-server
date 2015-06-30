require 'spec_helper'

describe 'chef-server::default' do
  cached(:centos_65) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '6.5',
      step_into: %w(chef_ingredient)
    ) do |node|
      node.set['chef-server']['version'] = nil
    end.converge('chef-server::default')
  end

  context 'compiling the test recipe' do
    it 'installs chef_server_ingredient[chef-server-core]' do
      expect(centos_65).to install_chef_ingredient('chef-server')
    end
  end
end
