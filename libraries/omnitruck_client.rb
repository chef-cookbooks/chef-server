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
require 'uri'

class OmnitruckClient
  class Version
    attr_reader :version_string, :parsed_version

    def initialize(version_string)
      @version_string = version_string
      @parsed_version = Gem::Version.new(version_string.gsub(/-\w{8}$/,'').gsub(/[^\w.]+/,'.'))
    end

    def to_s
      @version_string
    end

    def <=>(other)
      @parsed_version <=> other.parsed_version
    end

  end

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
    parsed_versions_for_platform = Hash[available_versions_for_platform.map do |v, package|
                                        [OmnitruckClient::Version.new(v), package]
                                      end]
    package = latest_package_for_version(version, parsed_versions_for_platform)
    unless package.nil?
      "https://#{omnitruck_bucket}.s3.amazonaws.com" << package
    end
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
    # Latest translates into max version
    if candidate_version.to_s == "latest" || candidate_version.nil? || candidate_version.empty?
      max_version = available_versions.keys.sort.last
      available_versions[max_version]
    elsif candidate_version && ( candidate_version.include?("-") ||
                                 candidate_version.match(/[[:alpha:]]/) )
      available_versions[candidate_version]
    else
      filtered_available_versions =[]
      filtered_available_versions = available_versions.keys.find_all do |v|
        # exclude versions such as x.y.z.beta.0 and x.y.z.rc.1
        !v.nil? && !v.prerelease?
      end

      parsed_candidate_version = OmnitruckClient::Version.new(candidate_version)

      # Find all of the iterations of the version matching the major, minor, tiny
      matching_versions = filtered_available_versions.find_all do |v|
        parsed_candidate_version.segments[0] == v.segments[0] &&
        parsed_candidate_version.segments[1] == v.segments[1] &&
        parsed_candidate_version.segments[2] == v.segments[2]
      end

      if max_interation = matching_versions.sort.last
        available_versions[max_interation]
      end
    end
  end
end
