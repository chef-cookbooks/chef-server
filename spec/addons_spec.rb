require 'spec_helper'

describe 'chef-server::addons' do
  cached(:subject) do
    ChefSpec::SoloRunner.new do |node|
      node.set['chef-server']['addons'] = %w(manage reporting)
    end.converge(described_recipe)
  end

  it 'installs addons' do
    expect(subject).to install_chef_ingredient('manage')
    expect(subject).to install_chef_ingredient('reporting')
  end
end
