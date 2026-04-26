#!/usr/local/share/dotnet/dotnet
using System;
using System.IO;

void DumpArgs()
{
    foreach (var arg in args)
    {
        Console.Write($"{arg} | ");
    }
    Console.WriteLine();
}

DumpArgs();

if (args.Length == 1 && args[0].Contains("fail"))
{
    Console.Error.WriteLine("No arguments provided.\n");
    return 1;
}

Console.WriteLine("SUCCESS - everything was working!");

return 0;