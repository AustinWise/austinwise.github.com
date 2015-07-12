---
name: spooky-csharp-at-a-distance
title: Werid CSharp
layout: post
time: 2015-07-12 18:00:00 -08:00
tags:
- draft
---

It is not every day you discover a new corner of a language you have been working with for over 10 years. This past week however I discovered that the act of declaring a new class can change the attributes of a base class’s member in an observable way. Since you never would expect the act of inheriting from class to change the inherited class, I am too giddy with excitement to not share with the world.

{% highlight csharp linenos %}
using System;
using System.Reflection;
using System.Reflection.Emit;

namespace ConsoleApplication2808
{
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
}
{% endhighlight %}
