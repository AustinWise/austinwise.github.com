---
layout: post.liquid
title: The Container-Native Home Server
published_date: 2018-06-05 01:00:00 -0800
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

# Background

In my [2013 post][OldPost] I described my decision to use [SmartOS][] on my
home server. It continues to serve me well, so I thought I would write up home
running the different roles of my home server in containers works.

# Server configuration

I keep all my media files like music, ISO disk images, and videos in ZFS filesystems under /zones/shares/.
I have home directories for various users under /zones/home/. By having different ZFS datasets
for different types of data, I can improve performance. For example, I can use a larger blocksize
on `/zones/shares/videos` to minimize metadata overhead while using smaller block sizes
on `/zones/shares/torrents` to match Bittorent's block size, eliminating read-modify-write cycles.

I used [LoFS][] to map
these directories into various zones I create. Different zones have different subsets of
filesystems mapped into them. Some zones only have read only views. For example,
the zone running Plex has a read-only view of `/zones/shares/videos` while the Transmission
zone has a read-write view of `/zones/shares/torrents`. This least privilege approach to file
system access limits the impact of security intrusions or operator errors.

## Containers I'm running

I currently keep the `vmadm` scripts and setup shell scripts for each zone in [a Git repo][Config].
Someday I plan to use a proper configuration management system, but this works well enough for now.

* dns: runs `dnsmasq` so containers can locate each other by name
* fs: runs Samba so windows clients can access files
* torrent: runs Transmission to download and upload files over Bittorent
* dkp: runs my [DKP][] website, using ASP.NET Core on LX
* nginx: proxies traffic to DKP
* postgresql: runs PostgreSQL, mostly for DKP
* plex: Runs a Plex server
* devl: Used for software development and testing

# What I like about SmartOS

## Easy to upgrade

Upgrading the operating system is as easy as writing a new image to the USB thumb drive
and rebooting. To roll back, I just write the old image on the USB thumb drive and reboot.
I run each application on the server in a separate zone so I can update
the zones one at a time without worrying about effecting the other applications on the system.

## Run anything in containers

At the time I wrote my [old post][OldPost], the only types of containers supported were
the pkgsrc-based SmartMachine containers and the hardware virtualization KVM containers.
While pkgsrc covered a lot of use cases, some things like PS3 Media Server were difficult to
set up.

Since then, Joyent has added Linux-emulating LX container support. These containers are able to
run almost any Linux program. I use these types of containers to run Plex and .NET Core. This
addition allowed me to finally delete the Windows Server virtual machine and run all applications
in lightweight operating-system-provided containers.

## Easy backup

zsnapper constantly creates ZFS snapshots on a hourly, daily, weekly, and monthly basis.
My desktop computers are configured to frequently `rsync` their data files to
`/zones/shares/backup`. This means my server has snapshots of all my large media files
and my personal files. Using the scripts in the `usbdrive` folder of my [Config][] repository,
once a month I use `zfs send` to copy the past month's changes to a USB thumb drive. I then transport
these snapshots physically to an offsite location where I `zfs receive` the snapshots
into a backup server. Compared to backing up all of these files on something like S3, this has a much lower
monthly cost. Additionally, it would be difficult to do the initial multiple-terabyte upload if only for
lame 1TB Comcast-imposed datacap.

## NFS

Recently I decided to try to migrate off Windows. There are a number of reasons, but they are
outside the scope of this blog post.

Now that I've been using Ubuntu, I've been able to take advantage of the NFS server built into
SmartOS. With a simple `zfs set sharenfs=on zones/shares/` on SmartOS and setting my user and group
IDs to match on Ubuntu, I can now seamlessly access all my server's files from desktop.
While there are currently no security controls, it's my private network so for the moment I don't care.

[OldPost]: /2013/03/10/smartos-home-server.html
[SmartOS]: https://joyent.com/smartos
[Config]:  https://www.github.com/AustinWise/ServerConfiga
[LoFS]:    https://smartos.org/man/7FS/lofs
[DKP]:     https://www.github.com/AustinWise/DinnerKillPoints
