---
layout: post.liquid
title: "Adding a new feature to CoreCLR: BindingFlags.DoNotWrapException"
published_date: 2018-04-25 00:00:00 -08:00
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

# Background

If you have ever used reflection in .NET to invoke a method, you probably have
dealt with [TargetInvocationException].
Whenever an exception is thrown as the result of invoking a method with
reflection, it is wrapped in a [TargetInvocationException]. Any exception-handling
logic downstream of the reflection invocation callsite has to add a
`catch (TargetInvocationException ex)` and duplicate their logic to handle the
`InnerException` property of `ex`.

There are a few workarounds for this wrapping behavior that I am aware
of. One is to simply wrap the reflection invocation location and have it rethrow
the `InnerException` of the `TargetInvocationException`. However, this loses the
call stack information when you rethrow an exception. The more modern version
of this strategy is using `ExceptionDispatchInfo` to capture the inner exception
and rethrow it, but it would be nice if one did not have to catch the exception
in the first place.

# The Interface

Last August, while perusing the commit log of CoreCLR, I noticed that
Microsoft's [Atsushi Kanamori][Kanamori] merged [a pull request][OP_PR]
to CoreCLR[^1] that added an intriguing enumeration value to [BindingFlags]:
`DoNotWrapExceptions`:

```diff
[Flags]
public enum BindingFlags
{
+     DoNotWrapExceptions = 0x02000000, // Disables wrapping exceptions in TargetInvocationException
}
```

The linked [design review][DesignReview] showed an example of how using the new
flag would prevent exceptions from being wrapped in `TargetInvocationException`:

```csharp
public class Program
{
	public static void Main()
	{
		try {
			var bf = BindingFlags.Static |
                            BindingFlags.Public |
                            BindingFlags.InvokeMethod;

            //The new flag
            bf |= BindingFlags.DoNotWrapExceptions;

			typeof(Program).InvokeMember("LateBoundTarget", bf, null, null, null);

		} catch(TargetInvocationException) {
			Console.WriteLine("catches before the new flag");

		} catch(InvalidOperationException) {
			Console.WriteLine("catches after the new flag");
		}
	}

	public static void LateBoundTarget() {
		throw new InvalidOperationException();
	}
}
```

This looks like a handy way to avoid dealing with the
`TargetInvocationException`. There was only one problem with this new flag: it
was as of yet unimplemented.

# The Implementation

If you have ever peeked and poked around `mscorlib` using [IlSpy] or the like
before .NET Core was open source, or if you have looked at that source of
`System.Private.CoreLib` after the open sourcing, you have undoubtedly had your
exploration end at method that looks like this just as things were getting
interesting:

```csharp
[MethodImpl(MethodImplOptions.InternalCall)]
public static extern void FailFast(string message);
```

These methods are called FCalls and are documented in the
[Book of the Runtime][BOTR]. They allow C# code to call directly into the C++
code of the CLR.

While a lot of the reflection systems is now[^2] written in C#, the final
invocation of the method happens in C++. This is also where exceptions thrown
during the reflection invocation are caught and wrapped in
`TargetInvocationException`.

The [implementation of this feature][Commit] was relatively simple: find the
places in reflection that wrap, and just make them not do that. In this
simplified example, it was just a matter of adding a path that does not wrap
the method invoke in a TRY-CATCH block:

```diff
+    bool fExceptionThrown = false;
+    if (fWrapExceptions)
+    {
-        bool fExceptionThrown = false;
         EX_TRY_THREAD(pThread) {
             CallDescrWorkerReflectionWrapper(&callDescrData, &catchFrame);
         } EX_CATCH{
             // Abuse retval to store the exception object
             gc.retVal = GET_THROWABLE();

             fExceptionThrown = true;
         } EX_END_CATCH(SwallowAllExceptions);
+    }
+    else
+    {
+        CallDescrWorkerWithHandler(&callDescrData);
+    }
```

In one case the wrapping happened in C#. In this case it was pretty to use C# 6's
exception filters to make the wrapping conditional:

```diff
                         try
                         {
                             ace.m_ctor(instance);
                         }
-                        catch (Exception e)
+                        catch (Exception e) when (wrapExceptions)
                         {
                             throw new TargetInvocationException(e);
                         }
```

# Conclusion

You can try out this new feature in the [.NET Core 2.1 preview][Preview].
It should ship shortly in the final .NET Core 2.1 release.
Since implementing this feature in CoreCLR, Microsoft's Atsushi has
[implemented it in CoreRT][CoreRT_PR] and I have also implemented it in
[Mono][]. [Hopefully][Framework] the .NET Framework will also gain this flag
and thus make it possible to include this feature in a future version of
.NET standard.

# Acknowledgements

Thanks to [Caspar Hansen][Caspar] for reviewing drafts of this.

# Footnotes

[^1]: The linked pull request is to the CoreRT repository, however that part of
      repo is synced with CoreCLR automatically.

[^2]: In .NET Framework 1.0, pretty much all of reflection was implemented using
      `FCalls`. I can't recall exactly when, but it was either .NET 1.1 or 2.0
	  where they reimplemented much of reflection in C#. At the time, this was
	  claimed to be a big performance boost. The reduction of the use of FCalls
	  continues in CoreCLR. CoreRT represents an existence proof how little C++
	  code you can write when implementing a .NET runtime, but this is the
	  subject of a future blog post, not a foot note.

[TargetInvocationException]: https://docs.microsoft.com/en-us/dotnet/api/system.reflection.targetinvocationexception
[CreateDelegate]: https://docs.microsoft.com/en-us/dotnet/api/system.reflection.methodinfo.createdelegate
[ProxyBug]: https://github.com/dotnet/corefx/pull/19181
[IlSpy]: https://github.com/icsharpcode/ILSpy
[DesignReview]: https://github.com/dotnet/corefx/issues/22866
[BindingFlags]: https://docs.microsoft.com/en-us/dotnet/api/system.reflection.bindingflags
[Kanamori]: https://github.com/AtsushiKan
[OP_PR]: https://github.com/dotnet/corert/pull/4433
[MY_PR]: https://github.com/dotnet/coreclr/pull/13767
[BOTR]: https://github.com/dotnet/runtime/blob/master/docs/design/coreclr/botr/corelib.md
[Commit]: https://github.com/dotnet/coreclr/commit/1f9aeeb7a3685bc7fd1098fc50d91ac81bae4873
[Mono]: https://github.com/mono/mono/pull/7863
[Framework]: https://github.com/Microsoft/dotnet/issues/717
[Preview]: https://blogs.msdn.microsoft.com/dotnet/2018/02/27/announcing-net-core-2-1-preview-1/
[CoreRT_PR]: https://github.com/dotnet/corert/pull/4437
[Caspar]: http://casparhansen.blogspot.com/
