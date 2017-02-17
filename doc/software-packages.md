# Software packages

The software packages module enables searching the installed software of machines.

## Design
Software configuration of machines is stored as a JSON column in the database. This requires
MySQL 5.7. The stored JSON is a array of objects which MUST have a `name` and MAY have a `version`:

	[ { "name": "python", "version": "2.6" },
	  { "name":"openssh" },
	  { "name": "nmap", "version": "7.12"} ]

Versions are strings as they can differ in format between packages and platform. 
Python on CentOS maybe looks like this:

	`{ "name" : "python", "version": "2.6.6-66.el6_8.x86_64" }`
while on Debian it looks like this:

	`{ "name": "python", "2.6.6-3.22.201205211619" }`
and Ubuntu like this:

	`{ "name": "python", "version": "2.7.11-1" }`

## Sources

This column can only be filled automatically with data, no frontend for manual input exists. Currently
two methods are supported to add software data to machines.

### API
Currently the software configuration can be imported using the IDB-API. The relevant field
for this is the `software` field containing a value like described above.

### Puppet
Scripts are used to provide a custom `idb_installed_packages` fact. These scripts can be found at
[https://github.com/idb-project/idb-puppetintegration](https://github.com/idb-project/idb-puppetintegration/).
The fact consists of a list enclosed by `[` and `]` of space seperated items which are returned from the individiual package manager,
e.g. a python package would be listed as `python=2.6.6-3.22.201205211619` in an apt based system.
A list of those items may look like this:

	 [accountsservice=0.6.40-2ubuntu11.2 acl=2.2.52-3 acpid=1:2.0.26-1ubuntu2 ... zlib1g:amd64=1:1.2.8.dfsg-2ubuntu4]

The individual items have to be split into package name and version. Currently apt and yum based systems are supported.

## Frontend

### Display packages of a machine

If a machine has contents in its software field, a new tab named "Software" shows up in the
detailed view of a machine.

### Search for packages

When selecting "Software" in the top menu bar, a search field is displayed.
To query the IDB for machines with a particular software configuration the following
search syntax is used: 

	NAME=VERSION NAME=VERSION NAME=VERSION ...

Currently only conjunction is supported for multiple search terms. All terms must match.

The `=VERSION` part can be omitted if any version should match. `VERSION` can also
be a prefix, `1.2` matches any version starting with `1.2`.
