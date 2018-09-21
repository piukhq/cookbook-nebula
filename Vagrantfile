Vagrant.configure('2') do |v|
  v.vm.define 'nebula' do |b|
    b.vm.box = 'bento/ubuntu-16.04'
    b.vm.hostname = 'nebula'
    b.vm.network :private_network, type: 'dhcp'
    b.berkshelf.enabled = true
    b.vm.provision 'chef_solo' do |c|
      c.version = '13.8.5'
      c.cookbooks_path = '../'
      c.add_recipe 'nebula::default'
      c.environments_path = 'environments'
      c.environment = 'vagrant'
    end
  end
end
