# Background

ZFS attributes are not provided by snmpd out-of-the-box. Another script is
needed to get the free/used bytes etc. One alternative is provided here:

https://github.com/FransUrbo/snmp-modules/tree/master/zfs

The major issue here is that snmpd needs to run as root to execute the commands
from the script files. On Ubuntu, snmpd normally runs as an unprivileged user
and escalating its permissions seems like a rather drastic move for us.

Other, more DIY alternatives are discussed here:

http://serverfault.com/questions/262829/how-to-monitor-zfs-with-snmp-in-freebsd

Unfortunately, the snmp_hostres.so mentioned seems FreeBSD-specific.

This approach provides a bare-bones approach, which could ostensibly be
sudo-wrapped to provide access to these commands only:

http://forums.cacti.net/viewtopic.php?f=12&t=47979

In the end, this is the approach I chose to implement.


