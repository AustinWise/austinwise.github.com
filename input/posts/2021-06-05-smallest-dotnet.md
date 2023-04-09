---
layout: post.liquid
title: Smallest .NET Hello World
published_date: 2021-06-05 15:45:00 -0700
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
description: |
      An investigation into the size overhead of different ways of deploying .NET
      applications.
---

I started an
[investigation](https://github.com/AustinWise/SmallestDotnetHelloWorlds)
of the on-disk size of different ways of deploying .NET applications exactly
two years ago today.
Since I just mentioned in a footnote in [my previous post](/2021/05/31/cobalt.html)
about the size of .NET core, I thought it would be a good time to write up my findings.

### .NET Framework

First let's start with the classic .NET Framework. We are going to count the size
of the application only. This is sort of cheating, as the
[installer for .NET 4.8](https://dotnet.microsoft.com/download/dotnet-framework/thank-you/net48-offline-installer)
is 116MB. But it's a good bet it's already installed on user's computers, as all
supported versions of Windows 10 already include .NET 4.8[^1]. And there
[won't be another major version of .NET Framework](https://devblogs.microsoft.com/dotnet/net-core-is-the-future-of-net/).

If you do [File -> New Project in Visual Studio](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/1.VisualStudioProjectNew)
the resulting EXE is 4.5 KB. Not bad. You can [cut that down to 2.5 KB](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/2.VisualStudioTrimmed)
by deleting some of the attributes that Visual Studio includes by default and by
setting the target architecture to X64. When you target X64, the compiler
does not include the [_CorExeMain stub](https://www.red-gate.com/simple-talk/blogs/anatomy-of-a-net-assembly-the-clr-loader-stub/).
Not including the stub means you also not include the relocations directory,
the import directory, and the `.reloc` section of the Portable Executable (PE) file.

To get to 1 KB, you have to [drop down to MSIL](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/3.IlAsm).
This enables a couple of optimizations:

* We can remove all attributes. By default the C# compiler includes some like `TargetFrameworkAttribute`.
* We can remove the `.rscs` section of the PE file by not including the version information resource.

It's small enough that we can easily annotate the different parts of the [PE file](https://docs.microsoft.com/windows/win32/debug/pe-format).

![](/images/smallest-dotnet/PE.png)

Because of the minimum of 512 byte file alignment, shrinking this further would
not result in a smaller on-disk file. If you are interested in how far an PE file
can be shrunk, [see this article](http://www.phreedom.org/research/tinype/) by
Alexander Sotirov.

### .NET Core

When deploying apps built on .NET Core or .NET 5 and later, we have more [options for deployment](https://docs.microsoft.com/dotnet/core/deploying/).
We can create a "framework-dependent" application the relies on a globally installed
version of the .NET Core runtime. This is similar to how .NET Framework apps are deployed.
We also have the option of creating a "self-contained" app that includes the entire
.NET Core runtime with the application. This allows you to ship an application with
the exact version of .NET you tested with, at the cost of increase application size.

Testing with .NET 6 preview 4, a [framework dependent app is 155 KB](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/4.DotNetCoreNew).
This bloat relative to a .NET Framework app comes from the native code App Host .exe file.
This App Host exe will find the installed version of .NET Core and run the application.
If you [exclude the app host](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/4.1.NoAppHost)
you can get the deployed size down to 14.5 KB, but you will have to run the application
using the `dotnet` command:

```
dotnet app.dll arg1 args2 ...
```

When you deploy as ["self-contained"](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/5.SelfContained),
the size balloons to 64 MB. This is because the entire .NET Core runtime is included
with the published application. There are a lot of options for getting this file
size down and this is were it gets complicated.

You can start by making a [single file application](https://docs.microsoft.com/en-us/dotnet/core/deploying/single-file).
When you make a "self-contained" single file application for .NET 6 on Windows,
it includes all the native and managed components of the .NET Core runtime in
a single file that runs without extracting any temporary files. .NET 5 supported
this for Linux and macOS. The native components are all statically linked together
and includes simplified hosting components[^2], so the size is smaller at 58 MB.

If you use trimming to remove code your application does not need to execute, we
can greatly cut down the size. Our hello world application does not need XML or
JSON support, so by enabling [trimming](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/7.SingleFileTrimmed),
we get down to 11 MB. We can [compressing](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/7.1.SingleFileTrimmedCompressed)
the files inside the single file bundle. While this is smaller, I assume it may
not start up as fast and may take more memory[^3]. Probably the version you would
actually deploy is trimmed and ahead of time compiled using Ready to Run.
[This version](https://github.com/AustinWise/SmallestDotnetHelloWorlds/tree/master/8.SingleFileTrimmedR2R)
is 13MB.

~10 MB for Hello World is a little fat. Comparing to Go's 2MB for Hello World makes
it look less bad. Compared to a 182 MB Electron hello world app, it looks great.

### Native AOT

To get smaller, we will have to use the experimental [Native AOT](https://github.com/dotnet/runtimelab/tree/feature/NativeAOT)
version of CoreCLR. This version of .NET compiles everything to native code at
build time. Following the
[instructions on how to build a Hello World](https://github.com/dotnet/runtimelab/blob/feature/NativeAOT/samples/HelloWorld/README.md)
app, we get a 4MB executable. By adding some [optimization options to disable reflection and i18n](https://github.com/dotnet/runtimelab/blob/feature/NativeAOT/docs/using-nativeaot/optimizing.md)
we get a 1MB executable.

To go much below 1MB, see [Michal Strehovský](https://twitter.com/MStrehovsky)'s
[zerosharp](https://github.com/MichalStrehovsky/zerosharp). By taking out everything
you would normally consider to be part of .NET, including the GC, exceptions, and
type-casting, you can get down to ~5KB. This is not a practical environment to
write C# in, but it's interesting to see the possibilities of the Native AOT
experiment.

### Conclusion

There are many options for deploying .NET apps available today and more may be possible
in the future. While the single file, self-contained option in .NET 6 is a little big,
you get the advantage of controlling the exact version of .NET you are shipping to
your users. It is the option I would use[^4] for distributing .NET 6 apps.

#### Footnotes

[^1]: .NET 4.8 was first [shipped](https://devblogs.microsoft.com/dotnet/announcing-the-net-framework-4-8/)
      Windows 10 1903. At time of writing, the [oldest supported version of Windows](https://en.wikipedia.org/wiki/Windows_10_version_history#Channels)
      is 1909. This is not counting Long Term Support Channel versions.

[^2]: You can see [in the source code for the static app host](https://github.com/dotnet/runtime/blob/41af30ca291e0435083c0d4b5d70e2939e0dbc3d/src/native/corehost/apphost/static/CMakeLists.txt#L42-L48)
      that it includes some of the contents of `hostfxr` and `hostpolicy`, which
      are normally separate shared libraries. Some other components for debugging
      are missing. See the [documentation](https://docs.microsoft.com/dotnet/core/deploying/single-file)
      for details.

[^3]: See the notes on this [pull request](https://github.com/dotnet/runtime/pull/50817).
      Depending on the operating system, some extra copying of memory is required
      compared to non-compressed single file bundles.

[^4]: That does mean self-contained single file apps are the right choice for your
      use case. The [Microsoft documentation](https://docs.microsoft.com/dotnet/core/deploying/)
      goes into detail about tradeoffs between different options.