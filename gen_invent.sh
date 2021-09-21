#!/bin/bash

iscsi_ip=`terraform output external_ip_address_iscsi | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
pcm_ip=`terraform output external_ip_address_pcm | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
int_iscsi_ip=`terraform output internal_ip_address_iscsi | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
pcm0_ip=`terraform output external_ip_address_pcm_0 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
echo "[iscsi]" > my.invent
echo "${iscsi_ip}" >> my.invent
echo "" >> my.invent
echo "[pcm]" >> my.invent
echo "${pcm_ip}" >> my.invent
echo "" >> my.invent
echo "[pcm0]" >> my.invent
echo "${pcm0_ip}" >> my.invent
echo "===== inventory hase been generated ====="

echo "int_iscsi_ip: ${int_iscsi_ip}" > roles/create-initiator/vars/main.yml

# for /etc/hosts
int_pcm0_ip=`terraform output internal_ip_address_pcm_0 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
int_pcm1_ip=`terraform output internal_ip_address_pcm_1 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
int_pcm2_ip=`terraform output internal_ip_address_pcm_2 | grep -Po '(\d{1,3}\.){3}\d{1,3}'`
hname_pcm0=`terraform output hostname_pcm_0 | grep -Po '\w+'`
hname_pcm1=`terraform output hostname_pcm_1 | grep -Po '\w+'`
hname_pcm2=`terraform output hostname_pcm_2 | grep -Po '\w+'`
echo "${int_pcm0_ip}   ${hname_pcm0}" > roles/install-pacemaker/files/hosts
echo "${int_pcm1_ip}   ${hname_pcm1}" >> roles/install-pacemaker/files/hosts
echo "${int_pcm2_ip}   ${hname_pcm2}" >> roles/install-pacemaker/files/hosts
echo "===== file etc/hosts hase been generated ====="
nodes=`echo "${hname_pcm0} ${hname_pcm1} ${hname_pcm2}"`
sed -i '/^nodes/d' roles/install-pacemaker/vars/main.yml
sed -i "$ a nodes: '${nodes}'" roles/install-pacemaker/vars/main.yml
