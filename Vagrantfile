# -*- mode: ruby -*-

# Vagrant file API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

['vagrant-reload', 'vagrant-disksize'].each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise "Vagrant plugin #{plugin} is not installed!"
  end
end

# the directory where the provisioning scripts are located
$base_dir = File.dirname(File.realdirpath(__FILE__))

$devbind_img = "williamofockham/dpdk-devbind:18.11.2"
$dpdk_driver = "uio_pci_generic"
$dpdk_devices = "0000:00:06.0 0000:00:07.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at https://docs.vagrantup.com.
  config.vm.box = "generic/ubuntu1804"
  config.disksize.size = "45GB"

  # e.g. for wireshark forwarding
  config.ssh.forward_x11 = true
  config.ssh.forward_agent = true

  # config.vm.synced_folder ".", "/vagrant", disabled: false
  config.vm.synced_folder ".", "/vagrant/", type: "nfs"
  config.vm.provision "shell", inline: "echo 'cd /vagrant' >> /home/vagrant/.bashrc", run: "always"

  config.vm.network "public_network", dev: "net1", type: "bridge", ip: "192.168.10.2"
  config.vm.network "public_network", dev: "net2", type: "bridge", ip: "192.168.11.2"

  # Setup the VM for DPDK, including binding the extra interface via the fetched
  # container
  config.vm.provision "shell", path: "#{$base_dir}/utils/vm-setup.sh"
  
  # Pull and run (then remove) our image in order to do the devbind
  config.vm.provision "docker" do |d|
    d.pull_images "#{$devbind_img}"
    d.run "#{$devbind_img}",
          auto_assign_name: false,
          args: %W(--rm
                   --privileged
                   --network=host
                   -v /lib/modules:/lib/modules
                   -v /dev/hugepages:/dev/hugepages).join(" "),
          restart: "no",
          daemonize: true,
          cmd: "/bin/bash -c 'dpdk-devbind --force -b #{$dpdk_driver} #{$dpdk_devices}'"
  end

  # libvirt-specific configuration
  config.vm.provider "libvirt" do |v|
    # Set machine name, memory and CPU limits
    v.memory = 8192
    v.cpus = 4

  end
end
