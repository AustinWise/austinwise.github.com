---
name: smart-os-home-server
layout: post
title: SmartOS Home Server
time: 2013-03-10 18:00:00 -08:00
---

I am no longer satisfied with Windows Home Server and have decided to replace it with SmartOS.  WHS’s Drive Extender does offer some data check-summing and redundancy.  However it is a bolt-on solution to NTFS that only offers support for mirroring data across disks.  Dive Extender also moves data between disks every hour which causes media streaming to noticeably skip.

I had a few requirements for my new home server operating system:
  * Has a file system that ensures data integrity – not just metadata integrity.
  * Ability to run Windows in a VM (so I don’t have to maintain a separate physical server for running Windows apps)

# My SmartOS configuration

Setting up SmartOS as a home server proved challenging. I need to expose the files on the server to windows clients.  On a conventional Solaris-based operating system you would type `zfs set sharesmb=on zones/shares` and you would be done.  However SmartOS does not persist /etc between reboots.  This prevents adding users or using idmap to record what windows users map to which unix users.  Also sharesmb does not work on a delegated filesystem inside of a zone.

The solution was to run Samba inside the zone.  I decided to create my shared folders in a dataset outside of the zone’s dataset and used [LOFS](https://illumos.org/man/7FS/lofs) to map the folders into any zones that needed them.  This allows me to delete zones without worrying about losing data and for many zones. For example I can map a subset of files into a zone as readonly and then share them over HTTP.  If I mess up my HTTP configuration the files are safe from getting deleted or modified.

# Alterative file systems considered

I considered three file systems for my new server: ZFS, Btrfs , and ReFS (with Storage Spaces).  All of these file systems are have checksumming of all data and meta data.  They all use copy-on-write so that the contents on disk is always consistent.  They all pool your physical hard disks into a single pool of storage that you can easily carve into filesystems.

Ultimately I decided to go with ZFS.  Both Btrfs and ReFS are relatively new compared to ZFS and thus have not had time to mature like ZFS has.  ReFS’s closed-source nature was a strike against it, as I like being able to understand how my file system works.

ZFS is not without downsides.  ZFS requires devices in a mirror or RAID configuration to be the same size, while Btrs and Storage Spaces allow mixed size drives.  Btrs and ReFS also support making their storage pools smaller by removing a device, unlike ZFS.  In college and high school I slowly built my server’s capacity one hard drive at a time and would not have been able to use ZFS.  However now I can do ~capacity planning~ and just get all the hard drives up front.  So despite these limitations ZFS is now my best option.

## Alternative ZFS implementations
A plethora of operating systems support ZFS.  I tried a number before settling on SmartOS.

### FreeNAS, NAS4Free, and Nexenta

If I did not have the requirement to run VMs, I would have probably choosen FreeNAS.  Its web-based GUI made setting up the file system and windows file sharing very easy. Like SmartOS it can be booted off of a USB thumb drive, which allows all the disks in the system to be dedicated to storing data.  Ultimatly I decided against FreeNAS and NAS4Free because I was not able to get VM’s working on them.  Also I did not use Nexenta because I did not want to have to rely on them to continue to publish a free edition of their closed-source product.

###Other Illumos distributions

SmartOS has a few advantages over other Illumos operating systems like OmniOS and OpenIndiana.  It boots off a USB, allowing all disks in the system to be used for data.  This USB booting strategy also makes OS upgrades as simple as rebooting the server.  Its tools vmadm and imgadm make setting up virtual machines really simple.  I had the least trouble getting Windows running a virtual machine.
