using System.IO.Abstractions.TestingHelpers;

namespace archive_to_paperless.tests;

public class ProgramTests
{
    [Fact]
    public void ProcessFile_NewFile_ReturnsSuccess()
    {
        // Arrange
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") },
        });
        fs.AddDirectory(Program._ArchivePath);
        fs.AddDirectory(Program._NASDropPath);
        
        // Act
        var result = Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.Equal(FileResult.Success, result);
    }

    [Fact]
    public void ProcessFile_FileAlreadyInNAS_ReturnsAlreadyArchived()
    {
        // Arrange
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") },
            { $"{Program._NASDropPath}/testfile.pdf", new MockFileData("Content of file") },
        });
        fs.AddDirectory(Program._ArchivePath);
        
        // Act
        var result = Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.Equal(FileResult.AlreadyArchived, result);
    }

    [Fact]
    public void ProcessFile_FileInArchiveWithSameWriteTime_ReturnsAlreadyArchived()
    {
        // Arrange
        var writeTime = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime } },
            { $"{Program._ArchivePath}/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime } },
        });
        fs.AddDirectory(Program._NASDropPath);
        
        // Act
        var result = Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.Equal(FileResult.AlreadyArchived, result);
    }

    [Fact]
    public void ProcessFile_FileInArchiveWithDifferentWriteTime_ReturnsAlreadyArchivedWarning()
    {
        // Arrange
        var writeTime1 = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);
        var writeTime2 = new DateTime(2024, 1, 2, 12, 0, 0, DateTimeKind.Utc);
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime1 } },
            { $"{Program._ArchivePath}/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime2 } },
        });
        fs.AddDirectory(Program._NASDropPath);
        
        // Act
        var result = Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.Equal(FileResult.AlreadyArchivedWarning, result);
    }

    [Fact]
    public void ProcessFile_FileInBothNASAndArchiveWithSameWriteTime_ReturnsAlreadyArchived()
    {
        // Arrange
        var writeTime = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime } },
            { $"{Program._NASDropPath}/testfile.pdf", new MockFileData("Content of file") },
            { $"{Program._ArchivePath}/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime } },
        });
        
        // Act
        var result = Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.Equal(FileResult.AlreadyArchived, result);
    }

    [Fact]
    public void ProcessFile_FileInBothNASAndArchiveWithDifferentWriteTime_ReturnsAlreadyArchivedWarning()
    {
        // Arrange
        var writeTime1 = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);
        var writeTime2 = new DateTime(2024, 1, 2, 12, 0, 0, DateTimeKind.Utc);
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime1 } },
            { $"{Program._NASDropPath}/testfile.pdf", new MockFileData("Content of file") },
            { $"{Program._ArchivePath}/testfile.pdf", new MockFileData("Content of file") { LastWriteTime = writeTime2 } },
        });
        
        // Act
        var result = Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.Equal(FileResult.AlreadyArchivedWarning, result);
    }

    [Fact]
    public void ProcessFile_NewFile_CopiesFileToNAS()
    {
        // Arrange
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") },
        });
        fs.AddDirectory(Program._ArchivePath);
        fs.AddDirectory(Program._NASDropPath);
        
        // Act
        Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.True(fs.File.Exists($"{Program._NASDropPath}/testfile.pdf"));
    }

    [Fact]
    public void ProcessFile_NewFile_MovesFileToArchive()
    {
        // Arrange
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") },
        });
        fs.AddDirectory(Program._ArchivePath);
        fs.AddDirectory(Program._NASDropPath);
        
        // Act
        Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        Assert.True(fs.File.Exists($"{Program._ArchivePath}/testfile.pdf"));
        Assert.False(fs.File.Exists("/sourcefolder/testfile.pdf"));
    }

    [Fact]
    public void ProcessFile_FileAlreadyInNAS_DoesNotCopyAgain()
    {
        // Arrange
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("Content of file") },
            { $"{Program._NASDropPath}/testfile.pdf", new MockFileData("Existing content") },
        });
        fs.AddDirectory(Program._ArchivePath);
        
        // Act
        Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        var nasFileContent = fs.File.ReadAllText($"{Program._NASDropPath}/testfile.pdf");
        Assert.Equal("Existing content", nasFileContent);
    }

    [Fact]
    public void ProcessFile_FileInArchive_DoesNotMoveAgain()
    {
        // Arrange
        var writeTime = new DateTime(2024, 1, 1, 12, 0, 0, DateTimeKind.Utc);
        var fs = new MockFileSystem(new Dictionary<string, MockFileData>
        {
            { "/sourcefolder/testfile.pdf", new MockFileData("New content") { LastWriteTime = writeTime } },
            { $"{Program._ArchivePath}/testfile.pdf", new MockFileData("Existing content") { LastWriteTime = writeTime } },
        });
        fs.AddDirectory(Program._NASDropPath);
        
        // Act
        Program.ProcessFile(fs, "/sourcefolder/testfile.pdf");
        
        // Assert
        var archiveFileContent = fs.File.ReadAllText($"{Program._ArchivePath}/testfile.pdf");
        Assert.Equal("Existing content", archiveFileContent);
        Assert.True(fs.File.Exists("/sourcefolder/testfile.pdf"));
    }
}
