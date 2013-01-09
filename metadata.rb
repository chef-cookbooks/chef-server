name              "chef-server"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures Chef Server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "2.0.0"

%w{ ubuntu redhat centos fedora amazon scientific oracle }.each do |os|
  supports os
end
