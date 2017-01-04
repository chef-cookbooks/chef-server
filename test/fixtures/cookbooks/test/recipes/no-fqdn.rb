node.default['chef-server']['api_fqdn'] = ''

apt_update 'update' if platform_family?('debian')

include_recipe 'chef-server::default'
