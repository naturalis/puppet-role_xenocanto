puppet-role_xenocanto
==================

Role manifest for deploying xeno canto website

Parameters
-------------
All parameters are read from defaults in init.pp and can be overwritten by hiera or The foreman


```
 $bla = bla       ' must have
```


Classes
-------------
- role_xenocanto::conf
- role_xenocanto::web
- role_xenocanto::db

Dependencies
-------------




Result
-------------
Xeno canto webserver and / or database server.


Limitations
-------------
This module has been built on and tested against Puppet 4 and higher.

The module has been tested on:

- Ubuntu 16.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>
