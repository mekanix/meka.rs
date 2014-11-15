# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define "blog" do |blog|
        blog.vm.box = "jayunit100-VAGRANTSLASH-centos7"
        blog.vm.box_url = "https://vagrantcloud.com/jayunit100/boxes/centos7/versions/1/providers/virtualbox.box"
        blog.vm.network :private_network, ip: "192.168.33.33"
        blog.vm.provision :ansible do |ansible|
            ansible.playbook = "provision/site.yml"
            ansible.host_key_checking = false
            ansible.groups = {
                "vagrant" => ["onelove"],
            }
        end
    end
end
