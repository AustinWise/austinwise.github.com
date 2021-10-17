---
layout: post
title: Debugging emulation nesting dolls
time: 2019-01-01 00:00:00 -08:00
is_draft: true 
---

In a [previous post][OldPost] I talked about how SmartOS was great in part because it allows you
run native Linux applications using LX-branded zones. One challenge when running software in a
virtualized is it increases the number of interfaces between software systems where one side can
get something wrong. This post will explore one such case.

To recap, illumos supports [OS-level virtualization][OsVirt]. This concept is broadly know as "containers", illumos calls
this absraction zones. A unqie feature of illumos zones it the ability to dine a "brand" for the zone.
A [brand][man_brands] customizes the behavior of the zone. One simple use for a brand is to change
what privileges a zone has by default and what devices are available under /dev[^1], to create a stronger sandbox.
But zones can go much futher in distorting the reality they presnt to the processes running within them. Zones
also have the ability to redefine the [system call table][syscal] the operating system exposes to
processes. This powerful feature[^2] allows SmartOS to emulate Linux using [lx zones][man_lx]. This
feature allows you run applications that were originally compiled for Linux on SmartOS, without
modification. Checkout the SmartOS wiki for [a guide on using lx-zones][lxguide] [^3].

## .NET on Windows on Linux on SmartOS

For my own purposes, having the ability to run linux programs on illumos means I can
run my .NET applications on illumos. This is quite handy: I can get the operational benefits of
running on illumos while getting the breadth of application compatibility by running any Linux application.

If we look closer at what is going on within the .NET CoreCLR, it is up to it's
own to it's own emulation games. There is a lower of software called the PAL:
Platform Abstraction Layer. This layer provides a subset of the Windows API,
implemented in terms of underlying Linux platform.

When you put the CoreCLR's PAL layer together with illumos LX Zones emulation
layer, you have a tower of emulation.

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

In fairness to the CoreCLR, most of the PAL is not in fast path of executing .NET
programs. The PAL contains functions relating to loading shared libraries or
handling exceptions. There has also been work recently for decreasing the size of
the PAL by moving functionality to C# (see
[#42476](https://github.com/dotnet/runtime/commit/220bf9714248cca8ef18cb4175ae83b1cf210a70)
and
[#47321](https://github.com/dotnet/runtime/commit/e8f09edc676d7415c77b06259e0fdbfbdaea9763)
for some recent examples
). But still this abstraction layer persists, because different operating systems
handle the same thing differently.

## Why care about layers?

Everyone is happy as long as all these layers of abstraction continue to work.
However once something starts to go wrong, the layers make it harder to identify
a root cause. At any point in the stack of layers something could go wrong. When
something goes wrong, you often times have to inspect several layers to find
the true cause.

<!--
TODO: the above point is somewhat tempered by the below statement that we could
quick rule out a program in the Linux-Windows PAL interface by just testing on
regular Linux. So there are some tools that can help like "run on Linux".
 -->

# What actually went wrong that cause you to write such a long-winded blog post?

The bad behavior I initially observed was this: when I clicked the "login" button
on my website, the .NET process would segfault. This problem did not occur on
Windows or Linux hosts. So that pointed at a problem in illumos.

The initial crashing test case included all of ASP.NET MVC. After repeated
reducing the size of this test case, I ended up with a small C# program that
[performed a null reference dereference](https://github.com/AustinWise/CrashRepro/blob/master/csharp/Program.cs)
twice in a row.

### TODO: some ideas on the way forward for this blogpost

* Check out where what handles a null pointer difference in CoreCLR (SEH on windows, SIGSEV handler on Linux (Mach exception port on masOS?))
* How to investigate the crash? (Attach a debugger, place a data breakpoint on the data structure that is being read in the crash)
  * something about how the signal was raised repeatedly, observable with the LX Debug probs?
* How to determine that the variations in alternate stack behavior was the cause for signal handlers smashing stack memory.

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
