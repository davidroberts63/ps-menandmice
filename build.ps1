Rename-Item .\source MenAndMice
Publish-Module -Path .\MenAndMice -Repository $ENV:RepositoryName -NuGetApiKey $ENV:NuGetApiKey
Rename-Item .\MenAndMice source