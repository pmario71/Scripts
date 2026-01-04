using HelperLib;

if (args.Length < 1)
{
    PrintUsage();
    return 1;
}

var command = args[0];

return command switch
{
    "validate-year" => ValidateYear(args.Skip(1).ToArray()),
    "help" => PrintUsage(),
    _ => InvalidCommand(command)
};

int ValidateYear(string[] cmdArgs)
{
    if (cmdArgs.Length == 0)
    {
        Console.Error.WriteLine("Error: Path argument required");
        Console.Error.WriteLine("Usage: HelperLibCli validate-year <path>");
        return 1;
    }

    var path = cmdArgs[0];
    
    if (!Directory.Exists(path))
    {
        Console.Error.WriteLine($"Error: Directory not found: {path}");
        return 1;
    }

    try
    {
        var results = XmpHelper.ValidateYear(path).ToList();
        
        // Use simple text output instead of JSON
        var errorCount = results.Count(r => r.HasError);
        var validCount = results.Count(r => !r.HasError);
        
        Console.WriteLine($"VALIDATION_RESULT|{validCount}|{errorCount}");
        
        foreach (var result in results.Where(r => r.HasError))
        {
            Console.WriteLine($"ERROR|{result.ErrorType}|{result.ErrorMsg}");
        }
        
        return errorCount > 0 ? 1 : 0;
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"ERROR|Exception|{ex.Message}");
        return 1;
    }
}

int InvalidCommand(string command)
{
    Console.Error.WriteLine($"Error: Unknown command '{command}'");
    PrintUsage();
    return 1;
}

int PrintUsage()
{
    Console.WriteLine(@"HelperLibCli - XMP Photo Metadata Validator

Usage: HelperLibCli <command> [options]

Commands:
  validate-year <path>    Validate XMP metadata years against directory structure
  help                    Show this help message

Examples:
  HelperLibCli validate-year /path/to/photos
");
    return 0;
}
