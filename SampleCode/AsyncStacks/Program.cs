using System;
using System.Diagnostics;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        await F1();
        Console.WriteLine(new StackTrace());
    }

    static async Task F1()
    {
        await F2();
    }

    static async Task F2()
    {
        Console.WriteLine(new StackTrace());
        Console.WriteLine();
        await Task.Delay(1);
    }
}

