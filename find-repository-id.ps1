[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$base64AuthInfo1=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f   "$(username)","$(pattoken)")))
$result = Invoke-RestMethod -Uri $(GETrepoURL) -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo1)}
$c = $result.value
foreach($m in $c)
{ if($m.name -eq '$(repositoryName)')
{
   $repositoryID=$m.id
}
}
echo $repositoryID
Write-Host "##vso[task.setvariable variable=repositoryID;]$repositoryID"
