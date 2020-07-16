---
page_title: "Nebula"
---

[![Build Status](https://git.bink.com/DevOps/Cookbooks/nebula/badges/master/pipeline.svg)](https://git.bink.com/DevOps/Cookbooks/nebula)

## Hardening

The nebula cookbook performs generic Ubuntu hardening based on the CIS guidelines. The cookbook specifically ignores the CIS networking section as those tweaks cause instability when operating Kubernetes as well as being less relevant when operating in a cloud envrionment.

The OpenSSH server config is also hardened, the config is rather verbose including defaults purely so that we can use tools like Inspec to validate the setup.

### CIS Hardening

Here are the controls from the Ubuntu 18.04 CIS benchmark. Any controls relating to network configuration has been purposefuly ignored as they can interfer with Kubernetes networking and are less useful when operating in a cloud envrionment. The same goes for controls referencing early boot, partitions as in a cloud environment we have no control over this. Password controls are also ignored as we operate systems without the need for passwords as sudo is govened by OTP and login uses ED25519 SSH keys.

| Control ID   | Control                                                                                | Y / N | Notes                                                         |
|--------------|----------------------------------------------------------------------------------------|-------|---------------------------------------------------------------|
| 1.1.1.1      | Ensure mounting of cramfs filesystems is disabled                                      | Y     |                                                               |
| 1.1.1.2      | Ensure mounting of freevxfs filesystems is disabled                                    | Y     |                                                               |
| 1.1.1.3      | Ensure mounting of jffs2 filesystems is disabled                                       | Y     |                                                               |
| 1.1.1.4      | Ensure mounting of hfs filesystems is disabled                                         | Y     |                                                               |
| 1.1.1.5      | Ensure mounting of hfsplus filesystems is disabled                                     | Y     |                                                               |
| 1.1.1.6      | Ensure mounting of squashfs filesystems is disabled                                    | Y     |                                                               |
| 1.1.1.7      | Ensure mounting of udf filesystems is disabled                                         | Y     |                                                               |
| 1.1.1.8      | Ensure mounting of FAT filesystems is limited (Not Scored)                             | N     | Cannot disable, using UEFI                                    |
| 1.1.2        | Ensure /tmp is configured                                                              | Y     |                                                               |
| 1.1.3        | Ensure nodev option set on /tmp partition                                              | Y     |                                                               |
| 1.1.4        | Ensure nosuid option set on /tmp partition                                             | Y     |                                                               |
| 1.1.5        | Ensure noexec option set on /tmp partition                                             | Y     |                                                               |
| 1.1.6        | Ensure separate partition exists for /var                                              | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.7        | Ensure separate partition exists for /var/tmp                                          | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.8        | Ensure nodev option set on /var/tmp partition                                          | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.9        | Ensure nosuid option set on /var/tmp partition                                         | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.10       | Ensure noexec option set on /var/tmp partition                                         | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.11       | Ensure separate partition exists for /var/log                                          | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.12       | Ensure separate partition exists for /var/log/audit                                    | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.13       | Ensure separate partition exists for /home                                             | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.14       | Ensure nodev option set on /home partition                                             | N/A   | Not using separate partitions, using a cloud image            |
| 1.1.15       | Ensure nodev option set on /dev/shm partition                                          | Y     |                                                               |
| 1.1.16       | Ensure nosuid option set on /dev/shm partition                                         | Y     |                                                               |
| 1.1.17       | Ensure noexec option set on /dev/shm partition                                         | Y     |                                                               |
| 1.1.18       | Ensure nodev option set on removable media partitions (Not Scored)                     | N/A   | Cloud instance, not possible                                  |
| 1.1.19       | Ensure nosuid option set on removable media partitions (Not Scored)                    | N/A   | Cloud instance, not possible                                  |
| 1.1.20       | Ensure noexec option set on removable media partitions (Not Scored)                    | N/A   | Cloud instance, not possible                                  |
| 1.1.21       | Ensure sticky bit is set on all world-writable directories                             | Y     |                                                               |
| 1.1.22       | Disable Automounting                                                                   | Y     |                                                               |
| 1.1.23       | Disable USB Storage                                                                    | N/A   | Cloud instance, not possible                                  |
| 1.2.1        | Ensure package manager repositories are configured (Not Scored)                        | Y     |                                                               |
| 1.2.2        | Ensure GPG keys are configured (Not Scored)                                            | Y     |                                                               |
| 1.3.1        | Ensure sudo is installed                                                               | Y     |                                                               |
| 1.3.2        | Ensure sudo commands use pty                                                           | Y     |                                                               |
| 1.3.3        | Ensure sudo log file exists                                                            | Y     |                                                               |
| 1.4.1        | Ensure AIDE is installed                                                               | N     | Will be solved by AquaSecurity                                |
| 1.4.2        | Ensure filesystem integrity is regularly checked                                       | N     | Will be solved by AquaSecurity                                |
| 1.5.1        | Ensure permissions on bootloader config are configured                                 | Y     |                                                               |
| 1.5.2        | Ensure bootloader password is set                                                      | N/A   | Cloud instance, not possible                                  |
| 1.5.3        | Ensure authentication required for single user mode                                    | N/A   | Cloud instance, not possible                                  |
| 1.5.4        | Ensure interactive boot is not enabled (Not Scored)                                    | Y     |                                                               |
| 1.6.1        | Ensure XD/NX support is enabled                                                        | Y     |                                                               |
| 1.6.2        | Ensure address space layout randomization (ASLR) is enabled                            | Y     |                                                               |
| 1.6.3        | Ensure prelink is disabled                                                             | Y     |                                                               |
| 1.6.4        | Ensure core dumps are restricted                                                       | Y     |                                                               |
| 1.7.1.1      | Ensure AppArmor is installed                                                           | Y     |                                                               |
| 1.7.1.2      | Ensure AppArmor is enabled in the bootloader configuration                             | N     | Not implemented as would impact Kubernetes stability          |
| 1.7.1.3      | Ensure all AppArmor Profiles are in enforce or complain mode                           | N     | Not implemented as would impact Kubernetes stability          |
| 1.7.1.4      | Ensure all AppArmor Profiles are enforcing                                             | N     | Not implemented as would impact Kubernetes stability          |
| 1.8.1.1      | Ensure message of the day is configured properly                                       | N     | Not implemented as would impact Kubernetes stability          |
| 1.8.1.2      | Ensure local login warning banner is configured properly                               | Y     |                                                               |
| 1.8.1.3      | Ensure remote login warning banner is configured properly                              | Y     |                                                               |
| 1.8.1.4      | Ensure permissions on /etc/motd are configured                                         | Y     |                                                               |
| 1.8.1.5      | Ensure permissions on /etc/issue are configured                                        | Y     |                                                               |
| 1.8.1.6      | Ensure permissions on /etc/issue.net are configured                                    | Y     |                                                               |
| 1.8.2        | Ensure GDM login banner isconfigured                                                   | N/A   |                                                               |
| 1.9          | Ensure updates, patches, and additional security software are installed (Not Scored)   | Y     |                                                               |
| 2.1.1        | Ensure xinetd is not installed                                                         | Y     |                                                               |
| 2.1.2        | Ensure openbsd-inetd is not installed                                                  | Y     |                                                               |
| 2.2.1.1      | Ensure time synchronization is in use                                                  | Y     |                                                               |
| 2.2.1.2      | Ensure systemd-timesyncd is configured (Not Scored)                                    | Y     |                                                               |
| 2.2.1.3      | Ensure chrony is configured                                                            | N     | As systemd-timesyncd is in use                                |
| 2.2.1.4      | Ensure ntp is configured                                                               | N     | As systemd-timesyncd is in use                                |
| 2.2.2        | Ensure X Window System is not installed                                                | Y     |                                                               |
| 2.2.3        | Ensure Avahi Server is not enabled                                                     | Y     |                                                               |
| 2.2.4        | Ensure CUPS is not enabled                                                             | Y     |                                                               |
| 2.2.5        | Ensure DHCP Server is not enabled                                                      | Y     |                                                               |
| 2.2.6        | Ensure LDAP server is not enabled                                                      | Y     |                                                               |
| 2.2.7        | Ensure NFS and RPC are not enabled                                                     | Y     |                                                               |
| 2.2.8        | Ensure DNS Server is not enabled                                                       | Y     |                                                               |
| 2.2.9        | Ensure FTP Server is not enabled                                                       | Y     |                                                               |
| 2.2.10       | Ensure HTTP server is not enabled                                                      | Y     |                                                               |
| 2.2.11       | Ensure email services are not enabled                                                  | Y     |                                                               |
| 2.2.12       | Ensure Samba is not enabled                                                            | Y     |                                                               |
| 2.2.13       | Ensure HTTP Proxy Server is not enabled                                                | Y     |                                                               |
| 2.2.14       | Ensure SNMP Server is not enabled                                                      | Y     |                                                               |
| 2.2.15       | Ensure mail transfer agent is configured for local-only mode                           | Y     |                                                               |
| 2.2.16       | Ensure rsync service is not enabled                                                    | Y     |                                                               |
| 2.2.17       | Ensure NIS Server is not enabled                                                       | Y     |                                                               |
| 2.3.1        | Ensure NIS Client is not installed                                                     | Y     |                                                               |
| 2.3.2        | Ensure rshclient is not installed                                                      | Y     |                                                               |
| 2.3.3        | Ensure talk client is not installed                                                    | Y     |                                                               |
| 2.3.4        | Ensure telnet client is not installed                                                  | Y     |                                                               |
| 2.3.5        | Ensure LDAP client is not installed                                                    | Y     |                                                               |
| 3.1.1        | Ensure packet redirect sending is disabled                                             | N     | Not implemented as would impact Kubernetes stability          |
| 3.1.2        | Ensure IP forwarding is disabled                                                       | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.1        | Ensure source routed packets are not accepted                                          | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.2        | Ensure ICMP redirects are not accepted                                                 | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.3        | Ensure secure ICMP redirects are not accepted                                          | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.4        | Ensure suspicious packets are logged                                                   | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.5        | Ensure broadcast ICMP requests are ignored                                             | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.6        | Ensure bogus ICMP responses are ignored                                                | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.7        | Ensure Reverse Path Filtering is enabled                                               | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.8        | Ensure TCP SYN Cookies is enabled                                                      | N     | Not implemented as would impact Kubernetes stability          |
| 3.2.9        | Ensure IPv6 router advertisements are not accepted                                     | N     | Not implemented as would impact Kubernetes stability          |
| 3.3.1        | Ensure TCP Wrappers is installed (Not Scored)                                          | N     | Not implemented as would impact Kubernetes stability          |
| 3.3.2        | Ensure /etc/hosts.allow is configured (Not Scored)                                     | N     | Not implemented as would impact Kubernetes stability          |
| 3.3.3        | Ensure /etc/hosts.deny is configured (Not Scored)                                      | N     | Not implemented as would impact Kubernetes stability          |
| 3.3.4        | Ensure permissions on /etc/hosts.allow are configured                                  | Y     |                                                               |
| 3.3.5        | Ensure permissions on /etc/hosts.deny are configured                                   | Y     |                                                               |
| 3.4.1        | Ensure DCCP is disabled                                                                | Y     |                                                               |
| 3.4.2        | Ensure SCTP is disabled                                                                | Y     |                                                               |
| 3.4.3        | Ensure RDS is disabled                                                                 | Y     |                                                               |
| 3.4.4        | Ensure TIPC is disabled                                                                | Y     |                                                               |
| 3.5.1.1      | Ensure a Firewall package is installed                                                 | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.2.1      | Ensure ufw service is enabled                                                          | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.2.2      | Ensure default deny firewall policy                                                    | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.2.3      | Ensure loopback traffic is configured                                                  | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.2.4      | Ensure outbound connections are configured (Not Scored)                                | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.2.5      | Ensure firewall rules exist for all open ports (Not Scored)                            | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.1      | Ensure iptables are flushed (Not Scored)                                               | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.2      | Ensure a table exists                                                                  | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.3      | Ensure base chains exist                                                               | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.4      | Ensure loopback traffic is configured                                                  | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.5      | Ensure outbound and established connectionsare configured (Not Scored)                 | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.6      | Ensure default deny firewall policy                                                    | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.7      | Ensure nftables service is enabled                                                     | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.3.8      | Ensure nftables rules are permanent                                                    | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.1.1    | Ensure default deny firewall policy                                                    | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.1.2    | Ensure loopback traffic is configured                                                  | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.1.3    | Ensure outbound and established connections are configured (Not Scored)                | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.1.4    | Ensure firewall rules existfor all open ports                                          | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.2.1    | Ensure IPv6 default deny firewall policy                                               | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.2.2    | Ensure IPv6 loopback traffic is configured                                             | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.2.3    | Ensure IPv6 outbound and established connections are configured (Not Scored)           | N     | Not implemented as would impact Kubernetes stability          |
| 3.5.4.2.4    | Ensure IPv6 firewall rules exist for all open ports (Not Scored)                       | N     | Not implemented as would impact Kubernetes stability          |
| 3.6          | Ensure wireless interfaces are disabled                                                | Y     |                                                               |
| 3.7          | Disable IPv6 (Not Scored)                                                              | N     | Not implemented as would impact Kubernetes stability          |
| 4.1.1.1      | Ensure auditd is installed                                                             | Y     |                                                               |
| 4.1.1.2      | Ensure auditd service is enabled                                                       | Y     |                                                               |
| 4.1.1.3      | Ensure auditing for processes that start prior to auditd is enabled                    | Y     |                                                               |
| 4.1.1.4      | Ensure audit_backlog_limit is sufficient                                               | Y     |                                                               |
| 4.1.2.1      | Ensure audit log storage size is configured                                            | Y     |                                                               |
| 4.1.2.2      | Ensure audit logs are not automatically deleted                                        | N     | Blocked until we ship hosts logs                              |
| 4.1.2.3      | Ensure system is disabledwhen audit logs are full                                      | N     | Not acceptable to enable in a containerised envrionment       |
| 4.1.3        | Ensure events that modify date and time information are collected                      | N     | DEVOPS-755                                                    |
| 4.1.4        | Ensure events that modify user/group information are collected                         | N     | DEVOPS-755                                                    |
| 4.1.5        | Ensure events that modify the system's network environment are collected               | N     | DEVOPS-755                                                    |
| 4.1.6        | Ensure events that modify the system's Mandatory Access Controls are collected         | N     | DEVOPS-755                                                    |
| 4.1.7        | Ensure login and logout events are collected                                           | N     | DEVOPS-755                                                    |
| 4.1.8        | Ensure session initiation information iscollected                                      | N     | DEVOPS-755                                                    |
| 4.1.9        | Ensure discretionary access control permission modification events are collected       | N     | DEVOPS-755                                                    |
| 4.1.10       | Ensure unsuccessful unauthorized file access attempts are collected                    | N     | DEVOPS-755                                                    |
| 4.1.11       | Ensure use of privileged commands is collected                                         | N     | DEVOPS-755                                                    |
| 4.1.12       | Ensure successful file system mounts are collected                                     | N     | DEVOPS-755                                                    |
| 4.1.13       | Ensure file deletion events by users are collected                                     | N     | DEVOPS-755                                                    |
| 4.1.14       | Ensure changes to system administration scope (sudoers) is collected                   | N     | DEVOPS-755                                                    |
| 4.1.15       | Ensure system administrator actions (sudolog) are collected                            | N     | DEVOPS-755                                                    |
| 4.1.16       | Ensure kernel module loading and unloading is collected                                | N     | DEVOPS-755                                                    |
| 4.1.17       | Ensure the audit configuration is immutable                                            | N     | Not implemented as configuration management will enforce this |
| 4.2.1.1      | Ensure rsyslog is installed                                                            | Y     |                                                               |
| 4.2.1.2      | Ensure rsyslog Service is enabled                                                      | Y     |                                                               |
| 4.2.1.3      | Ensure logging is configured (Not Scored)                                              | Y     |                                                               |
| 4.2.1.4      | Ensure rsyslog default file permissions configured                                     | Y     |                                                               |
| 4.2.1.5      | Ensure rsyslog is configured to send logs to a remote log host                         | Y     |                                                               |
| 4.2.1.6      | Ensure remote rsyslog messages are only accepted on designated log hosts. (Not Scored) | N/A   | Not relevant                                                  |
| 4.2.2.1      | Ensure journald is configured to send logs to rsyslog                                  | N     | DEVOPS-756                                                    |
| 4.2.2.2      | Ensure journald is configured to compress large log files                              | N     | DEVOPS-756                                                    |
| 4.2.2.3      | Ensure journald is configured to write logfiles to persistent disk                     | N     | DEVOPS-756                                                    |
| 4.2.3        | Ensure permissions on all logfiles are configured                                      | Y     |                                                               |
| 4.3          | Ensure logrotate is configured (Not Scored)                                            | Y     |                                                               |
| 5.1.1        | Ensure cron daemon is enabled                                                          | Y     |                                                               |
| 5.1.2        | Ensure permissions on /etc/crontab are configured                                      | Y     |                                                               |
| 5.1.3        | Ensure permissions on /etc/cron.hourly are configured                                  | Y     |                                                               |
| 5.1.4        | Ensure permissions on /etc/cron.daily are configured                                   | Y     |                                                               |
| 5.1.5        | Ensure permissions on /etc/cron.weekly are configured                                  | Y     |                                                               |
| 5.1.6        | Ensure permissions on /etc/cron.monthly are configured                                 | Y     |                                                               |
| 5.1.7        | Ensure permissions on /etc/cron.d are configured                                       | Y     |                                                               |
| 5.1.8        | Ensure at/cron is restricted to authorized users                                       | Y     |                                                               |
| 5.2.1        | Ensure permissions on /etc/ssh/sshd_config are configured                              | Y     |                                                               |
| 5.2.2        | Ensure permissions on SSH private host key files are configured                        | Y     |                                                               |
| 5.2.3        | Ensure permissions on SSH public host key files are configured                         | Y     |                                                               |
| 5.2.4        | Ensure SSH Protocol is not set to 1                                                    | Y     |                                                               |
| 5.2.5        | Ensure SSH LogLevel is appropriate                                                     | Y     |                                                               |
| 5.2.6        | Ensure SSH X11 forwarding is disabled                                                  | Y     |                                                               |
| 5.2.7        | Ensure SSH MaxAuthTries is set to 4 or less                                            | Y     |                                                               |
| 5.2.8        | Ensure SSH IgnoreRhosts is enabled                                                     | Y     |                                                               |
| 5.2.9        | Ensure SSH HostbasedAuthentication is disabled                                         | Y     |                                                               |
| 5.2.10       | Ensure SSH root login is disabled                                                      | Y     |                                                               |
| 5.2.11       | Ensure SSH PermitEmptyPasswords is disabled                                            | Y     |                                                               |
| 5.2.12       | Ensure SSH PermitUserEnvironment is disabled                                           | Y     |                                                               |
| 5.2.13       | Ensure only strong Ciphers areused                                                     | Y     |                                                               |
| 5.2.14       | Ensure only strong MAC algorithms are used                                             | Y     |                                                               |
| 5.2.15       | Ensure only strong Key Exchange algorithms are used                                    | Y     |                                                               |
| 5.2.16       | Ensure SSH Idle Timeout Interval is configured                                         | Y     |                                                               |
| 5.2.17       | Ensure SSH LoginGraceTime is set to one minute or less                                 | Y     |                                                               |
| 5.2.18       | Ensure SSH access is limited                                                           | Y     |                                                               |
| 5.2.19       | Ensure SSH warning banner is configured                                                | Y     |                                                               |
| 5.2.20       | Ensure SSH PAM is enabled                                                              | Y     |                                                               |
| 5.2.21       | Ensure SSH AllowTcpForwarding is disabled                                              | Y     |                                                               |
| 5.2.22       | Ensure SSH MaxStartups is configured                                                   | Y     |                                                               |
| 5.2.23       | Ensure SSH MaxSessions is set to 4 or less                                             | Y     |                                                               |
| 5.3.1        | Ensure password creation requirements are configured                                   | N/A   | Passwords are not used                                        |
| 5.3.2        | Ensure lockout for failed password attempts is configured                              | N/A   | Passwords are not used                                        |
| 5.3.3        | Ensure password reuse is limited                                                       | N/A   | Passwords are not used                                        |
| 5.3.4        | Ensure password hashing algorithm is SHA-512                                           | N/A   | Passwords are not used                                        |
| 5.4.1.1      | Ensure password expiration is 365 days or less                                         | N/A   | Passwords are not used                                        |
| 5.4.1.2      | Ensure minimum days between password changes is  configured                            | N/A   | Passwords are not used                                        |
| 5.4.1.3      | Ensure password expiration warning days is 7 or more                                   | N/A   | Passwords are not used                                        |
| 5.4.1.4      | Ensure inactive password lock is 30days or less                                        | N/A   | Passwords are not used                                        |
| 5.4.1.5      | Ensure all users last password change date is in the past                              | N/A   | Passwords are not used                                        |
| 5.4.2        | Ensure system accounts are secured                                                     | Y     |                                                               |
| 5.4.3        | Ensure default group for the root account is GID 0                                     | Y     |                                                               |
| 5.4.4        | Ensure default user umask is 027 or more restrictive                                   | Y     |                                                               |
| 5.4.5        | Ensure default user shell timeout is 900 seconds or less                               | Y     |                                                               |
| 5.5          | Ensure root login is restricted to system console (Not Scored)                         | Y     |                                                               |
| 5.6          | Ensure access to the su command is restricted                                          | Y     |                                                               |
| 6.1.1        | Audit system file permissions (Not Scored)                                             | Y     |                                                               |
| 6.1.2        | Ensure permissions on /etc/passwd are configured                                       | Y     |                                                               |
| 6.1.3        | Ensure permissions on /etc/gshadow-are configured                                      | Y     |                                                               |
| 6.1.4        | Ensure permissions on /etc/shadow are configured                                       | Y     |                                                               |
| 6.1.5        | Ensure permissions on /etc/group are configured                                        | Y     |                                                               |
| 6.1.6        | Ensure permissions on /etc/passwd-are configured                                       | Y     |                                                               |
| 6.1.7        | Ensure permissions on /etc/shadow-are configured                                       | Y     |                                                               |
| 6.1.8        | Ensure permissions on /etc/group-are configured                                        | Y     |                                                               |
| 6.1.9        | Ensure permissions on /etc/gshadow are configured                                      | Y     |                                                               |
| 6.1.10       | Ensure no world writable files exist                                                   | N/A   | Literally not enforcable                                      |
| 6.1.11       | Ensure no unowned files or directories exist                                           | N     | Docker volumes makes this infeasible                          |
| 6.1.12       | Ensure no ungrouped files or directories exist                                         | N     | Docker volumes makes this infeasible                          |
| 6.1.13       | Audit SUID executables (Not Scored)                                                    | N     | DEVOPS-755                                                    |
| 6.1.14       | Audit SGID executables (Not Scored)                                                    | N     | DEVOPS-755                                                    |
| 6.2.1        | Ensure password fields are not empty                                                   | N/A   | Passwords are not used                                        |
| 6.2.2        | Ensure no legacy "+" entries exist in /etc/passwd                                      | N/A   | Passwords are not used                                        |
| 6.2.3        | Ensure all users' home directories exist                                               | Y     |                                                               |
| 6.2.4        | Ensure no legacy "+" entries exist in /etc/shadow                                      | N/A   | Passwords are not used                                        |
| 6.2.5        | Ensure no legacy "+" entries exist in /etc/group                                       | N/A   | Passwords are not used                                        |
| 6.2.6        | Ensure root is the only UID 0 account                                                  | Y     |                                                               |
| 6.2.7        | Ensure root PATH Integrity                                                             | Y     |                                                               |
| 6.2.8        | Ensure users' home directories permissions are 750 or more restrictive                 | Y     |                                                               |
| 6.2.9        | Ensure users own their home directories                                                | Y     |                                                               |
| 6.2.10       | Ensure users' dot files are not group or world writable                                | Y     |                                                               |
| 6.2.11       | Ensure no users have .forward files                                                    | Y     |                                                               |
| 6.2.12       | Ensure no users have .netrc files                                                      | Y     |                                                               |
| 6.2.13       | Ensure users' .netrc Files are not group or world accessible                           | Y     |                                                               |
| 6.2.14       | Ensure no users have .rhosts files                                                     | Y     |                                                               |
| 6.2.15       | Ensure all groups in /etc/passwd exist in /etc/group                                   | Y     |                                                               |
| 6.2.16       | Ensure no duplicate UIDs exist                                                         | Y     |                                                               |
| 6.2.17       | Ensure no duplicateGIDs exist                                                          | Y     |                                                               |


## Verification

This cookbook installs Inspec with a Python 3.5 runner script which runs Inspec, collected the JSON output, simpiflies the results and then submits to Elasticsearch. This runs daily at 4AM configured by a systemd timer `inspec.timer` and `inspec.service`.

A base Inspec profile is deployed (look in `./files/base`) which is an Inspec YAML file declaring dependencies and Inspec controls which currently only trigger the depenencies to run (just declaring dependencies will not actually trigger them to run). Currently the Python shim will only run the baseline profile, but it will eventually be updated to run all profiles in a directory (it seems at the moment Inspec needs to be provided a list of profiles to run).

The [Linux baseline](https://github.com/dev-sec/linux-baseline) and [SSH baseline](https://github.com/dev-sec/ssh-baseline) Inspec profiles are pulled from their respective GitHub repositories and ran againt the host system, various controls have been skipped for the reasons discussed above.

### Inspec result format

The JSON document below will be sent to elasticsearch for each profile ran against the host, currently they will be `linux-baseline` and `ssh-baseline`. The document is a summary of the profile run, with the aim of making a Grafana compliance dashboard easier. These documents will appear under the `inspec-summary-YYYY-MM-DD` indicies.
```json
{
    "@timestamp": "2020-07-09T11:38:24Z",
    "inspec_profile": "linux-baseline",
    "host": "C02CCHDGMD6M",
    "ip": "127.0.0.1",
    "success_percentange": 0.99
}
```

Inspec results are more verbose and repeated for every inspec control that passed or failed. These documents combined with the summaries should provide enough data in Elasticsearch to allow a Grafana dashboard to drill down into results and display some sane information. These documents will appear under the `inspec-results-YYYY-MM-DD` indicies.
```json
{
    "control_id": "os-05",
    "control_title": "Check login.defs",
    "status": "passed",
    "@timestamp": "2020-07-09T16:01:26+00:00",
    "name": "linux-baseline",
    "title": "DevSec Linux Security Baseline",
    "version": "2.4.5",
    "host": "bastion",
    "ip": "192.168.4.4"
}
```

## Cookbook Updates

Currently the cookbook pulls version `4.21.3-1` of Inspec. Whilst there is not a direct need to keep this up to date, it would make sense to check this biannually. 
