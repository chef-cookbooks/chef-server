chef-server cookbook README
==========================

v2.1.6 (2014-05-22)
-------------------

* COOK-4660 - Adds a OS version and image updates to the testing harness


v2.1.4 (2014-03-29)
-------------------
- Dropping dependency on git


v2.1.2 (2014-03-18)
-------------------
- [COOK-4386] - 'package_options' attribute added


v2.1.0 (2014-02-24)
-------------------
- Updating test harness, adding amazon support to omnitruck library
- '[COOK-4176] - Ensure creation of `:file_cache_path`'
- '[COOK-4178] - update Bento boxes used in chef-server cookbook'


v2.0.1
------
Documentation update to reflect Vagrant version dependency


v2.0.0
------
- Complete re-write for Chef Server 11+. Chef Server is now installed
  using "fat" Omnibus package.

v1.1.0
------
- [COOK-1637] - Directory creation in chef-server should be recursive
- [COOK-1638] - chef-server: Minor foodcritic fixups needed
- [COOK-1643] - Chef Server Cookbook Missing Erlang in Metadata Depends
- [COOK-1767] - use platform_family in chef-server cookbook

v1.0.0
------
- [COOK-801] - add amazon linux
- [COOK-886] - use bin path consistently
- [COOK-1034] - expander bluepill doesn't have default value for node count

v0.99.12
--------
- [COOK-757] - compact all the views
- [COOK-969] - `server_name` and `server_aliases` as configurable attributes on `chef_server::nginx-proxy` and `chef_server::apache-proxy`
