#!/bin/bash
sudo sh -c 'echo user.max_user_namespaces=15000  >/etc/sysctl.d/90-max_user_namespaces.conf'
sudo sysctl -p /etc/sysctl.d/90-max_user_namespaces.conf