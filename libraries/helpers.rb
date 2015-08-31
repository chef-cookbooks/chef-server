
module ChefServerCookbook
  module Helpers
    def api_fqdn_available?
      return false if node['chef-server'].nil?
      return false if node['chef-server']['api_fqdn'].nil?
      !node['chef-server']['api_fqdn'].empty?
    end

    def api_fqdn_resolves?
      ChefIngredientCookbook::Helpers.fqdn_resolves?(
        node['chef-server']['api_fqdn']
      )
    end

    def repair_api_fqdn
      fe = Chef::Util::FileEdit.new('/etc/hosts')
      fe.insert_line_if_no_match(/#{node['chef-server']['api_fqdn']}/,
        "127.0.0.1 #{node['chef-server']['api_fqdn']}")
      fe.write_file
    end
  end
end
