using archive_to_paperless;
using Shouldly;

namespace archive_to_paperless.tests;

public class Prototyping
{
    [Fact(Explicit = true)]
    public void MountSMBShare()
    {
        // Given
        // When
        var ret = Program.EnsureNASMounted(Program._serverName, Program._NASDropPathRel);
    
        // Then
        ret.ShouldBe(ErrorCodes.SUCCESS);
    }

    [Fact(Explicit = true)]
    public void TryToAccessMountedPath()
    {
        // Given
    
        // When
    
        // Then
        Directory.Exists(Program._NASDropPath);
    }
}
