#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

class OmnitruckClient

  attr_reader :platform, :platform_version, :machine_architecture

  def initialize(node)
    @platform = node['platform_family'] == "rhel" ? "el" : node['platform']
    @platform_version = node['platform_family'] == "rhel" ? node['platform_version'].to_i : node['platform_version']
    @machine_architecture = node['kernel']['machine']
  end

  def package_for_version(version, prerelease=false, nightly=false)
    url = "http://www.opscode.com/chef/download-server"
    url << "?p=#{platform}"
    url << "&pv=#{platform_version}"
    url << "&m=#{machine_architecture}"
    url << "&v=#{version}" if version
    url << "&prerelease=#{prerelease}"
    url << "&nightlies=#{nightly}"
    Chef::Log.info("Omnitruck download-server request: #{url}")
    target = redirect_target(url)
    Chef::Log.info("Downloading chef-server package from: #{target}") if target
    target
  end

  private

  def redirect_target(url)
    url = URI.parse(url)
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    response = http.get(url.request_uri, {})
    case response
    when Net::HTTPRedirection
      response['location']
    else
      nil
    end
  end

end
