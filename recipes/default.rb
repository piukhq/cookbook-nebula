# CIS Benchmarks
# These scripts are intentionally inefficient to make it easier to break each
# "feature" down to a specific spec in the benchmarks

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

# Benchmark: 1.3
package 'aide'

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
package 'chrony'


