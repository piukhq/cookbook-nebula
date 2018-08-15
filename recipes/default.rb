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

#%w(cramfs freevxfs jffs2 hfs hfsplus udf).each do |f|
  #append_if_no_line "disable_#{f}_filesystem" do
    #path '/etc/modprobe.d/disabled_filesystems.conf'
    #line "install #{f} /bin/true"
  #end
#end

%w(cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat).each do |fs|
  append_if_no_line "disable_#{fs}_filesystem" do
    path '/etc/modprobe.d/disabled_filesystems.conf'
    line "install #{fs} /bin/true"
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

