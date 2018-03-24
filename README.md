Maven Release Checker
=====================

Currently this is an approach to have a script based 
checking which will check the release packages with
several JDKs and Maven versions in combination.

Scenarios
---------

 o Test a release of a maven plugin


   What to do?

 * Download the source-package + sha1 package (done).
 * calculate sha1 checksum (done).
 * check calculate against downloaded sha1 package (done).
 * Unpackage downloaded source-package (done).
 * Run mvn -Prun-its clean verfiy ony it.
   * Serveral combinations Maven versions and JDK's
   * safe log files from running (target/it/ ?)


Configuration
 * Define the command to be used for testing like "mvn -Prun-its clean verfiy"
   or "mvn clean verify"
 * Run in separated environments separated local cache (via command line)
 * Make the run parallel ?

Make a maven tool of it:
 * Using of toolchains for different JDK's.
 * 
