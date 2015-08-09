Changelog
=========

0.0.8
-----

* Add a default command for rake files.
* Show the yaml files being read (in order of precedence - files at the bottom overwrite settings above them).
* All yaml files are now evaluated and used.


0.0.7
-----

* Load the yaml contents on every invocation.


0.0.4
-----

* Allow the use of normal files as well as named pipes (see readme for details).
* Move caching of commands to plugin code instead of ruby code.
	This simplifies both pieces of code.
* Add Params object to parse and validate params.
