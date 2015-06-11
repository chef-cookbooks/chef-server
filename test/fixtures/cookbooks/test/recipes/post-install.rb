# we need to ensure that the reconfigure is run so that the api_fqdn
# is updated for the correct chef_server_url we're using from the
# attribute defined in .kitchen.yml.
execute 'chef-server-ctl reconfigure'

chef_server_opts = {
                    chef_server_url: 'https://chef-server-tk.example.com',
                    options: {
                      client_name: 'pivotal',
                      signing_key_filename: '/etc/opscode/pivotal.pem'
                    }
                   }

# Begin: Cheffish from GitHub pull request
# https://github.com/chef/cheffish/pull/50
# Once that PR is merged we can just do chef_gem 'cheffish' with a
# version pin.
execute 'apt-get update' if platform_family?('debian')

package('git') do
  # TODO: Drop this when we no longer support Ubuntu 10.04 (it's EOL)
  package_name 'git-core' if platform?('ubuntu') && node['platform_version'].to_f == 10.04
end.run_action :install

git '/tmp/cheffish' do
  repository 'https://github.com/chef/cheffish'
  branch 'ssd/organization-force-associate'
end.run_action :checkout

execute "#{Chef::Config.embedded_dir}/bin/rake build" do
  cwd '/tmp/cheffish'
  creates '/tmp/cheffish/pkg/cheffish-1.2.gem'
end.run_action :run

chef_gem 'cheffish' do
  source '/tmp/cheffish/pkg/cheffish-1.2.gem'
  compile_time true
end
# End: Cheffish from GitHub pull request

require 'cheffish'

directory Chef::Config[:trusted_certs_dir] do
  recursive true
end

link File.join(Chef::Config[:trusted_certs_dir], 'chef-server-tk.example.com.crt') do
  to '/var/opt/opscode/nginx/ca/chef-server-tk.example.com.crt'
end

private_key '/tmp/exemplar.key'

chef_user 'exemplar' do
  email 'exemplar@example.com'
  password 'dontusethisforreal'
  source_key_path '/tmp/exemplar.key'
  chef_server chef_server_opts
end

chef_organization 'sample' do
  full_name 'Sample Size'
  members ['exemplar']
  chef_server chef_server_opts
end
