require 'spec_helper'

describe 'chef-server::addons' do
  cached(:subject) do
    ChefSpec::SoloRunner.new do |node|
      node.normal['chef-server']['addons'] = { manage: '2.5.0', reporting: nil }
    end.converge(described_recipe)
  end

  it 'installs addons' do
    expect(subject).to install_chef_ingredient('manage').with_version('2.5.0')
    expect(subject).to install_chef_ingredient('reporting')
  end
end
