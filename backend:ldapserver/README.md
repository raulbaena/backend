# Servidor LDAP

## Descripcio 

raulbaena/ssh:ldapserver --> Servidor ldap que proveira usuaris per connectarse per ssh. Aquesta maquina conte una base de dades anomenada dc=edt,dc=org.


## Configuracio

ldap.conf --> Aquest és l'arxiu de configuració per a totes les aplicacions client que fan servir les biblioteques OpenLDAP com ara ldapsearch, ldapadd, Sendmail, Pine, Bassa, Evolution, i Gnome Meeting.
Contingut de l'arxiu
```
#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

#BASE	dc=example,dc=com
#URI	ldap://ldap.example.com ldap://ldap-master.example.com:666

#SIZELIMIT	12
#TIMELIMIT	15
#DEREF		never

TLS_CACERTDIR /etc/openldap/certs

# Turning this off breaks GSSAPI used with krb5 when rdns = false
SASL_NOCANON	on

URI ldap://ldap/
BASE dc=escoladeltreball,dc=org
```

slapd.conf --> Aquest és l'arxiu configuració per al dimoni slapd.
Contingut de l'arxiu
```
# See slapd.conf(5) for details on configuration options.
# This file should NOT be world readable.
#

include		/etc/openldap/schema/corba.schema
include		/etc/openldap/schema/core.schema
include		/etc/openldap/schema/cosine.schema
include		/etc/openldap/schema/duaconf.schema
include		/etc/openldap/schema/dyngroup.schema
include		/etc/openldap/schema/inetorgperson.schema
include		/etc/openldap/schema/java.schema
include		/etc/openldap/schema/misc.schema
include		/etc/openldap/schema/nis.schema
include		/etc/openldap/schema/openldap.schema
include		/etc/openldap/schema/ppolicy.schema
include		/etc/openldap/schema/collective.schema

# Allow LDAPv2 client connections.  This is NOT the default.
allow bind_v2

pidfile		/var/run/openldap/slapd.pid
#argsfile	/var/run/openldap/slapd.args

# ----------------------------------------------------------------------
database bdb
suffix "dc=edt,dc=org"
rootdn "cn=Manager,dc=edt,dc=org"
rootpw secret
directory /var/lib/ldap

# Indices to maintain for this database
index objectClass                       eq,pres

# ACL for this database
access to *
	by self write
	by * read
# ----------------------------------------------------------------------
	
# enable monitoring
database monitor

# allow only rootdn to read the monitor
access to *
       by dn.exact="cn=Manager,dc=edt,dc=org" read
       by * none

```

## Execucio de la maquina 

Per executar la maquina fes la seguent ordre:

```
docker run --rm --name ldap -h ldap --network sshnet -d raulbaena/shh:ldapserver 
```

