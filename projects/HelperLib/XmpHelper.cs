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
    public static IEnumerable<string> ValidateYear(string sourcePath)
    {
        var xmpFilePaths = Directory.EnumerateFiles(sourcePath, "*.xmp", SearchOption.AllDirectories);
        foreach (var path in xmpFilePaths)
        {
            var doc = ReadXmpFile(path);

            var dt = ReadDateTimeOriginal(doc);
            if (dt == null)
            {
                yield return $"(parse error) year from xmp file: {path}";
            }
            var yearFromPath = ExtractYearFromPath(path);

            if (yearFromPath == -1)
            {
                yield return $"(parse error) year from path: {path}";
            }

            if (dt!.Value.Year != yearFromPath)
            {
                yield return $"(validation error) year from path: {yearFromPath}, year in xmp: {dt.Value.Year}";
            }
        }
    }

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

        return -1;
    }
    
    /// <summary>
    /// 
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
