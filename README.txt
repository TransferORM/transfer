This is an updated version of Transfer containing a collection
of community patches.  It is believed to be the best current 
version of Transfer through Adobe ColdFusion 11 and Railo 4.  
Read the migration guide here:

https://github.com/TransferORM/transfer/wiki/Migrating-to-Transfer-1.3

It is based on the pluggable_cache branch which uses EhCache for 
storage rather than the 1.1 method of SoftReferences (which tend 
to cause memory leaks).  Upgrading from any 1.1 or 1.2 version is
encouraged, particularly if you are under any load as we worked 
around a significant ACF xmlSearch() bug in July 2014.  This version 
also upgrades to the last release of JavaLoader 1.1 from 2012.

Mark Mandel no longer develops Transfer.  If you are starting a 
new project, please use CF ORM instead.

For up to date information on Transfer, you can go to:
http://github.com/TransferORM

Support is provided on a community basis at:
https://groups.google.com/forum/#!forum/transfer-dev



Copyright 2008+, Mark Mandel
