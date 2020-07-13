directory '/usr/local/src/inspec'

package 'python3-requests' do
  action :install
end

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

cookbook_file '/usr/local/src/inspec/inspec.py' do
  source 'inspec.py'
  owner 'root'
  group 'root'
  mode '0770'
  action :create
end

systemd_unit 'inspec.service' do
  content(
    Unit: {
      Description: 'Runs inspec and submits data to elasticsearch',
      After: 'network-online.target',
      Wants: 'network-online.target',
    },
    Service: {
      Type: 'oneshot',
      Environment: 'HOME=/root',
      ExecStart: '/usr/local/src/inspec/inspec.py',
    }
  )
  action [:create, :enable]
end

systemd_unit 'inspec.timer' do
  content(
    Unit: {
      Description: 'Runs inspec and submits data to elasticsearch',
    },
    Timer: {
      OnCalendar: '*-*-* 4:00:00',
    },
    Install: {
      WantedBy: 'timers.target',
    }
  )
  action [:create, :start, :enable]
end
