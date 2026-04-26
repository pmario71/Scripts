// to publish, use `cp archive_to_paperless.cs /Users/pmario/Local/tools/archive_to_paperless.cs`

using System;
using System.IO;
using System.IO.Abstractions;

internal class Program
{
    internal const string ArchivePath = "/Users/pmario/Local/archived";
    internal const string NASDropPath = "/Volumes/dropfolders/paperless";
    // const string NASDropMount = "//contrib@truenas._smb._tcp.local/dropfolders";
    
    internal static int Main(string[] args)
    {
        IFileSystem fs = new FileSystem();
        

        if (args.Length == 0)
        {
            Console.Error.WriteLine("No arguments provided.\n");
            PrintHelp();
            return 1;
        }

        if (args.Length == 1 && (args[0] == "--help" || args[0] == "-h"))
        {
            PrintHelp();
            return 0;
        }

        if (!fs.Directory.Exists(NASDropPath))
        {
            Console.Error.WriteLine($"NAS drop path not mounted / found:  {NASDropPath}\n");
            return 1;
        }

        int result = 0;
        foreach (var arg in args)
        {
            // string ext = Path.GetExtension(arg);
            // if (string.Compare(ext, ".pdf", StringComparison.OrdinalIgnoreCase) != 0)
            // {
            //     Console.WriteLine($"Ignoring extension: {ext}");
            //     continue;
            // }

            if (!fs.File.Exists(arg))
            {
                Console.Error.WriteLine($"File not found:  {arg}\n");
                continue;
            }
            try
            {
                ProcessFile(fs, arg);
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
    }

    private static void PrintHelp()
    {
        Console.WriteLine("Usage: archive_to_paperless <file1> [file2 ...]");
        Console.WriteLine("Copies files to the NAS drop folder and archives them locally.");
        Console.WriteLine();
        Console.WriteLine("Arguments:");
        Console.WriteLine("  <file1> [file2 ...]   One or more files to process.");
        Console.WriteLine();
        Console.WriteLine("Options:");
        Console.WriteLine("  -h, --help            Show this help message and exit.");
        Console.WriteLine();
        Console.WriteLine($"NAS Drop Path: {NASDropPath}");
        Console.WriteLine($"Archive Path:  {ArchivePath}");
    }

    internal static FileResult ProcessFile(IFileSystem fs, string arg)
    {
        var fileName = fs.Path.GetFileName(arg);
        var destPath = fs.Path.Combine(NASDropPath, fileName);
        
        FileResult result = FileResult.Success;

        if (!fs.File.Exists(destPath))
        {
            fs.File.Copy(arg, destPath);
        }
        else
        {
            result = FileResult.AlreadyArchived;
        }
        
        var archiveDestPath = fs.Path.Combine(ArchivePath, fileName);
        if (fs.File.Exists(archiveDestPath))
        {
            if (fs.File.GetLastWriteTimeUtc(archiveDestPath) == fs.File.GetLastWriteTimeUtc(arg))
            {
                Console.WriteLine($"File: {fileName}  already archived!");
                result = FileResult.AlreadyArchived;
            }
            else
            {
                Console.WriteLine($"File: {fileName}  already archived, but different write times!");
                result = FileResult.AlreadyArchivedWarning;
            }
        }
        else
        {
            fs.File.Move(arg, archiveDestPath);
        }
        return result;
    }
}

internal enum FileResult
{
    Success,
    Failure,
    AlreadyArchived,
    AlreadyArchivedWarning
}