node['chef-server']['add_ons'].each do |addon|
  chef_server_ingredient addon do
    notifies :reconfigure, "chef_server_ingredient[#{addon}]"
  end
end
