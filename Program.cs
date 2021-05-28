using System;
using System.Threading.Tasks;
using Statiq.App;
using Statiq.Web;

namespace MyWebsite
{
    class Program
    {
        public static async Task<int> Main(string[] args)
        {
            Environment.CurrentDirectory = @"D:\src\austinwise.github.com\";
            int ret = await Bootstrapper
                 .Factory
                 .CreateWeb(args)
                 .RunAsync();
            return ret;
        }
    }
}
