using System.Globalization;
using System.Xml.Linq;
using System.Linq;

namespace HelperLib;

public static class XmpHelper
{
    static readonly XNamespace RDF = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
    static readonly XNamespace Exif = "http://ns.adobe.com/exif/1.0/";
    
    const string DateFormat = "yyyy:MM:dd HH:mm:ss.fff";


    /// <summary>
    /// Extracts year from xmp file and checks if it corresponds with year in filepath.
    /// It returns a list of validation or other errors.
    /// </summary>
    /// <param name="sourcePath"></param>
    /// <returns>list of validation or parse errors</returns>
    public static IEnumerable<ValidationResult> ValidateYear(string sourcePath)
    {
        var xmpFilePaths = Directory.EnumerateFiles(sourcePath, "*.xmp", SearchOption.AllDirectories);
        foreach (var path in xmpFilePaths)
        {
            var doc = ReadXmpFile(path);

            var dt = ReadDateTimeOriginal(doc);
            if (dt == null)
            {
                yield return ValidationResult.FromError( ErrorType.ParseError, $"year from xmp file: {path}");
                continue;
            }
            var yearFromPath = ExtractYearFromPath(path);

            if (yearFromPath == -1)
            {
                yield return ValidationResult.FromError( ErrorType.ParseError, $"year from path: {path}");
                continue;
            }

            if ((dt!.Value.Year) != yearFromPath)
            {
                yield return ValidationResult.FromError( ErrorType.ValidationError, $"year from path: {yearFromPath}, year in xmp: {dt.Value.Year} ({path})");
                continue;
            }
        }
    }

    /// <summary>
    /// Tries to extract year from file path by looking at directory names.
    /// It looks for 4 digit directory names between 1900 and 2100!
    /// </summary>
    /// <param name="sourcePath"></param>
    /// <returns></returns>
    public static int ExtractYearFromPath(string sourcePath)
    {
        var currentPath = sourcePath.AsSpan();
        while (true)
        {
            ReadOnlySpan<char> directoryPath = Path.GetDirectoryName(currentPath);
            
            if (directoryPath.IsEmpty)
                return -1;
            
            var directoryName = Path.GetFileName(directoryPath);

            if (directoryName.Length == 4 && int.TryParse(directoryName, NumberStyles.Integer, CultureInfo.InvariantCulture, out int result))
            {
                if (result is >= 1900 and <= 2100)
                    return result;
            }
            currentPath = directoryPath;
        }
    }
    
    /// <summary>
    /// Read file and create XDocument for later parsing.
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static XDocument ReadXmpFile(string path)
    {
        var doc = XDocument.Load(path);
        return doc;
    }

    /// <summary>
    /// Parses DateTimeOriginal value from xmp information and returns it.
    /// </summary>
    /// <param name="xmpDoc"></param>
    /// <returns>DateTime if value was found and successfully parsed, null otherwise</returns>
    public static DateTime? ReadDateTimeOriginal(XDocument xmpDoc)
    {
        var description = xmpDoc.Descendants(RDF + "Description").FirstOrDefault();
        if  (description == null)
            return null;
        
        string? dateString = description.Attribute(Exif + "DateTimeOriginal")?.Value;
        if (string.IsNullOrEmpty(dateString))
            return null;

        if (!DateTime.TryParseExact(dateString, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None,
                out DateTime result))
            return null;
        
        return result;
    }
}

public record ValidationResult
{
    public ErrorType ErrorType { get; init; }
    
    public bool HasError => ErrorType != ErrorType.None;

    public string ErrorMsg { get; init; } = string.Empty;

    public static ValidationResult NoError = new ValidationResult() { ErrorType = ErrorType.None };

    public static ValidationResult FromError(ErrorType errorType, string message)
    {
        return new ValidationResult(){ ErrorType = errorType, ErrorMsg = message };
    }
}

public enum ErrorType
{
    None,
    ValidationError,
    ParseError
}