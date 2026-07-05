// to publish, use `cp archive_to_paperless.cs /Users/pmario/Local/tools/archive_to_paperless.cs`

using System.IO.Abstractions;
using System.Diagnostics;
using System.Text;

namespace archive_to_paperless;

internal class Program
{
    internal const string _ArchivePath = "/Users/pmario/Local/archived";
    // internal const string NASDropPath = "/Volumes/dropfolders/paperless";

    internal const string _NASDropPathRel = "/dropfolders/paperless";
    internal const string _NASDropPath = $"/Volumes{_NASDropPathRel}";
    internal const string _serverName = "//contrib@truenas";

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

        if (EnsureNASMounted(_serverName, _NASDropPathRel) != ErrorCodes.SUCCESS)
        {
            return (int)ErrorCodes.PREREQ_FAILED;
        }

        // ensure archive folder exists
        fs.Directory.CreateDirectory(_ArchivePath);

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
        Console.WriteLine($"NAS Drop Path: {_NASDropPath}");
        Console.WriteLine($"Archive Path:  {_ArchivePath}");
    }

    internal static FileResult ProcessFile(IFileSystem fs, string arg)
    {
        var fileName = fs.Path.GetFileName(arg);
        var destPath = fs.Path.Combine(_NASDropPath, fileName);

        FileResult result = FileResult.Success;

        if (!fs.File.Exists(destPath))
        {
            fs.File.Copy(arg, destPath);
        }
        else
        {
            result = FileResult.AlreadyArchived;
        }

        var archiveDestPath = fs.Path.Combine(_ArchivePath, fileName);
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

    internal static ErrorCodes EnsureNASMounted(string serverPath, string relPath)
    {
        if (Directory.Exists(Path.Combine("/Volume", relPath)))
        {
            return ErrorCodes.SUCCESS;
        }

        string mountPath = Path.Combine("/Volumes", relPath);

        var psi = new ProcessStartInfo
        {
            FileName = "/sbin/mount_smbfs",
            Arguments = $"{Path.Combine(serverPath, relPath)} {mountPath}",
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false
        };

        var process = Process.Start(psi);

        if (process == null)
        {
            Console.Error.WriteLine("Failed to execute 'mount_smbfs'");
            return ErrorCodes.PREREQ_FAILED;
        }

        if (!process.WaitForExit(5_000))
        {
            var sb = new StringBuilder("Executing'mount_smbfs' timed out!");
            sb.AppendLine(process.StandardError.ReadToEnd());
            sb.AppendLine(process.StandardOutput.ReadToEnd());

            Console.Error.WriteLine(sb);
            return ErrorCodes.PREREQ_FAILED;
        }

        return ErrorCodes.SUCCESS;
    }
}

enum ErrorCodes
{
    SUCCESS = 0,
    PREREQ_FAILED = 1,
    COPY_FAILED = -1,

    // public static implicit operator int(ErrorCodes value) => (int)value;
}

internal enum FileResult
{
    Success,
    Failure,
    AlreadyArchived,
    AlreadyArchivedWarning
}