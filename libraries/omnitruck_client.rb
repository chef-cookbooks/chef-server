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

require 'chef/json_compat'
require 'chef/rest/rest_request'
require 'uri'

class OmnitruckClient

  attr_reader :node, :platform, :platform_version, :machine_architecture
  attr_reader :omnitruck_endpoint, :omnitruck_bucket

  def initialize(node)
    @node = node
    platform_data_for_node(node)
    @omnitruck_endpoint = node['chef-server']['omnitruck_endpoint']
    @omnitruck_bucket = node['chef-server']['omnitruck_bucket']
  end

  def package_for_version(version)
    server_list = get_request("#{omnitruck_endpoint}/full_server_list")
    available_versions_for_platform = server_list[platform][platform_version][machine_architecture]
    package = latest_package_for_version(version, available_versions_for_platform)
    unless package.nil?
      "https://#{omnitruck_bucket}.s3.amazonaws.com" << package
    else
      raise "Could not locate chef-server #{version} package on [#{platform}-#{platform_version}_#{machine_architecture}]."
    end
  rescue => e
    raise e
  end

  private

  def get_request(url)
    url = URI.parse(url)
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    response = http.get(url.request_uri, {})
    Chef::JSONCompat.from_json(response.body.chomp)
  end

  def platform_data_for_node(node)
    @platform = node[:platform_family] == "rhel" ? "el" : node[:platform]
    @platform_version = node[:platform_version]
    @machine_architecture = node[:kernel][:machine]
  end

  def latest_package_for_version(candidate_version, available_versions)
    require 'versionomy'

    if candidate_version && ( candidate_version.include?("-") ||
                              candidate_version.match(/[[:alpha:]]/) )
      available_versions[candidate_version]
    else
      parsed_available_versions =[]
      parsed_available_versions = available_versions.keys.map do |v|
        parsed_version = Versionomy.parse(v) rescue  nil
        # exclude versions such as x.y.z.beta.0 and x.y.z.rc.1
        next if parsed_version.nil? || parsed_version.prerelease?
        parsed_version
      end.compact

      parsed_candidate_version = if candidate_version.nil? || candidate_version.empty?
        candidate_versions.max
      else
        Versionomy.parse(candidate_version)
      end

      # Find all of the iterations of the version matching the major, minor, tiny
      matching_versions = parsed_available_versions.find_all do |v|
        parsed_candidate_version.major == v.major &&
        parsed_candidate_version.minor == v.minor &&
        parsed_candidate_version.tiny == v.tiny
      end

      if max_interation = matching_versions.max
        available_versions[max_interation.to_s]
      end
    end
  end
end
