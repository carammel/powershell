[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$(base64AuthInfo)=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "$(username)","$(pattoken)")))

$FileContent = Get-Content -Path "$(System.ArtifactsDirectory)/getReleaseDef.json" -Raw | ConvertFrom-Json
#top 
$FileContent.source = 'undefined'
$FileContent.revision= 1
$FileContent.description= 'This release definition is created automatically by DevOps Team for $(repositoryName)'
$FileContent.createdBy = ''
$FileContent.createdOn= "0001-01-01T00:00:00"
$FileContent.modifiedBy = ''
$FileContent.modifiedOn= "0001-01-01T00:00:00"
$FileContent.id=0
$FileContent.name="$(ReleaseName)"
$FileContent.path='\\Release\$(repositoryName)'

#variables
$FileContent.variables.ID.value='$(ID)'


$silinecek_property = @('owner','_links','url')
foreach ($prop in $silinecek_property){
$FileContent.PSObject.Properties.Remove($prop)
}

#environments
$envDelList= @('currentRelease','badgeUrl')
foreach ($env in $FileContent.environments){
  foreach ($edl in $envDelList){
  $env.PSObject.Properties.Remove($edl)
  }
}

foreach ($env in $FileContent.environments){
  foreach ($cond in $env.conditions){
   if ($cond.conditionType -eq 'artifact'){
    $cond.name='_$(repositoryName).ci'
   }
  }
}

#trigger
$FileContent.triggers.Get(0).artifactAlias='_$(repositoryName).ci'

#artifacts
$FileContent.artifacts.Get(0).sourceId= '$(System.TeamProjectId):$(CIbuildid)'
$FileContent.artifacts.Get(0).alias='_$(repositoryName).openshift'
$FileContent.artifacts.Get(0).definitionReference.definition.id='$(CIbuildid)'
$FileContent.artifacts.Get(0).definitionReference.definition.name='$(repositoryName).ci'
$FileContent.artifacts.Get(0).definitionReference.project.id='$(System.TeamProjectId)'
$FileContent.artifacts.Get(0).definitionReference.project.name='$(System.TeamProject)'

$FileContent | ConvertTo-Json -Depth 99

#region update release pipeline
Write-Output ('Updating Release Definition')
$releaseurl = 'https://{instance}/{organization_name}/$(System.TeamProject)/_apis/release/definitions?api-version=6.0'
Write-Output $releaseurl

$json = @($FileContent ) | ConvertTo-Json -Depth 99
Invoke-RestMethod -Uri $releaseurl -Method POST -Body $json -ContentType "application/json;charset=utf-8" -Headers @{Authorization=("Basic {0}" -f $(base64AuthInfo))}
