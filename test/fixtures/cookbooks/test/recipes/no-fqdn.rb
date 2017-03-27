node.default['chef-server']['api_fqdn'] = ''

apt_update 'update'

include_recipe 'chef-server::default'
