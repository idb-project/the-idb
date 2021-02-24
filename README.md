[![Build Status](https://travis-ci.org/idb-project/the-idb.svg?branch=develop)](https://travis-ci.org/idb-project/the-idb)

# the idb

Once upon a time we used spreadsheets and wiki pages to 
document our server landscape. Then the age of working 
together, more people joined the team and it became 
tedious to maintain all those wiki pages.

And we thought, why not keep to the principle of:

Automate all boring things!

And the idb - the infrastructure database core application -
was created.

## What this really is

This is a rails based web application known as 'idb-core', that
is fed by various 'adapters' to corelate information for
machines, inventory-items, networks and such.
You can find various idb adapters within the github organization:

https://github.com/idb-project

## It all began with puppet and puppetdb

The primary adapter for gathering informations has been PuppetDB.
That's the reason why - unlike other adapters - the PuppetDB adapter is
bundled directly within the idb. Don't fear: the idb can be used
without puppet just fine.

## Install packages

You might find several but probably untested packages for various operating systems at https://packager.io/gh/idb-project/the-idb/refs/develop

## Contact to the team

Either contact us through github or use team AT the-idb.org.


## Commercial support

While the idb is an open source project, there is commercial support available
from the fine folks at [bytemine](https://www.bytemine.net/). They offer 
the idb packaged for various platforms and these come with support and services.
(Disclaimer: currently all people working on the idb are employed by bytemine)

