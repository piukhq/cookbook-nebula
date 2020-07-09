directory '/usr/local/src/inspec'

remote_file '/usr/local/src/inspec/inspec.deb' do
  source node['inspec']['deb_url']
  checksum node['inspec']['deb_sha256']
end

dpkg_package 'inspec.deb' do
  source '/usr/local/src/inspec/inspec.deb'
end

# inspec exec --chef-license=accept /usr/local/src/inspec/profiles/base
# inspec exec --chef-license=accept /usr/local/src/inspec/profiles/base --reporter json:/tmp/output.json

remote_directory '/usr/local/src/inspec/profiles/base' do
  source 'base'
  files_owner 'root'
  files_group 'root'
  files_mode '0755'
  action :create
  recursive true
end
