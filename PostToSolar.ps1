#curl "http://localhost:8983/solr/techproducts/update/extract?literal.id=doc6&defaultField=text&commit=true" --data-binary @example/exampledocs/sample.html -H 'Content-type:text/html'
$file = 'D:\Dokumente\Bücher\dotNet\Apress.dot.NET.2.0.Interoperability.Recipes.A.Problem.Solution.Approach.Mar.2006.pdf'
$id = [System.IO.Path]::GetFileName($file)
$ext = [System.IO.Path]::GetExtension($file)

$fi = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList $file
$fileSize = $fi.Length

$col = 'files'
$server='http://localhost:8983/solr/'

#$headers = @{'Content-type'="text/$ext"}
$headers = @{'Content-type'='text/pdf'}
$URI = "$server$col/update/extract" #?method=standard&raw=true&fileName=$file&‌​fileSize=$fileSize"

$body = @{}
$body.Add("filename",  [IO.File]::ReadAllBytes($file))

$content = [IO.File]::ReadAllBytes($file)

$r = Invoke-RestMethod -Uri $URI -Method Post -Body $content -Headers $headers 
#$u = "$URI/extract?stream.file=$file&stream.contentType=application/pdf&literal.id=$id"
#Invoke-RestMethod -Uri $u

$r