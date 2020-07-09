case node['platform_version']
when '16.04'
  default['inspec']['deb_url'] = 'https://packages.chef.io/files/stable/inspec/4.21.3/ubuntu/16.04/inspec_4.21.3-1_amd64.deb'
  default['inspec']['deb_sha256'] = '4a1eb3a0deb5bbbe63cb0ab63b30eaef06d16077dfbc1671e60fa897e7759375'
when '18.04'
  default['inspec']['deb_url'] = 'https://packages.chef.io/files/stable/inspec/4.21.3/ubuntu/18.04/inspec_4.21.3-1_amd64.deb'
  default['inspec']['deb_sha256'] = '4a1eb3a0deb5bbbe63cb0ab63b30eaef06d16077dfbc1671e60fa897e7759375'
when '20.04'
  default['inspec']['deb_url'] = 'https://packages.chef.io/files/stable/inspec/4.21.3/ubuntu/20.04/inspec_4.21.3-1_amd64.deb'
  default['inspec']['deb_sha256'] = '4a1eb3a0deb5bbbe63cb0ab63b30eaef06d16077dfbc1671e60fa897e7759375'
end
