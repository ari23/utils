#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
# silence ansible warnings to e.g. "run apt module instead of apt command"
export ANSIBLE_COMMAND_WARNINGS=False

BASE_DIR=$1

sudo -E apt-get install -y ansible aptitude quagga curl screen python-pip python-backports.ssl-match-hostname
sudo -E pip install termcolor

cd /vagrant/$BASE_DIR/containernet/ansible
sudo -E ansible-playbook -i "localhost," -c local install.yml

cd /vagrant/$BASE_DIR/containernet
sudo python setup.py install
sudo py.test -v mininet/test/test_containernet.py

cd /vagrant/$BASE_DIR
rm -rf oflops oftest openflow pox
