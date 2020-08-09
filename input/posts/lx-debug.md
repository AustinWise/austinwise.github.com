---
layout: post
title: Debugging emulation nesting dolls
time: 2019-01-01 00:00:00 -08:00
is_draft: true 
---

In my [previous post][OldPost] I talked about how SmartOS was great in part because it allows you
run native Linux applications using LX-branded zones. One challenge when running software in a
virtualized is it increases the number of interfaces between software systems where one side can
get something wrong. This post will explore one such case.

To recap, illumos supports [OS-level virtualization][OsVirt]. Other operating systems call these containers, illumos calls
them zones. A unix feature of illumos zones it the ability different different brands for different
zones to run under. A [brand][man_brands] customizes the behavior of the zone. Brands typically change
what privileges a zone has by default and what devices are available under /dev[^1]. However they
also have the ability to redefine the [system call table][syscal] the operating system exposes to
processes. This powerful feature[^2] allows SmartOS to emulate Linux using [lx zones][man_lx]. This
feature allows you run applications that were originally compiled for Linux on SmartOS, without
modification. Checkout the SmartOS wiki for [a guide on using lx-zones][lxguide] [^3].

## .NET on Windows on Linux on SmartOS

```
       +------------+
       |.NET CoreCLR|
       +------------+
         Windows API
     +---------------+
     |   .NET PAL    |
     +---------------+
         Linux ABI
   +--------------------+
   |      LX Zones      |
   +--------------------+
         illumos ABI
+-------------------------+
|          SmartOS        |
+-------------------------+
```

[^1]: SmartOS uses these features to create the [locked-down bhyve brand][bhyv_zone] for running the
      user-mode components of hardware virtualization.
[^2]: [Windows Subsystem for Linux][wsl] version 1 and [FreeBSD's Linux emulation][freebsd_linuxemu]
      also use system call emulation.
[^3]: The [Bryan Cantrill talk][LxTalk] linked from that wikipage is also worth a watch.

[OldPost]: /2018/06/05/container-native-home-server.html
[OsVirt]: https://en.wikipedia.org/wiki/OS-level_virtualization
[man_brands]: https://smartos.org/man/5/brands
[bhyv_zone]: https://github.com/joyent/illumos-joyent/tree/master/usr/src/lib/brand/bhyve/zone
[syscall]: https://en.wikipedia.org/wiki/System_call
[man_lx]: https://smartos.org/man/5/lx
[wsl]: https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux
[freebsd_linuxemu]: https://www.freebsd.org/doc/handbook/linuxemu.html
[lxguide]: https://wiki.smartos.org/lx-branded-zones/
[LxTalk]: https://www.youtube.com/watch?v=TrfD3pC0VSs
