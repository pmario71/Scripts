namespace HelperLib.Tests;

public class XmpHelperTests
{
    private readonly ITestOutputHelper _output;

    readonly string _xmpFile =
        "/Users/pmario/Projects/Scripts/projects/tests/HelperLib.Tests/TestData/Photo/XMP/DSC05043.ARW.xmp";

    public XmpHelperTests(ITestOutputHelper output)
    {
        _output = output;
    }

    [Fact]
    public void ReadXmpFileTest()
    {
        var xmpDoc = XmpHelper.ReadXmpFile(_xmpFile);

        Assert.NotNull(xmpDoc);
    }

    [Fact]
    public void ReadDateTimeOriginalTest()
    {
        var xmpDoc = XmpHelper.ReadXmpFile(_xmpFile);

        DateTime? result = XmpHelper.ReadDateTimeOriginal(xmpDoc);

        Assert.NotNull(result);
        Assert.Equal(new DateTime(year: 2023, month: 10, day: 1, hour: 14, minute: 29, second: 55), result);
    }

    [Theory]
    [InlineData("/test/2023/file.xmp", 2023)]
    [InlineData("/test/2023/other/file.xmp", 2023)]
    [InlineData("/2025/some/other/file.xmp", 2025)]
    [InlineData("/test/xxx/other/file.xmp", -1)]
    [InlineData("/test/1899/other/file.xmp", -1)]
    [InlineData("/test/2122/other/file.xmp", -1)]
    public void ExtractYearFromPathTest(string path, int expectedYear)
    {
        int? result = XmpHelper.ExtractYearFromPath(path);

        if (expectedYear != 0)
        {
            Assert.Equal(expectedYear, result!);
        }
        else
        {
            Assert.Null(result);
        }
    }
}