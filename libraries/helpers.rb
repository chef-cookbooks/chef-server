
module ChefServerCoobook
  module Helpers
    def api_fqdn_node_attr
      return false if node['chef-server'].nil?
      return false if node['chef-server']['api_fqdn'].nil?
      return false if node['chef-server']['api_fqdn'].empty?
      true
    end

    def api_fqdn_resolves
      require 'resolv'
      Resolv.getaddress(node['chef-server']['api_fqdn'])
      return true
    rescue
      false
    end

    def repair_api_fqdn
      fe = Chef::Util::FileEdit.new('/etc/hosts')
      fe.insert_line_if_no_match(/#{node['chef-server']['api_fqdn']}/,
        "127.0.0.1 #{node['chef-server']['api_fqdn']}")
      fe.write_file
    end
  end
end
