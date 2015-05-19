require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class ChefServerUser < Chef::Resource::LWRPBase
      self.resource_name = :chef_server_user
      actions :create, :delete
      default_action :create

      attribute :username, kind_of: String, name_attribute: true, required: true
      attribute :firstname, kind_of: String, default: nil
      attribute :lastname, kind_of: String, default: nil
      attribute :email, kind_of: String, default: nil
      attribute :password, kind_of: String, default: nil
      attribute :private_key_path, kind_of: String, default: nil
    end
  end
end