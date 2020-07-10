# ClamAV
apt_update

%w(clamav clamav-daemon).each do |a|
  package a do
    action :install
    notifies :run, 'execute[freshclam]', :immediately
  end
end

execute 'freshclam' do
  command 'freshclam'
  action :nothing
  ignore_failure true
end

cron_d 'daily-clamscan' do
  minute 0
  hour 3
  command 'freshclam && clamscan -r -i --exclude-dir="^/sys" --exclude-dir="^/proc" / -l /var/log/clamscan.log'
end

service 'sshd' do
  action %i(enable start)
end

# Benchmark 5.2.1
cookbook_file '/etc/ssh/sshd_config' do
  source 'sshd_config'
  owner 'root'
  group 'root'
  mode '0600'
  action :create
  notifies :restart, 'service[sshd]'
end

if node.chef_environment != 'uksouth-prod' && node.chef_environment != 'uksouth-sandbox'
  include_recipe 'nebula::cis'
end

include_recipe 'nebula::inspec'
