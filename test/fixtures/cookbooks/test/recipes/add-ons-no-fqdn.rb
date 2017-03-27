node.default['chef-server']['api_fqdn'] = ''
node.default['chef-server']['addons'] = ['manage']
node.default['chef-server']['accept_license'] = true

apt_update 'update'

include_recipe 'chef-server::default'
include_recipe 'chef-server::addons'
