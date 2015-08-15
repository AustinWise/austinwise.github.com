---
name: spooky-csharp-at-a-distance
title: CSharp Vs. CLR
layout: post
time: 2015-08-15 18:00:00 -08:00
tags:
- draft
---

### TL;DR

While it is easy to think of the CSharp and the Common Language Runtime (CLR) as
one cohesive unit, there are difference between the semantics of the CLR and the
semantics of the Common Type System (CTS) in the CLR. The way in which the CSharp
compiler goes about implementing it's semantics on top of the CTS are observable
and may be surprising. Specifically, the act of creating a sub class can change
the definition of the base class.

### The long story

At work my [robot][Robot] runs on the .NET Compact Framework while clients access
it using the regular Windows verion of .NET. Since the .NET Compact Framework lacks
remoting, I have implemented my RPC system. On the client side I'm using the new
[DynamicProxy] from [CoreFX] to impelement the client proxy.

I wanted to have a base class define some members of an interface without
implmenting the interface. Then the generated proxy class would implement this
interface and use the existing methods to fullfill the interface contract, exactly
as you can when writing a class in C#. However the [CreateType] method was throwing
an `System.TypeLoadException` exception with the error complaining that the method
"does not have an implementation". I was able to fix this by marking the relevent
members are `virtual`, however I was not able to reproduce the exception in my
simple test program:

{% highlight csharp linenos %}
using System;
using System.Reflection;
using System.Reflection.Emit;

class Program
{
    static void Main(string[] args)
    {
        var asm = AppDomain.CurrentDomain.DefineDynamicAssembly(new AssemblyName("testasm"), AssemblyBuilderAccess.Run);
        var mod = asm.DefineDynamicModule("testmod");
        var tb = mod.DefineType("MyGeneratedType", TypeAttributes.Public, typeof(MyBaseClass));
        tb.AddInterfaceImplementation(typeof(IHasName));
        var instance = (IHasName)Activator.CreateInstance(tb.CreateType());
        Console.WriteLine(instance.Name);
    }
}

public interface IHasName
{
    string Name { get; }
}
public class MyBaseClass
{
    public string Name { get { return "Inigo Montoya"; } }
}
public class MySubClass : MyBaseClass, IHasName { }

{% endhighlight %}

In this little program, I have a base class `MyBaseClass` that has the implemention
of interface `IHasName`, but does not actually implement it. Using two different
methods I create a subclass of `MyBaseClas` that implements `IHasName`:

  * Create `MySubClass` using CSharp.
  * Create `MyGeneratedType` using `System.Reflection.Emit`.

The `System.Reflection.Emit` method appeared to work in the same way as the CSharp
version until I commented-out the definition of `MySubClass` on line 26. Oddly the
existence of this sub class effected an the ability for an unrelated generated class
to implement the interface!

### What's going on here?

I decided to take a look at the IL of my test program without the subclass and
with the sub class. Below is the relevant portion of the diff between the two:

{% highlight diff %}
--- a/no_subclass.il
+++ b/subclass_exists.il
@@ -128,7 +128,7 @@
 .class public auto ansi beforefieldinit MyBaseClass
        extends [mscorlib]System.Object
 {
-  .method public hidebysig specialname
+  .method public hidebysig newslot specialname virtual final
           instance string get_Name() cil managed
   {
     // Code size       11 (0xb)
{% endhighlight %}

By adding the sub class, the member on the base class is now marked as `newslot`,
`virtual`, and `final`. The `newslot` and `virtual` keywords make this method
appear in the V-Table so that it can take part in dynamic dispatch, but the `final`
keyword makes the member respect the CSharp code's wish to make this member non-overrideable.
These contradictory attributes are reminiscent of how a static class in C# is
implemented by marking the class as both `sealed` and `abstract`.

### Cross Assembly Inheritence

After seeing how the CSharp compiler implements interfaces on non-virtual methods
when both the base class and sub class live in the same assembly, the obvious question
to ask is how this works when the base class is in a different assembly. Surely
the other assembly is not modified, yet this scenario works. The code that the
CSharp compiler generates in this case is roughly equivalent to explicitly
implementing the interface and forwarding the call to the base class:

{% highlight csharp %}
public class MySubClass : MyBaseClass, IHasName
{
    string IHasName.Name
    {
        get { return base.Name; }
    }
}
{% endhighlight %}

I saw "roughly equivalent" because there is a small difference between code generated
by the compiler and what you are able to express using C#. The above code generates
both a property called `Name` and a method called `get_Name`. If you leave it up
to the C# compiler however, you get only the method named `get_Name`.

### Why do I care?

These sort of details effect you if you are creating code-generating tools that
directly generate .NET Classes and Microsoft Intermediate Langauge (MSIL) without
going through a C# compiler. You have to be aware of the division of responsibility
between the C# compiler and the CLR when trying to emulate the sysmantics of C#
with your code generator. In my case, I made the simplifying rule that all
member on the base class have to be marked as virtual. This is easy to verify
with automated testing and frees me from having to generate stub functions to
emulate the C# behavior.

[Robot]: http://www.brooks.com/products/semiconductor-automation/factory-automation/spartan-sorters
[DynamicProxy]: https://github.com/dotnet/corefx/tree/0987afcd536743bf3a5cf868b3598e898f4aea53/src/System.Reflection.DispatchProxy
[CoreFx]: https://github.com/dotnet/corefx
[CreateType]: https://msdn.microsoft.com/en-us/library/system.reflection.emit.typebuilder.createtype.aspx
[IlSpy]: http://ilspy.net/















