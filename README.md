
Scenarios
=========

 o Test a release of a maven plugin


   What to do?

 * Download the source-package + sha1 package
 * calculate sha1 checksum
 * check calculate against downloaded sha1 package
 * Unpackage downloaded source-package
 * Run mvn -Prun-its clean verfiy ony it.
   * Serveral combinations Maven versions and JDK's
   * safe log files from running (target/it/ ?)
   
