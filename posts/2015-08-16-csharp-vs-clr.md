---
title: C# vs. CLR
layout: post.liquid
published_date: 2015-08-16 00:26:00 -08:00
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

### Summary

While it is easy to think of the C# and the Common Language Runtime (CLR) as
one cohesive unit, there are difference between the semantics of the CLR and the
semantics of the Common Type System (CTS) in the CLR. The way in which the C#
compiler implements its semantics on top of the CTS are observable
and may be surprising. Specifically, the act of creating a sub class can change
the definition of the base class.

### The long story

The SDK for my work [robot][Robot] implments its own RPC system to talk to the
embedded controller. The interface we expose is a proxy built on top of the
`RealProxy` and `TransparentProxy` classes from .NET remoting. I decided to
switch these proxies to be built on top of the [DynamicProxy] from [CoreFX].

One of the reasons I made this change was to allow some methods of the class to
be implemented on the client side. The idea is that a base class of the proxy can implement
just the methods from an interface it wants to execute locally. The generated proxy
subclass will fill in all the methods the base class did not define and complete the
implemention of the interface. In C#, it's perfectly valid to have a subclass implement an
interface in this way, even if the methods on the base class are not `virtual`.
However, the [CreateType] method on `TypeBuilder` was throwing
an `System.TypeLoadException` exception, with the error complaining that the method
"does not have an implementation". I was able to fix this by marking the relevent
members are `virtual`, however, I was not able to reproduce the exception in my
simple test program:

```c#
using System;
using System.Reflection;
using System.Reflection.Emit;

class Program
{
    static void Main(string[] args)
    {
        var asm = AppDomain.CurrentDomain.DefineDynamicAssembly(
            new AssemblyName("testasm"), AssemblyBuilderAccess.Run);
        var mod = asm.DefineDynamicModule("testmod");
        var tb = mod.DefineType("MyGeneratedType",
            TypeAttributes.Public, typeof(MyBaseClass));
        tb.AddInterfaceImplementation(typeof(IHasName));
        var instance = (IHasName)Activator.CreateInstance(
            tb.CreateType());
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
```

In this little program, I have a class `MyBaseClass` that has the implemention
of interface `IHasName`, but does not actually implement it. Also note that the
`Name` property is not marked as virtual. This program creates two subclasses of
`MyBaseClass` that implement `IHasName`:

  * `MySubClass` is created using C#.
  * `MyGeneratedType` is created using `System.Reflection.Emit`.

The `System.Reflection.Emit` method appeared to work in the same way as the C#
version - until I commented out the definition of `MySubClass` on line 26. Oddly, the
existence of this sub class determined whether or not the generated subclass was
able to implement the interface!

### What's going on here?

Obviously, the C# compiler was doing more than I expected. To find out what it was
doing, I compiled the program twice, once with the subclass and once without. I
then used `ILDasm` to dump the Microsoft Intermediate Langauge (MSIL) represention
of the programs and diffed them. Below is the relevant portion of the diff
between the two:

```diff
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
```

By adding the sub class, the member on the base class is now marked as `newslot`,
`virtual`, and `final`. The `newslot` and `virtual` keywords make this method
appear in the V-Table so that it can take part in dynamic dispatch, but the `final`
keyword makes the member respect the C# code's wish to make this member non-overrideable.
These contradictory attributes are reminiscent of how a static class in C# is
implemented by marking the class as both `sealed` and `abstract`.

### Cross Assembly Inheritence

After seeing how the C# compiler implements interfaces on non-virtual methods
when both the base class and sub class live in the same assembly, the obvious question
to ask is how this works when the base class is in a different assembly. Surely
the other assembly is not modified, yet this scenario works. The code that the
C# compiler generates in this case is roughly equivalent to explicitly
implementing the interface and forwarding the call to the base class:

```c#
public class MySubClass : MyBaseClass, IHasName
{
    string IHasName.Name
    {
        get { return base.Name; }
    }
}
```

I say "roughly equivalent" because there is a small difference between code generated
by the compiler and what you are able to express using C#. The above code generates
both a property called `Name` and a method called `get_Name`. If you leave it up
to the C# compiler, however, you get only the method named `get_Name`.

### Why do I care?

These sort of details affect you if you are creating code-generating tools that
directly generate .NET Classes and MSIL without
going through a C# compiler. You have to be aware of the division of responsibility
between the C# compiler and the CLR when trying to emulate the semantics of C#
with your code generator. In my case, I simplified things by making a rule that all
members on the base class have to be marked as virtual. This is easy to verify
with automated testing and frees me from having to generate stub functions to
emulate the C# behavior.


### Acknowledgements

Thanks to [Caspar] for reviewing drafts of this post.

[Robot]: https://www.brooks.com/products/semiconductor-automation/factory-automation/spartan-sorters
[DynamicProxy]: https://github.com/dotnet/corefx/tree/0987afcd536743bf3a5cf868b3598e898f4aea53/src/System.Reflection.DispatchProxy
[CoreFx]: https://github.com/dotnet/corefx
[CreateType]: https://docs.microsoft.com/dotnet/api/system.reflection.emit.typebuilder.createtype
[Caspar]: https://github.com/CasparHansen
