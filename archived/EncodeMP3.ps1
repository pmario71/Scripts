function wrap([string]$in)
{
    return ('"{0}"' -f $in)
}

$source = "Z:\Biermösl Blosn\Wellcome to Bavaria"
$lame = "D:\Tools\Audio\lame\lame.exe"
$param = " -h -v -b 192 "

$files = [System.IO.Directory]::GetFiles($source, "*.wav")

ForEach($f in $files)
{
    $mp3 = wrap([System.IO.Path]::ChangeExtension($f, ".mp3"))

    if (-not [System.IO.File]::Exists($mp3))
    {
        $f = wrap($f)

        $p = Start-Process $lame -ArgumentList @($param, $f, $mp3) -Verbose
    
        $fn = [System.IO.Path]::GetFileName($f)
        Write-Output ("Encoded {0} -> {1}" -f $fn, $p.ExitCode)
    }
    else
    {
        Write-Output ("Ignored {0} because existed!" -f $fn)
    }
}
Write-Output "Finished!"