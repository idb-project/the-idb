# User management within IDB

## LDAP / AD Backend

The idb is LDAP / AD backend based, this is currently the sole source of users.
The LDAP / AD is configured in config/application.yml:

```
  ldap:
    host: '127.0.0.1'
    port: 389
    base: 'dc=nodomain'
    uid: 'uid'
    auth_dn: 
    auth_password:
    uid: 'uid'
    admin_group: 'cn=admins,cn=groups,dc=example,dc=com'
    group_membership_attribute: 'uniqueMember'
```

The relevant infos for the users are `uid` as well as the `admin_group`.

## Users and admins

Admins can access the backoffice actions. Furthermore there are no visibility
restrictions laid upon admins ("They see everything, but don't tell on anyone"), 
such as owner restrictions.

If _no_ `admin_group` is defined, all users are treated as admins.



