#!/usr/local/share/dotnet/dotnet

// to publish, use `cp archive_to_paperless.cs /Users/pmario/Local/tools/archive_to_paperless.cs`

using System;
using System.IO;

if (args.Length == 0)
{
    Console.Error.WriteLine("No arguments provided.\n");
    return 1;
}

const string archivePath = "/Users/pmario/Local/archived";
const string NASDropPath = "/Volumes/dropfolders/paperless";
// const string NASDropMount = "//contrib@truenas._smb._tcp.local/dropfolders";

if (!Directory.Exists(NASDropPath))
{
    Console.Error.WriteLine($"NAS drop path not mounted / found:  {NASDropPath}\n");
    return 1;
}

int result = 0;
foreach (var arg in args)
{
    string ext = Path.GetExtension(arg);
    if (string.Compare(ext, ".pdf", StringComparison.OrdinalIgnoreCase) != 0)
    {
        Console.WriteLine($"Ignoring extension: {ext}");
        continue;
    }

    if (!File.Exists(arg))
    {
        Console.Error.WriteLine($"File not found:  {arg}\n");
        continue;
    }
    try
    {
        var fileName = Path.GetFileName(arg);
        var destPath = Path.Combine(NASDropPath, fileName);

        if (!File.Exists(destPath))
        {
            File.Copy(arg, destPath);
        }

        var archiveDestPath = Path.Combine(archivePath, fileName);
        if (File.Exists(archiveDestPath))
        {
            if (File.GetLastWriteTimeUtc(archiveDestPath) == File.GetLastWriteTimeUtc(arg))
                Console.WriteLine($"File: {fileName}  already archived!");
            else
                Console.WriteLine($"File: {fileName}  already archived, but different write times!");
        }
        else
        {
            File.Move(arg, archiveDestPath);
        }
    }
    catch (Exception ex)
    {
        string msg = $"Error processing file:  {arg}  / {ex.Message}";
        Console.Error.WriteLine(msg);

        var dest = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
        dest = Path.Combine(dest, "script_error.txt");
        File.AppendText(msg);
        result = -1;
    }
}

Console.WriteLine("SUCCESS!");
return result;