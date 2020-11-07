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

if node.chef_environment != 'uksouth-prod' && node.chef_environment != 'uksouth-sandbox'
  include_recipe 'nebula::cis'
end

include_recipe 'nebula::inspec'
