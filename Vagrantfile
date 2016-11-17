# -*- mode: ruby -*-
# vi: set ft=ruby :

# WARNING: Not ready yet!

Vagrant.configure("2") do |config|

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8443
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 3306, host: 3306
  config.vm.synced_folder "./", "/develop/idb/idb"

  config.vm.define :ubuntu1404 do |c|
    c.vm.box = 'ubuntu1404'
    c.vm.box_url = 'http://vagrantboxes.example.com/ubuntu1404.box'
  end

  config.vm.define :ubuntu1604 do |c|
    c.vm.box = 'ubuntu1604'
    c.vm.box_url = 'http://vagrantboxes.office.bytemine.net/ubuntu1604.box'
  end
  
end
