node.default['chef-server']['api_fqdn'] = 'chef-server-tk.example.com'

apt_update 'update' if platform_family?('debian')

include_recipe 'chef-server::default'
include_recipe 'test::post-install'
