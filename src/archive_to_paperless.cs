#!/usr/local/share/dotnet/dotnet
using System;
using System.IO;

string outputFile = System.IO.Path.GetTempPath() + "Schnellaktion_log.txt";

void AppendLog(string message)
{
    message = $"{DateTime.Now.ToString("s")} - {message}";

    System.Console.WriteLine(message);
    using (var writer = new StreamWriter(outputFile, append: true))
    {
        writer.WriteLine(message);
    }
}
System.Console.WriteLine($"Logging to {outputFile}");

if (args.Length == 0)
{
    AppendLog("No arguments provided.\n");
    return 1;
}

var archivePath = "/Users/pmario/Local/archived";
var NASDropPath = "/Volumes/dropfolders/paperless";

if (!Directory.Exists(NASDropPath))
{
    AppendLog($"NAS drop path not found:  {NASDropPath}\n");
    return 1;
}

foreach (var arg in args)
{
    if (!File.Exists(arg))
    {
        AppendLog($"File not found:  {arg}\n");
        continue;
    }
    try
    {
        var fileName = Path.GetFileName(arg);
        var destPath = Path.Combine(NASDropPath, fileName);

        File.Copy(arg, destPath);

        var archiveDestPath = Path.Combine(archivePath, fileName);
        File.Move(arg, archiveDestPath);        
    }
    catch (System.Exception ex)
    {
        var sb = new System.Text.StringBuilder();
        sb.AppendLine($"Error processing file:  {arg}");
        sb.AppendLine($"   {ex}");

        AppendLog(sb.ToString());
    }
}
return 0;