using System;
using System.Reflection;
using System.Reflection.Emit;

namespace CsharpVsClr
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

    public class MySubClass : MyBaseClass, IHasName
    {
        string IHasName.Name
        {
            get { return base.Name; }
        }
    }
}
