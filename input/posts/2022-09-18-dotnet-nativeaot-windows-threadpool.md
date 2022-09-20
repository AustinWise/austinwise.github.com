---
layout: post.liquid
title: The ThreadPool in .NET 7 NativeAOT uses the Windows thread pool
published_date: 2022-09-18 20:15:00 -08:00
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

Over the course of the .NET 6 and .NET 7 release, the .NET team has worked
towards converging on a common C# implementation of the thread pool. The main
threadpool, which handles scheduling work started with
`ThreadPool.QueueUserWorkItem` and `Task`, was converted to
[C# in .NET 6](https://github.com/dotnet/runtime/pull/38225). The I/O threadpool,
which is used on Windows for asynchronous I/O and
`ThreadPool.RegisterWaitForSingleObject`,
[was converted in .NET 7](https://github.com/dotnet/runtime/pull/64834).
In .NET 8 CoreCLR's C++ version of the thread pool
[will cease to exist as a fallback option](https://github.com/dotnet/runtime/pull/71719).

As of .NET 7, all dotnet platforms now have a common C# implementation of the threadpool,
save two platforms:

* Single threaded WASM
* NativeAOT on Windows

This post is about the second of those two exceptions.

Update 2022-09-19:
[Michal Strehovský](https://github.com/MichalStrehovsky/),
the software engineer on the .NET team who implemented many parts of NativeAOT
and evangelized its use over the years,
[clarifies](https://twitter.com/MStrehovsky/status/1571741674438787073)
that the future versions of .NET NativeAOT on Windows may or may not change to
use the common C# thread pool implementation. The current implementation is not
a deliberate choice, but rather the state of the codebase at the time
the ship deadline came.

### NativeAOT

NativeAOT (short for Native Ahead-of-time) is a new form factor of .NET that
precompiles to native code. This can improve startup time and binary size.
See the
[the documentation](https://learn.microsoft.com/dotnet/core/deploying/native-aot/)
for more details.

One interesting property of NativeAOT when running on Windows is it uses the
[thread pool apis that are built into Windows](https://learn.microsoft.com/windows/win32/procthread/thread-pools).
These were added in the Windows Vista, after .NET had been out for a
few years, and appear to be inspired by the .NET threadpool APIs.
So by relying on the thread pool already included in Windows,
NativeAOT apps can save a little binary size.

### Waiting for wait handles

Bench-marking the performance effects of different thread pools on overall
application performance outside the scope of this Sunday-afternoon blog post.
However there is one aspect of the threadpool that has an improved design and is
easy to write a micro benchmark for:
[`ThreadPool.RegisterWaitForSingleObject`](https://learn.microsoft.com/dotnet/api/system.threading.threadpool.registerwaitforsingleobject?view=net-7.0).

This function will trigger a callback when a wait handle is signaled or a timeout
expires. In .NET thread pool and the Windows thread pool prior to Windows 8, this
API was implemented on top of the Win32 API `WaitForMultipleObjects`.
`WaitForMultipleObjects` can wait on at most 64 items. To get around this limit,
thread pools that used `WaitForMultipleObjects` had to create 1 thread per 63
waits [^1].

Starting in Windows 8, the Windows thread pool was changed to internally [^2] use
I/O completion ports to implement the wait and no longer requires 1 thread per
63 waits. Early this year Raymond Chen wrote about this improvement to the
Windows thread pool on his
[The Old New Thing blog](https://devblogs.microsoft.com/oldnewthing/20220406-00/?p=106434).

We can write a benchmark similar to Raymond's to observe the performance
difference when using NativeAOT.

### Benchmark

The below benchmark sets up 63,000 wait handles and starts waiting them using
`ThreadPool.RegisterWaitForSingleObject`. The part that is actually measured for
the benchmark is signaling every 63rd one. So the workload being represented here
is something where you have many wait handles being waited upon and only a few
of them are being signaled.

On runtimes that don't use the Windows thread pool, this benchmark causes 1000
threads to be created. The core part of the benchmark involves waking up 1000
threads.

On NativeAOT, which uses the Windows thread pool, the process creates far
fewer than 1000 threads. There are just the I/O thread pool threads the read
I/O Completion Packets out of the completion ports and execute the callbacks.

```c#

using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Jobs;
using BenchmarkDotNet.Running;
using System.Threading;

[SimpleJob(RuntimeMoniker.Net48)]
[SimpleJob(RuntimeMoniker.Net60)]
[SimpleJob(RuntimeMoniker.Net70)]
[SimpleJob(RuntimeMoniker.NativeAot70)]
[RPlotExporter]
public class Program
{
    public static void Main(string[] args) => BenchmarkRunner.Run<Program>(null, args);

    private const int WAITS_PER_THREAD = 63;

    [Params(1000)]
    public int N;

    private AutoResetEvent[] HandlesToRegister;
    private RegisteredWaitHandle[] RegisteredWaits;
    private WaitOrTimerCallback CompleteDel;
    private AutoResetEvent AllCompleted;
    private volatile int CompleteCount;

    [GlobalSetup]
    public void GlobalSetup()
    {
        CompleteDel = new WaitOrTimerCallback(CompleteFunc);
        RegisteredWaits = new RegisteredWaitHandle[N * WAITS_PER_THREAD];
        HandlesToRegister = new AutoResetEvent[N * WAITS_PER_THREAD];
        AllCompleted = new AutoResetEvent(false);
        for (int i = 0; i < N * WAITS_PER_THREAD; i++)
        {
            HandlesToRegister[i] = new AutoResetEvent(false);
        }
        for (int i = 0; i < N * WAITS_PER_THREAD; i++)
        {
            RegisteredWaits[i] = ThreadPool.RegisterWaitForSingleObject(
                HandlesToRegister[i],
                CompleteDel,
                null,
                -1,
                executeOnlyOnce: false);
        }
    }


    [GlobalCleanup]
    public void GlobalCleanup()
    {
        foreach (var rw in RegisteredWaits)
        {
            rw.Unregister(null);
        }
        foreach (var wh in HandlesToRegister)
        {
            wh.Close();
        }
    }

    private void CompleteFunc(object state, bool timedOut)
    {
        if (Interlocked.Add(ref CompleteCount, 1) == N)
        {
            AllCompleted.Set();
        }
    }

    [Benchmark]
    public void BenchWait()
    {
        CompleteCount = 0;

        for (int i = 0; i < N; i++)
        {
            HandlesToRegister[i * WAITS_PER_THREAD].Set();
        }

        AllCompleted.WaitOne();
    }
}
```

FYI: as of time of publishing, this benchmark does not work with any published
version of [Benchmark.NET](https://benchmarkdotnet.org/). I ran against a
[pre-release version](https://github.com/dotnet/BenchmarkDotNet/tree/b525ba3d27fb4a471280256cbd9f0013c97d1281/).
0.13.3 should have
[the fix](https://github.com/dotnet/BenchmarkDotNet/pull/2095)
for running benchmark against NativeAOT.

### Performance improvement

I ran these benchmarks on a 16-core, 32-thread machine [^3]. I used .NET 7 RC1 [^4].
You can clearly see that the NativeAOT version has 2x the throughput of .NET
Framework, .NET 6, and .NET 7.


|    Method |                Job |            Runtime |    N |     Mean |     Error |    StdDev |   Median |
|---------- |------------------- |------------------- |----- |---------:|----------:|----------:|---------:|
| BenchWait | .NET Framework 4.8 | .NET Framework 4.8 | 1000 | 4.034 ms | 0.0177 ms | 0.0166 ms | 4.031 ms |
| BenchWait |           .NET 6.0 |           .NET 6.0 | 1000 | 4.093 ms | 0.0157 ms | 0.0147 ms | 4.093 ms |
| BenchWait |           .NET 7.0 |           .NET 7.0 | 1000 | 3.914 ms | 0.0091 ms | 0.0085 ms | 3.914 ms |
| BenchWait |      NativeAOT 7.0 |      NativeAOT 7.0 | 1000 | 2.060 ms | 0.0500 ms | 0.1474 ms | 2.132 ms |

![box plot](/images/windows-threadpool-wait.png)

The NativeAOT version used less memory (measured as private bytes), but in
absolute terms it was 10s of MiB. Obviously creating 1000 threads uses some
virtual memory when creating all their stacks, but that is mitigated somewhat
by .NET using a
[smaller](https://github.com/dotnet/runtime/blob/5fb45c561481cf3cbfca781ddcd8317db6a82d5d/src/libraries/System.Private.CoreLib/src/System/Threading/PortableThreadPool.WaitThread.cs#L188)
[256KiB](https://github.com/dotnet/runtime/blob/5fb45c561481cf3cbfca781ddcd8317db6a82d5d/src/libraries/System.Private.CoreLib/src/System/Threading/PortableThreadPool.cs#L17)
stack for these threads.

There is a quality of life improvement from not having to dig through 1000
threads when looking at a program in the debugger.

### Conclusion

I don't claim you should make any conclusion based on this micro benchmark other
than this: .NET 7 NativeAOT on Windows has a unique implementation of the thread
pool, so you should keep that in mind when testing your applications.

### Footnotes

[^1]: Why not 64? The last of the 64 wait handles is used by the thread pool
      implementation to wake thread so wait handles can be added or removed
      from waiting.
      [See the implementation in C#](https://github.com/dotnet/runtime/blob/5fb45c561481cf3cbfca781ddcd8317db6a82d5d/src/libraries/System.Private.CoreLib/src/System/Threading/PortableThreadPool.WaitThread.cs#L176).

[^2]: The relevant, undocumented system calls are `NtCreateWaitCompletionPacket`,
     `NtAssociateWaitCompletionPacket`, and `NtCancelWaitCompletionPacket`.

[^3]: Specifically a AMD Threadripper Pro 3955WX.

[^4]: Other software versions: Windows 11 22000.978, most recent .NET Framework
      4.8 patch, .NET 6.0.9.
