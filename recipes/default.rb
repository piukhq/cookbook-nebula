# CIS Benchmarks
# These scripts are intentionally inefficient to make it easier to break each
# "feature" down to a specific spec in the benchmarks

include_recipe 'apt'
# URL: https://packages.chef.io/files/stable/inspec/2.2.70/ubuntu/16.04/inspec_2.2.70-1_amd64.deb

directory '/usr/local/src/inspec'
remote_file '/usr/local/src/inspec/inspec_2.2.70-1_amd64.deb' do
  source 'https://packages.chef.io/files/stable/inspec/2.2.70/ubuntu/16.04/inspec_2.2.70-1_amd64.deb'
end

dpkg_package 'inspec_2.2.70-1_amd64.deb' do
  source '/usr/local/src/inspec/inspec_2.2.70-1_amd64.deb'
end

directory '/usr/local/src/inspec'
template '/usr/local/src/inspec/cis.rb' do
  source 'spec.rb.erb'
end

# Benchmarks: 1.1.1.1 - 1.1.1.6
file '/etc/modprobe.d/disabled_filesystems.conf' do
  owner 'root'
  group 'root'
  mode 0644
  action :create_if_missing
end

%w(cramfs freevxfs jffs2 hfs hfsplus udf).each do |f|
  append_if_no_line "disable_#{f}_filesystem" do
    path '/etc/modprobe.d/disabled_filesystems.conf'
    line "install #{f} /bin/true"
  end
end

# Benchmarks: 1.1.1.14 - 1.1.1.16
execute 'remount-dev-shm' do
  command 'mount -o remount,nodev,nosuid,noexec /dev/shm'
  action :nothing
end

append_if_no_line 'set nodev nosuid and noexec for /dev/shm in fstab' do
  path '/etc/fstab'
  line 'tmpfs /dev/shm tmpfs nodev,nosuid,noexec 0 0'
  notifies :run, 'execute[remount-dev-shm]', :immediately
end

# Benchmark: 1.1.20
Dir['/*'].each do |d|
  if File.world_writable?(d) && !File.sticky?(d)
    directory d do
      mode 01777
    end
  end
end

# Benchmark: 1.1.21
service 'autofs' do
  action :disable
end

# Benchmark: 1.3.1
package 'aide' do
  action :install
#  notifies :run 'execute[aideinit]' TODO: finish implementation of aideinit
end

# TODO: Finish implementation of 1.3.2 and update bookstack for 1.3.1 & 1.3.2

# Benchmark: 1.4.1
file '/boot/grub/grub.cfg' do
  mode 0400
end

# Benchmark: 1.5.1
append_if_no_line 'hard core 0' do
  path '/etc/security/limits.conf'
  line '* hard core 0'
end

execute 'sysctl-fs.suid_dumpable' do
  command 'sysctl -w fs.suid_dumpable=0'
  action :nothing
end

append_if_no_line 'set-fs.suid_dumpable' do
  path '/etc/sysctl.conf'
  line 'fs.suid_dumpable = 0'
  notifies :run, 'execute[sysctl-fs.suid_dumpable]'
end

# Benchmark: 1.5.3
execute 'sysctl-kernel.randomize_va_space' do
  command 'sysctl -w kernel.randomize_va_space=2'
  action :nothing
end

append_if_no_line 'set-kernel.randomize_va_space' do
  path '/etc/sysctl.conf'
  line 'kernel.randomize_va_space = 2'
  notifies :run, 'execute[sysctl-kernel.randomize_va_space]'
end

# Benchmark 1.5.4
execute 'restore_prelink_bins' do
  command 'prelink -ua'
  only_if { ::File.exist?('/usr/sbin/prelink') }
end

package 'prelink' do
  action :remove
end

# Benchmark 1.6.3
package 'apparmor' do
  action :upgrade
end

# Benchmark: 1.7.1.1
%w(10-help-text 51-cloudguest 90-updates-available 91-release-upgrade).each do |motd|
  file "/etc/update-motd.d/#{motd}" do
    action :delete
  end
end

# Benchmark: 1.7.1.2 - 1.7.1.3
file '/etc/update-motd.d/11-disclaimer' do
  content "\#!/bin/bash\necho 'You are connecting to a Loyalty Angels Ltd Server.'\necho 'Your activity is logged and recorded for audit purposes.'"
  owner 'root'
  group 'root'
  mode  0755
end

# Benchmark: 1.7.1.4 - 1.7.1.6
%w(motd issue issue.net).each do |f|
  file "/etc/#{f}" do
    owner 'root'
    group 'root'
    mode 0644
  end
end

# Benchmark: 2.1.1 - 2.1.11
file '/etc/xinetd.conf' do
  action :delete
end

directory '/etc/xinetd.d' do
  action :delete
  recursive true
end

package 'openbsd-inetd' do
  action :remove
end

# Benchmark: 2.2.1.1
package 'chrony' do
  action :install
end

# Benchmark 2.2.1.3
service 'chrony' do
  action :nothing
end

template '/etc/chrony/chrony.conf' do
  source 'chrony/config.erb'
  notifies :restart, 'service[chrony]'
end

# Benchmark: 2.2.2
package 'xserver-xorg' do
  action :remove
end

# Benchmark: 2.2.3 - 2.2.17
%w(
  avahi-daemon
  cups
  isc-dhcp-server
  isc-dhcp-server6
  slapd
  nfs-server
  bind9
  vsftpd
  apache2
  dovecot
  smbd
  squid
  snmpd
  postfix
  rsync
  nis
).each do |s|
  service s do
    action :disable
  end
end

systemd_unit 'rpcbind' do
  action :mask
end

# Benchmark: 2.3.1 - 2.3.5
%w(
  nis
  rsh-client
  rsh-redone-client
  talk
  telnet
  ldap-utils
).each do |a|
  package a do
    action :remove
  end
end

# Benchmark: 3.1.2 - 3.2.8
execute 'flush_routes' do
  command 'sysctl -w net.ipv4.route.flush=1'
  action :nothing
end

delete_lines 'remove_comments_from_/etc/sysctl.conf' do
  path '/etc/sysctl.conf'
  pattern /^#.*/
end

delete_lines 'remove_empty_lines' do
  path '/etc/sysctl.conf'
  pattern /^\s*$/
end

[
  "net.ipv4.conf.all.send_redirects",
  "net.ipv4.conf.default.send_redirects",
  "net.ipv4.conf.all.accept_source_route",
  "net.ipv4.conf.default.accept_source_route",
  "net.ipv4.conf.all.accept_redirects",
  "net.ipv4.conf.default.accept_redirects",
  "net.ipv4.conf.all.secure_redirects",
  "net.ipv4.conf.default.secure_redirects"
].each do |line|
  append_if_no_line "add_#{line}_to_/etc/sysctl.conf" do
    path '/etc/sysctl.conf'
    line "#{line} = 0"
    notifies :run, "execute[apply_#{line}]", :immediately
  end
  execute "apply_#{line}" do
    command "sysctl -w #{line}=0"
    action :nothing
    notifies :run, 'execute[flush_routes]'
  end
end

[
  "net.ipv4.conf.all.log_martians",
  "net.ipv4.conf.default.log_martians",
  "net.ipv4.icmp_echo_ignore_broadcasts",
  "net.ipv4.icmp_ignore_bogus_error_responses",
  "net.ipv4.conf.all.rp_filter",
  "net.ipv4.conf.default.rp_filter",
  "net.ipv4.tcp_syncookies"
].each do |line|
  append_if_no_line "add_#{line}_to_/etc/sysctl.conf" do
    path '/etc/sysctl.conf'
    line "#{line} = 1"
    notifies :run, "execute[apply_#{line}]", :immediately
  end
  execute "apply_#{line}" do
    command "sysctl -w #{line}=1"
    action :nothing
    notifies :run, 'execute[flush_routes]'
  end
end

# Benchmark 3.5.1 - 3.5.4
%w(dccp sctp rds tipc).each do |f|
  append_if_no_line "disable_#{f}_protocol" do
    path '/etc/modprobe.d/disabled_protocols.conf'
    line "install #{f} /bin/true"
  end
end

# Benchmark 3.6.1
package 'iptables' do
  action :upgrade
end

# Benchmark 4.1.2
package 'auditd' do
  action :install
end

service 'auditd' do
  action :enable
end

# Benchmark 4.1.3
add_to_list 'enable_auditd_on_boot' do
  path '/etc/default/grub'
  pattern 'GRUB_CMDLINE_LINUX='
  delim [' ']
  ends_with '"'
  entry 'audit=1'
  notifies :run, 'execute[update-grub]', :immediately
end

execute 'update-grub' do
  command 'update-grub'
  action :nothing
end

# Benchmark 4.1.4 - 4.1.18
template '/etc/audit/audit.rules' do
  owner 'root'
  group 'root'
  mode 0644
  source 'auditd/rules.erb'
  notifies :restart, 'service[auditd]'
end

# TODO: Research Benchmark 4.1.12 & update bookstack

# Benchmark 4.2.1.1
service 'rsyslog' do
  action :enable
end

# Benchmark 4.2.1.2 & 4.2.1.4 TODO: Improve below
file '/etc/rsyslog.d/99-graylog.conf' do
  content "*.* @@#{node[:graylog][:connection]};RSYSLOG_SyslogProtocol23Format"
  notifies :restart, 'service[rsyslog]', :immediately
end

# Benchmark 4.2.1.3
replace_or_add 'configure_FileCreateMode_in_/etc/rsyslog.conf' do
  path '/etc/rsyslog.conf'
  pattern '$FileCreateMode*'
  line '$FileCreateMode 0640'
  replace_only true
end

# Benchmark 5.1.1
service 'cron' do
  action :enable
end

# Benchmark 5.1.2
file '/etc/crontab' do
  mode 0600
end

# Benchmark 5.1.3 - 5.1.7
%w(hourly daily weekly monthly d).each do |d|
  directory "/etc/cron.#{d}" do
    mode 0700
  end
end

# Benchmark 5.1.8
%w(/etc/cron.deny /etc/at.deny).each do |f|
  file f do
    action :delete
  end
end

%w(/etc/cron.allow /etc/at.allow).each do |f|
  file f do
    action :touch
    owner 'root'
    group 'root'
    mode 0600
  end
end

# Benchmark 5.2.1
file '/etc/ssh/sshd_config' do
  action :touch
  owner 'root'
  group 'root'
  mode 0600
end

# Benchmark 5.2.2
replace_or_add 'configure_Protocol_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'Protocol '
  line 'Protocol 2'
end

# Benchmark 5.2.3
replace_or_add 'configure_LogLevel_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'LogLevel '
  line 'LogLevel INFO'
end

# Benchmark 5.2.4
replace_or_add 'configure_X11Forwarding_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'X11Forwarding '
  line 'X11Forwarding no'
end

# Benchmark 5.2.5
replace_or_add 'configure_MaxAuthTries_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'MaxAuthTries '
  line 'MaxAuthTries 4'
end

# Benchmark 5.2.6
replace_or_add 'configure_IgnoreRhosts_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'IgnoreRhosts '
  line 'IgnoreRhosts yes'
end

# Benchmark 5.2.7
replace_or_add 'configure_HostbasedAuthentication_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'HostbasedAuthentication '
  line 'HostbasedAuthentication no'
end

# Benchmark 5.2.8
replace_or_add 'configure_PermitRootLogin_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'PermitRootLogin '
  line 'PermitRootLogin no'
end

# Benchmark 5.2.9
replace_or_add 'configure_PermitEmptyPasswords_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'PermitEmptyPasswords '
  line 'PermitEmptyPasswords no'
end

# Benchmark 5.2.10
replace_or_add 'configure_PermitUserEnvironment_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'PermitUserEnvironment '
  line 'PermitUserEnvironment no'
end

# Benchmark 5.2.11
append_if_no_line 'configure_MACs_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  line 'MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com'
end

# Benchmark 5.2.12
replace_or_add "configure_ClientAliveInterval_in_/etc/ssh/sshd_config" do
  path '/etc/ssh/sshd_config'
  pattern 'ClientAliveInterval '
  line 'ClientAliveInterval 300'
end

replace_or_add "configure_ClientAliveCountMax_in_/etc/ssh/sshd_config" do
  path '/etc/ssh/sshd_config'
  pattern 'ClientAliveCountMax '
  line 'ClientAliveCountMax 0'
end

# Benchmark 5.2.13
replace_or_add 'configure_LoginGraceTime_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'LoginGraceTime '
  line 'LoginGraceTime 60'
end

# Benchmark 5.2.15
replace_or_add 'configure_Banner_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  pattern 'Banner '
  line 'Banner /etc/issue.net'
end

# TODO: Benchmark 5.4.2 - 5.6 & update bookstack CHRIS
# Notes for Bookstack:
# 5.4.2 cannot be easily implemented in Chef without potentally causing harm
# to other services, as such, we won't do this unless the tests show specific
# examples.

# 5.4.3 could cause the same issue as 5.4.2, we'll test for it

# TODO: Implement 5.4.4

# 5.4.5 not sure if there is any reasonable value in implementing this
# Office computers have a screen sleep policy of 2 minutes.

# 5.5 This is a VM, this does not apply.

# Benchmark 5.6
append_if_no_line 'prevent_access_to_su' do
  path '/etc/pam.d/su'
  line 'auth required pam_wheel.so'
end

# Benchmark 6.1.2 - 6.1.9
%w(/etc/passwd /etc/group /etc/passwd- /etc/group-).each do |f|
  file f do
    mode 0644
  end
end

%w(/etc/shadow /etc/gshadow /etc/shadow- /etc/gshadow-).each do |f|
  file f do
    mode 0640
  end
end

#TODO:Benchmark 6.1.10 - 6.2.20 & update bookstack CHRIS
