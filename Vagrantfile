# frozen_string_literal: true

Vagrant.configure('2') do |config|
  config.vm.box = 'geerlingguy/ubuntu1804'
  config.vm.hostname = 'rails'
  config.vm.network 'forwarded_port', guest: 3000, host: 3001

  config.vm.provision :ansible do |ansible|
    ansible.compatibility_mode = '2.0'
    ansible.playbook = 'provisioning/playbook.yml'
    ansible.become = true
  end
end
