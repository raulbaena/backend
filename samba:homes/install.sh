#! /bin/bash
# @edt ASIX M06 2018-2019
# instalacion servidor samba/pam
# -------------------------------------
mkdir /var/lib/samba/public
chmod 777 /var/lib/samba/public
cp /opt/docker/* /var/lib/samba/public/.
useradd -g users local01
useradd -g users local02
useradd -g users local03
echo "local01" | passwd --stdin local01
echo "local02" | passwd --stdin local02
echo "local03" | passwd --stdin local03

cp /opt/docker/smb.conf /etc/samba/smb.conf
authconfig --enableshadow --enablelocauthorize --enableldap --ldapserver='ldap' --ldapbase='dc=edt,dc=org' --enableldapauth --updateall
/usr/sbin/nslcd
/usr/sbin/nscd
/usr/sbin/smbd
/usr/sbin/nmbd

echo -e "pere\npere"|smbpasswd -a pere
echo -e "pau\npau"|smbpasswd -a pau
echo -e "marta\nmarta"|smbpasswd -a marta
echo -e "admin\nadmin"|smbpasswd -a admin
echo -e "local01\nlocal01"|smbpasswd -a local01
echo -e "local02\nlocal02"|smbpasswd -a local02
echo -e "local03\nlocal03"|smbpasswd -a local03
mkdir -p /tmp/home/pere 
mkdir -p /tmp/home/marta 
mkdir -p /tmp/home/anna 
mkdir -p /tmp/home/pau 
mkdir -p /tmp/home/admin
cp /opt/docker/README.md /tmp/home/pere/README.pere
cp /opt/docker/README.md /tmp/home/marta/README.marta
cp /opt/docker/README.md /tmp/home/anna/README.anna
cp /opt/docker/README.md /tmp/home/pau/README.pau
cp /opt/docker/README.md /tmp/home/admin/README.admin

chown -R pere.hisx2 /tmp/home/pere
chown -R pau.hisx2 /tmp/home/pau
#chown -R anna.hisx2 /tmp/home/anna
chown -R marta.hisx2 /tmp/home/marta
chown -R pere.wheel /tmp/home/admin
