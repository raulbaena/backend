# PRACTICA SAMBA, LDAP BACKEND

## ARQUITECTURA

Disposem de un servidor samba i un servidor LDAP. Aquest servidor LDAP fara de backend al servidor Samba. Tambe disposem de un hostpam amb el qual farem les proves del funcionament dels servidors. Tots aquests equips estan dintre d'una intranet anomenada sambanet. 

sambanet --> Xarxa local per la qual es comuniquen els equips informatics.

raulbaena/backend:samba --> Servidor samba amb el qual es comparteixen els directoris

raulbaena/backend:ldapserver --> Servidor ldap amb usuaris/as. Aquest servidor samba actua com a servidor backend


## Implementacio 

Per comencar hem configurat un servidor ldap en el qual hem implementat un nou schema. Aquest esquema anomenat samba.schema conte la informacio necessaria. Primer hem de generar aquest shcema afegir-lo al fitxer de configuracio slapd.conf. Els schemas d'aquest fitxer han de quedar de la seguent forma.
```
#
# See slapd.conf(5) for details on configuration options.
# This file should NOT be world readable.
#

#include	/etc/openldap/schema/corba.schema
include		/etc/openldap/schema/core.schema
include		/etc/openldap/schema/cosine.schema
#include	/etc/openldap/schema/duaconf.schema
#include	/etc/openldap/schema/dyngroup.schema
include		/etc/openldap/schema/inetorgperson.schema
#include	/etc/openldap/schema/java.schema
#include	/etc/openldap/schema/misc.schema
include		/etc/openldap/schema/nis.schema
include		/etc/openldap/schema/openldap.schema
#include	/etc/openldap/schema/ppolicy.schema
include		/etc/openldap/schema/collective.schema
include         /etc/openldap/schema/samba.schema

# Allow LDAPv2 client connections.  This is NOT the default.
allow bind_v2
pidfile		/var/run/openldap/slapd.pid
#argsfile	/var/run/openldap/slapd.args

#-------------------------------------------------
database config
rootdn "cn=Sysadmin,cn=config"
rootpw {SSHA}JGzCfrm+TvKfHtbpjPdz3YCVYpqUbTVY
#passwd syskey
# -------------------------------------------------
database mdb
suffix "dc=edt,dc=org"
rootdn "cn=Manager,dc=edt,dc=org"
rootpw secret
directory /var/lib/ldap
index objectClass eq,pres
access to * by self write by * read
# ----------------------------------------------------------------------
database monitor
access to * by * none
```
El contingut del schema ho podem trobar al seguent enllas:
Ara executem el nostre servidor ldap amb la seguent comanda:
```
docker run --rm --name ldap -h ldap --network sambanet -d raulbaena/backend:ldapserver
```

Ja un cop executat el nostre servidor ldap, farem la configuracio necessaria per que funcioni el nostre servidor samba y utilitzi al servidor ldap com a backend.
Instalarem el paquet SMBLDAP-TOOLS per poder crear y configurar el nostre servidor.
Comensarem afegint aquestes lineas al nostre arxiu de configuracio smb.conf i ha de quedar de la seguent manera:
```
[global]
        workgroup = MYGROUP
        server string = Samba Server Version %v
        log file = /var/log/samba/log.%m
        max log size = 50
        security = user
        passdb backend = ldapsam:ldap://ldap
        ldap suffix = dc=edt,dc=org
        ldap admin dn = cn=Manager,dc=edt,dc=org
        ldap ssl = no
        ldap passwd sync = yes  

[homes]
        comment = Home Directories
        browseable = no
        writable = yes
;       valid users = %S
;       valid users = MYDOMAIN\%S
[public]
        comment = Share publico
        path = /tmp/home/public
        public = yes
        browseable = yes
        writable = yes
        printable = no
guest ok = yes
```
Crearem dos arxius un anomenat smbldap_bind.conf i un altre anomenat smbldap.conf. L'arxiu smbldap_bind.conf conté les credencials per a realitzar operacions d'escriptura al servidor ldap. Conté la contrasenya d'administració de l'arbre ldap. Mentres que el fitxer anomenat smbldap_bind.conf s’utilitza per definir paràmetres que tothom pugui llegir.
Ara crearem un fitxer anomenat populate ldif que contindra els objectes ldap per emmagatzemar la informacio
Un cop tinguem la nostra maquina configurada executem la seguent comanda que posara en marxa el nostre servidor:
```
docker run --rm --name samba -h samba --network sambanet -it raulbaena/backend:samba
```
Ja tindrem el nostre servidor samba correns amb ldap com a backend.

## Troubleshooting

Per comprovar el funcionament d'aquesta infraestructura han de estar les dos maquines en funcionament. Comprovarem que funciona fent les ordres pbedit -L, smbtree, getent passwd i getent group.
Ens situem en el nostre servidor samba que ja esta en funcionament. Primer comprovarem si el nostre servidor te connexio amb el servior ldap. Per fer-ho fem la seguent comanda:
```
[root@samba docker]# getent passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:99:99:Nobody:/:/sbin/nologin
systemd-coredump:x:999:998:systemd Core Dumper:/:/sbin/nologin
systemd-timesync:x:998:997:systemd Time Synchronization:/:/sbin/nologin
systemd-network:x:192:192:systemd Network Management:/:/sbin/nologin
systemd-resolve:x:193:193:systemd Resolver:/:/sbin/nologin
dbus:x:81:81:System message bus:/:/sbin/nologin
tss:x:59:59:Account used by the trousers package to sandbox the tcsd daemon:/dev/null:/sbin/nologin
nscd:x:28:28:NSCD Daemon:/:/sbin/nologin
nslcd:x:65:55:LDAP Client User:/:/sbin/nologin
local01:x:1000:100::/home/local01:/bin/bash
local02:x:1001:100::/home/local02:/bin/bash
local03:x:1002:100::/home/local03:/bin/bash
local04:x:1003:100::/home/local04:/bin/bash
pau:*:5000:100:Pau Pou:/tmp/home/pau:
pere:*:5001:100:Pere Pou:/tmp/home/pere:
anna:*:5002:600:Anna Pou:/tmp/home/anna:
marta:*:5003:600:Marta Mas:/tmp/home/marta:
jordi:*:5004:100:Jordi Mas:/tmp/home/jordi:
admin:*:10:10:Administrador Sistema:/tmp/home/admin:
user01:*:7001:610:user01:/tmp/home/1asix/user01:
user02:*:7002:610:user02:/tmp/home/1asix/user02:
user02:*:7003:610:user03:/tmp/home/1asix/user03:
user04:*:7004:610:user04:/tmp/home/1asix/user04:
user05:*:7005:610:user05:/tmp/home/1asix/user05:
user06:*:7006:611:user06:/tmp/home/2asix/user06:
user07:*:7007:611:user07:/tmp/home/2asix/user07:
user08:*:7008:611:user08:/tmp/home/2asix/user08:
user09:*:7009:611:user09:/tmp/home/2asix/user09:
user10:*:7010:611:user10:/tmp/home/2asix/user10:
mao:*:11001:650:mao tse tung:/tmp/home/1wiaw/mao:
ho:*:11002:650:ho chi minh:/tmp/home/1wiaw/ho:
hiro:*:11003:650:hirohito:/tmp/home/1wiaw/hiro:
nelson:*:11004:650:nelson mandela:/tmp/home/1wiaw/nelson:
robert:*:11005:650:robert mugabe:/tmp/home/1wiaw/robert:
ali:*:11006:650:ali bey:/tmp/home/1wiaw/ali:
konrad:*:11007:651:konrad adenauer:/tmp/home/2wiaw/konrad:
humphrey:*:11008:651:humpprey appleby:/tmp/home/2wiaw/humphrey:
carles:*:11009:651:carles puigdemon:/tmp/home/2wiaw/jordi:
francisco:*:11010:651:francisco franco bahamonde:/tmp/home/2wiaw/fracisco:
vladimir:*:11011:651:vladimir putin:/tmp/home/2wiaw/vladimir:
jorge:*:11012:651:jorge mario bergoglio:/tmp/home/2wiaw/jorge:
root:*:0:0:Netbios Domain Administrator:/home/root:/bin/false
nobody:*:999:514:nobody:/nonexistent:/bin/false
```
Ara probarem l'ordre getent group
```
[root@samba docker]# getent group 
root:x:0:
bin:x:1:
daemon:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mem:x:8:
kmem:x:9:
wheel:x:10:
cdrom:x:11:
mail:x:12:
man:x:15:
dialout:x:18:
floppy:x:19:
games:x:20:
tape:x:33:
video:x:39:
ftp:x:50:
lock:x:54:
audio:x:63:
nobody:x:99:
users:x:100:
utmp:x:22:
utempter:x:35:
input:x:999:
kvm:x:36:
systemd-journal:x:190:
systemd-coredump:x:998:
systemd-timesync:x:997:
systemd-network:x:192:
systemd-resolve:x:193:
dbus:x:81:
tss:x:59:
printadmin:x:996:
nscd:x:28:
ldap:x:55:
localgrp01:x:1000:local01,local02
localgrp02:x:1001:local03,local04
Domain Admins:*:512:root
Domain Users:*:513:
Domain Guests:*:514:
Domain Computers:*:515:
Administrators:*:544:
Account Operators:*:548:
Print Operators:*:550:
Backup Operators:*:551:
Replicators:*:552:
```
Ara probarem amb la comanda smbtree:
```
[root@samba docker]# smbtree
WORKGROUP
	\\RAUL-LAP       		Samba 4.5.12-Debian
		\\RAUL-LAP\Able2Extract   	Able2Extract Professional Printer
		\\RAUL-LAP\IPC$           	IPC Service (Samba 4.5.12-Debian)
		\\RAUL-LAP\print$         	Printer Drivers
	\\J15            		Samba 4.9.5-Debian
MYGROUP
	\\SAMBA          		Samba Server Version 4.7.10
		\\SAMBA\IPC$           	IPC Service (Samba Server Version 4.7.10)
		\\SAMBA\public         	Share publico
[root@samba docker]# 
```

## Execució de tota la infraestructura
```
docker network create sambanet
docker run --rm --name ldap -h ldap --network sambanet -d raulbaena/backend:ldapserver
docker run --rm --name samba -h samba --network sambanet -d raulbaena/backend:samba
```
