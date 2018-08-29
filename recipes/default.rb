# CIS Benchmarks
# These scripts are intentionally inefficient to make it easier to break each
# "feature" down to a specific spec in the benchmarks

include_recipe 'apt'

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

# TODO: Finish implementation of 1.3.2

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

#Benchmark 4.1.1.1 - 4.1.1.3
directory '/etc/audit' do
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

file '/etc/audit/auditd.conf' do
  owner 'root'
  group 'root'
  mode 0644
  action :create_if_missing
end

[
  'max_log_file = 5',
  'space_left_action = email',
  'action_mail_acct = root',
  'admin_space_left_action = halt',
  'max_log_file_action = keep_logs'
].each do |line|
  append_if_no_line "add_#{line}_to_/etc/audit/auditd.conf" do
    path '/etc/audit/auditd.conf'
    line "#{line}"
  end
end

#Benchmark 4.1.2
package 'auditd' do
  action :install
end

service 'auditd' do
  action :enable
end

#Benchmark 4.1.3
add_to_list 'update-grub' do
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

#Benchmark 4.1.4 - 4.1.11
file '/etc/audit/audit.rules' do
  owner 'root'
  group 'root'
  mode 0644
  action :create_if_missing
end

[
  "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change",
  "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time- change",
  "-a always,exit -F arch=b64 -S clock_settime -k time-change",
  "-a always,exit -F arch=b32 -S clock_settime -k time-change",
  "-w /etc/localtime -p wa -k time-change",
  "-w /etc/group -p wa -k identity",
  "-w /etc/passwd -p wa -k identity",
  "-w /etc/gshadow -p wa -k identity",
  "-w /etc/shadow -p wa -k identity",
  "-w /etc/security/opasswd -p wa -k identity",
  "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale",
  "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale",
  "-w /etc/issue -p wa -k system-locale",
  "-w /etc/issue.net -p wa -k system-locale",
  "-w /etc/hosts -p wa -k system-locale",
  "-w /etc/sysconfig/network -p wa -k system-locale",
  "-w /etc/apparmor/ -p wa -k MAC-policy",
  "-w /etc/apparmor.d/ -p wa -k MAC-policy",
  "-w /var/log/faillog -p wa -k logins",
  "-w /var/log/lastlog -p wa -k logins",
  "-w /var/log/tallylog -p wa -k logins",
  "-w /var/run/utmp -p wa -k session",
  "-w /var/log/wtmp -p wa -k logins",
  "-w /var/log/btmp -p wa -k logins",
  "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod",
  "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod",
  "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod",
  "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod",
  "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod",
  "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod",
  "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access",
  "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access",
  "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access",
  "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"
].each do |line|
  append_if_no_line "add_#{line}_to_/etc/audit/audit.rules" do
    path '/etc/audit/audit.rules'
    line "#{line}"
  end
end

# TODO: Research Benchmark 4.1.12

#Benchmark 4.1.13 - 4.1.18
[

  "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts",
  "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts",
  "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete",
  "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete",
  "-w /etc/sudoers -p wa -k scope",
  "-w /etc/sudoers.d/ -p wa -k scope",
  "-w /var/log/sudo.log -p wa -k actions",
  "-w /sbin/insmod -p x -k modules",
  "-w /sbin/rmmod -p x -k modules",
  "-w /sbin/modprobe -p x -k modules",
  "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules",
  "-e 2"
].each do |line|
  append_if_no_line "add_#{line}_to_/etc/audit/audit.rules" do
    path '/etc/audit/audit.rules'
    line "#{line}"
  end
end

#Benchmark 4.2.1.1
service 'rsyslog' do
  action :enable
end

#TODO: Research Benchmark 4.2.1.2

#Benchmark 4.2.1.3
replace_or_add 'configure_FileCreateMode_in_/etc/rsyslog.conf' do
  path '/etc/rsyslog.conf'
  pattern '$FileCreateMode*'
  line '$FileCreateMode 0640'
  replace_only true
end

#TODO: Benchmark 4.2.1.4

#TODO: Benchmark 4.3

#Benchmark 5.1.1
service 'cron' do
  action :enable
end

#Benchmark 5.1.2
file '/etc/crontab' do
  mode 0600
end

#Benchmark 5.1.3 - 5.1.7
%w(hourly daily weekly monthly d).each do |d|
  directory "/etc/cron.#{d}" do
    mode 0700
  end
end

#Benchmark 5.1.8
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

#Benchmark 5.2.1
file '/etc/ssh/sshd_config' do
  action :touch
  owner 'root'
  group 'root'
  mode 0600
end

#Benchmark 5.2.2
append_if_no_line 'configure_Protocol_in_/etc/ssh/sshd_config' do
  path '/etc/ssh/sshd_config'
  line 'Protocol 2'
end
