require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class ChefServerOrg < Chef::Resource::LWRPBase
      self.resource_name = :chef_server_org
      actions :create, :delete, :add_admin
      default_action :create

      attribute :org_name, kind_of: String, name_attribute: true, required: true
      attribute :org_long_name, kind_of: String, default: nil
      attribute :org_private_key_path, kind_of: String, default: nil
      attribute :admins, kind_of: [String, Array], default: nil
    end
  end
end