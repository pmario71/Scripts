using Shouldly;
using TestHelpers.Files;

namespace archive_to_paperless.tests;

public class Prototyping_EndToEnd : IDisposable
{
    private FileGarbageCollector _gc;

    const string fname = "Dividendengutschrift_300_St._A14Y6F_(ALPHABET_INC.CL.A_DL-,001)_vom_15.06.2026_FCA60E.pdf";

    public Prototyping_EndToEnd(ITestOutputHelper oh)
    {
        _gc = new FileGarbageCollector(oh);
    }

    public void Dispose()
    {
        _gc.Cleanup();
    }

    [Fact]
    public void End_to_End_Test()
    {
        // Given
        string sourceFile = TestHelpers.TestDataHelper.ResolveTestdataFile(fname);
        string targetFile = Path.Combine(Path.GetTempPath(), fname);
        _gc.RegisterFile(targetFile);

        File.Copy(sourceFile, targetFile);

        // When
        var ret = Program.Main([targetFile]);

        // Then
        ret.ShouldBe((int)ErrorCodes.SUCCESS);
    }
}