
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
        IFileSystem fileSystem = new FileSystem();
        
        if (args.Length == 0)
        {
            Console.Error.WriteLine("No arguments provided.\n");
            return 1;
        }

        if (!Directory.Exists(NASDropPath))
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

            if (!File.Exists(arg))
            {
                Console.Error.WriteLine($"File not found:  {arg}\n");
                continue;
            }
            try
            {
                ProcessFile(fileSystem, arg);
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