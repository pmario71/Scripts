using System.IO.Abstractions.TestingHelpers;

namespace archive_to_paperless.tests;

public class ProcessFileTests
{
    [Fact]
    public void Test1()
    {
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { @"/sourcefolder/testfile.txt", new MockFileData("Content of file1") },
        });
        fs.AddDirectory(Program.ArchivePath);
        fs.AddDirectory(Program.NASDropPath);

        var res = Program.ProcessFile(fs, "/sourcefolder/testfile.txt");
        
        Assert.Equal(FileResult.Success, res);
    }
    
    
}
