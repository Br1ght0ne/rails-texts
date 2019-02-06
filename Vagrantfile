Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.hostname = "texts"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.synced_folder "app", "/opt/app"

  config.vm.provision :ansible do |ansible| 
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "provision/main.yml"
  end
end
