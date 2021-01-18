using System;
using System.Diagnostics;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        const string HOST = "www.microsoft.com";

        using var sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        await sock.ConnectAsync(HOST, 80);

        string httpReq = $"GET / HTTP/1.1\r\nHost: {HOST}\r\nConnection: Close\r\n\r\n";
        await sock.SendAsync(new ReadOnlyMemory<byte>(Encoding.ASCII.GetBytes(httpReq)), SocketFlags.None);

        bool printedStackTrace = false;
        var buff = new Memory<byte>(new byte[4096]);
        while (true)
        {
            int bytes = await sock.ReceiveAsync(buff, SocketFlags.None);
            if (!printedStackTrace)
            {
                printedStackTrace = true;
                Console.WriteLine(new StackTrace());
                Console.WriteLine();
            }
            if (bytes == 0)
                break;
            Console.WriteLine(Encoding.ASCII.GetString(buff.Span.Slice(0, bytes)));
        }
    }
}

