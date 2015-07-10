require 'spec_helper'

describe 'chef-server::default' do
  cached(:subject) do
    ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache').converge(described_recipe)
  end

  it 'ensures node can resolve API FQDN' do
    expect(subject).to run_ruby_block('ensure node can resolve API FQDN')
  end

  it 'installs chef server core' do
    expect(subject).to install_chef_ingredient('chef-server')
      .with(version: :latest,
            package_source: nil,
            config: "topology \"standalone\"\napi_fqdn \"fauxhai.local\"\n\n")
  end

  it 'creates file for first run' do
    expect(subject).to create_file('/var/chef/cache/chef-server-core.firstrun')
  end
end
