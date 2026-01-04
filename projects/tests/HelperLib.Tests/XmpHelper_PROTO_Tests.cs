using System.Globalization;
using System.Xml.Linq;

namespace HelperLib.Tests;

public class XmpHelper_PROTO_Tests
{
    private readonly ITestOutputHelper _output;
    public XmpHelper_PROTO_Tests(ITestOutputHelper output)
    {
        _output = output;
    }
    

    [Fact]
    public void Prototyping_ReadDateTimeOriginal()
    {
        string xmpSnippet = @"<?xml version=""1.0"" encoding=""UTF-8""?>
<x:xmpmeta xmlns:x=""adobe:ns:meta/"" x:xmptk=""XMP Core 4.4.0-Exiv2"">
 <rdf:RDF xmlns:rdf=""http://www.w3.org/1999/02/22-rdf-syntax-ns#"">
  <rdf:Description rdf:about=""""
    xmlns:exif=""http://ns.adobe.com/exif/1.0/""
    exif:DateTimeOriginal=""2023:10:01 14:29:55.000"">
  </rdf:Description>
 </rdf:RDF>
</x:xmpmeta>";

        XDocument doc = XDocument.Parse(xmpSnippet);

        // 1. Define the necessary namespaces
        XNamespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
        XNamespace exif = "http://ns.adobe.com/exif/1.0/";

        // 2. Locate the attribute (using the exif namespace)
        var description = doc.Descendants(rdf + "Description").FirstOrDefault();
        string dateString = description?.Attribute(exif + "DateTimeOriginal")?.Value;

        if (!string.IsNullOrEmpty(dateString))
        {
            // 3. Parse the Exif-style date format
            // Format uses colons for the date: "yyyy:MM:dd HH:mm:ss.fff"
            string format = "yyyy:MM:dd HH:mm:ss.fff";
            
            if (DateTime.TryParseExact(dateString, format, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime result))
            {
                _output.WriteLine($"Successfully parsed: {result}");
            }
            else
            {
                _output.WriteLine("Failed to parse date string.");
            }
        }
    }

    [Fact]
    public void Prototyping_ValidateParser_over_all_xmp_files()
    {
        const string sourcePath = "/Users/pmario/Local/Todo";
        
        int cntErrors = 0;
        int cntFilesFound = 0;
        
        var xmpFiles = Directory.EnumerateFiles(sourcePath, "*.xmp", SearchOption.AllDirectories);
        foreach (var xmpFile in xmpFiles)
        {
            var xmpDoc = XmpHelper.ReadXmpFile(xmpFile);
            DateTime? result = XmpHelper.ReadDateTimeOriginal(xmpDoc);
            if (result == null)
            {
                cntErrors++;
                _output.WriteLine($"[{cntErrors}] {xmpFile}");
            }

            cntFilesFound++;
        }
        
        _output.WriteLine($"Files found      : {cntFilesFound}");
        _output.WriteLine($"Files with errors: {cntErrors}");
        
        Assert.Equal(0, cntErrors);
        Assert.True(cntFilesFound > 10);
    }
}