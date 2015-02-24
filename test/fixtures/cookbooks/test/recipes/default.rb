# This test recipe is used within test kitchen to perform additional
# setup, or to configure custom resources in the main cookbook.

# For example, update the apt cache on Debian systems, which avoids
# requiring the `apt` cookbook. This doesn't work, of course, if the
# apt cache must be updated before the main cookbook's default recipe
# is run.
execute 'apt-get update' if platform_family?('debian')

# workaround for https://github.com/chef/bento/issues/325
remote_file '/etc/pki/tls/certs/ca-bundle.crt' do
  source 'http://opscode-omnibus-cache.s3.amazonaws.com/cacerts-2014.07.15-fd48275847fa10a8007008379ee902f1'
  checksum 'a9cce49cec92304d29d05794c9b576899d8a285659b3f987dd7ed784ab3e0621'
  sensitive true
end if platform_family?('rhel')
