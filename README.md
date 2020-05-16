# Windows-Event-Forwarding
Windows Event Forwarding Lab

This lab will walk throught building three Windows Server 2016 VMs build on Virtual Box.

Managament IP | Service IP | Service FQDN    | Role        | OS

192.168.1.111 | 10.0.0.111 | WINDC1.hq.corp  | WEF Lab DC  | Windows 2016

192.168.1.112 | 10.0.0.112 | WINMS1.hq.corp  | WEF Lab MS  | Windows 2016

192.168.1.113 | 10.0.0.113 | WINWEC1.hq.corp | WEF Lab WEC | Windows 2016



Managament will be from to following workstation.

Managament IP | Service IP | Service FQDN | Role | OS

192.168.1.180 | NONE       | pdasi124786  | Managament | Windows 10



This is additional infrastructure thats already created.

Managament IP | Service IP | Service FQDN      | Role | OS

192.168.1.10  | 10.0.0.10  | YUM0001.hq.corp   | YUM  | CentOS 7

192.168.1.11  | 10.0.0.11  | DNS0001.hq.corp   | DNS  | CentOS 7

192.168.1.101 | 10.0.0.101 | KAFKA0001.hq.corp | KAFKA | CentOS 7

192.168.1.102 | 10.0.0.102 | KAFKA0002.hq.corp | KAFKA | CentOS 7

192.168.1.103 | 10.0.0.103 | KAFKA0003.hq.corp | KAFKA | CentOS 7
