#requires -version 4.0
#requires –runasadministrator

# adapt path
$addPath = @()
$newPath = $env:Path + ";" + [System.String]::Join(';',$addPath)
$env:Path = $newPath

#add additional environment variables
$addVariables = @('JAVA_HOME',   'D:\Tools\Development\JDK'),
                @('HADOOP_HOME', 'D:\Tools\Development\Hadoop'),
                @('SPARK_HOME',  'D:\Tools\Development\spark-1.5.2-bin-hadoop2.6\bin')

foreach($v in $addVariables)
{
    $n = $v[0] # otherwise indexer is made part of string
    Set-Item -LiteralPath "env:$n" -Value $v[1]
}

cd D:\Tools\Allgemein\solr-5.4.0
.\bin\solr start -noprompt