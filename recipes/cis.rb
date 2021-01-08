# CIS Benchmarks
# These scripts are intentionally inefficient to make it easier to break each
# "feature" down to a specific spec in the benchmarks

# Benchmarks: 1.1.1.1 - 1.1.1.6
file '/etc/modprobe.d/disabled_filesystems.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  action :create_if_missing
end

%w(cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat).each do |f|
  append_if_no_line "disable_#{f}_filesystem" do
    path '/etc/modprobe.d/dev-sec.conf'
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

# Benchmark: 1.1.21
service 'autofs' do
  action :disable
end

# Benchmark: 1.4.1
file '/boot/grub/grub.cfg' do
  mode '0400'
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

execute 'sysctl-kernel.sysrq' do
  command 'sysctl -w kernel.sysrq=0'
  action :nothing
end

append_if_no_line 'set-kernel.sysrq' do
  path '/etc/sysctl.conf'
  line 'kernel.sysrq = 0'
  notifies :run, 'execute[sysctl-kernel.sysrq]'
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

# Benchmark: 1.7.1.1
%w(10-help-text 51-cloudguest 90-updates-available 91-release-upgrade).each do |motd|
  file "/etc/update-motd.d/#{motd}" do
    action :delete
  end
end

# Benchmark: 1.7.1.2 - 1.7.1.3
file '/etc/update-motd.d/11-disclaimer' do
  content "\#!/bin/bash\necho 'Your activity is logged and recorded for audit purposes.'"
  owner 'root'
  group 'root'
  mode '0755'
end

# Benchmark: 1.8.1.2-6
file '/etc/motd' do
  owner 'root'
  group 'root'
  mode '0644'
end

%w(issue issue.net).each do |f|
  file "/etc/#{f}" do
    owner 'root'
    group 'root'
    mode '0644'
    content 'Authorized uses only. All activity may be monitored and reported.'
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

# Benchmark 3.5.1 - 3.5.4
%w(dccp sctp rds tipc).each do |f|
  append_if_no_line "disable_#{f}_protocol" do
    path '/etc/modprobe.d/disabled_protocols.conf'
    line "install #{f} /bin/true"
  end
end

# Benchmark 4.1.2 - removing in favour of auditbeat
package 'auditd' do
  action :remove
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

# Benchmark 4.2.1.1
service 'rsyslog' do
  action :enable
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
  mode '0600'
end

# Benchmark 5.1.3 - 5.1.7
%w(hourly daily weekly monthly d).each do |d|
  directory "/etc/cron.#{d}" do
    mode '0700'
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
    owner 'root'
    group 'root'
    mode '0600'
  end
end

# Benchmark 5.6
append_if_no_line 'prevent_access_to_su' do
  path '/etc/pam.d/su'
  line 'auth required pam_wheel.so'
end

# Benchmark 6.1.2 - 6.1.9
%w(/etc/passwd /etc/group /etc/passwd- /etc/group-).each do |f|
  file f do
    mode '0644'
  end
end

%w(/etc/shadow /etc/gshadow /etc/shadow- /etc/gshadow-).each do |f|
  file f do
    mode '0640'
  end
end

# Benchmark 6.2.11 - 6.2.14
node['users']['active'].each do |u|
  %w(.forward .netrc .rhosts).each do |f|
    file "/home/#{u[:name]}/#{f}" do
      action :delete
    end
  end
end

# Fix login.defs
replace_or_add 'login.defs-PASS_MAX_DAYS' do
  path '/etc/login.defs'
  pattern 'PASS_MAX_DAYS.+'
  line 'PASS_MAX_DAYS 60'
end

replace_or_add 'login.defs-PASS_MIN_DAYS' do
  path '/etc/login.defs'
  pattern 'PASS_MIN_DAYS.+'
  line 'PASS_MIN_DAYS 7'
end

replace_or_add 'login.defs-UMASK' do
  path '/etc/login.defs'
  pattern 'UMASK.+'
  line 'UMASK 027'
end
