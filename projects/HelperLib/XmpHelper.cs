using System.Globalization;
using System.Xml.Linq;

namespace HelperLib;

public static class XmpHelper
{
    static readonly XNamespace RDF = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
    static readonly XNamespace Exif = "http://ns.adobe.com/exif/1.0/";
    
    const string DateFormat = "yyyy:MM:dd HH:mm:ss.fff";
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
