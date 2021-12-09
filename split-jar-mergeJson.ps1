$split = $env:item.Split(" ")
$all_length = [System.Math]::Floor($split.Length / 150)
$js = @() | ConvertTo-Json | Out-File -FilePath $env:Build_SourcesDirectory\$env:BUILD_BUILDNUMBER.json
for ($i = 0; $i -le $all_length; $i++) {
    $split_array = [System.Collections.ArrayList]@()
    for ($j = $i * 150; $j -le ($i + 1) * 150; $j++) {
        if ([string]::IsNullOrEmpty($split[$j]))
        { break }
        else {
            $split_array.Add($split[$j])
        }
    }
    $bre = "_$i"
    D:\Repos\jdk-11.0.1\bin\java -Xmx4096m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dumpfile.hprof -jar D:\Repos\policy.jar $env:Build_SourcesDirectory\$env:BUILD_BUILDNUMBER$bre.json $split_array
    $abc = Get-Content $env:Build_SourcesDirectory\$env:BUILD_BUILDNUMBER$bre.json -Raw | ConvertFrom-Json
    $js = Get-Content $env:Build_SourcesDirectory\$env:BUILD_BUILDNUMBER.json -Raw | ConvertFrom-Json
    $js = @($js; $abc) | ConvertTo-Json | Out-File -FilePath $env:Build_SourcesDirectory\$env:BUILD_BUILDNUMBER.json
}
