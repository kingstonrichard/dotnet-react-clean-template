while (($useSqlite -ne 'Y') -And ($useSqlite -ne 'N')) {
    $useSqlite = Read-Host -Prompt 'Does this project require Sqlite? (Y/N)'
}

while (($useSqlServer -ne 'Y') -And ($useSqlServer -ne 'N')) {
    $useSqlServer = Read-Host -Prompt 'Does this project require SqlServer? (Y/N)'
}

Write-Host 'Creating solution and projects' -ForegroundColor Green
dotnet new sln
dotnet new classlib -n Application -o src/Application        #Interface & Adapters layer
dotnet new classlib -n Domain -o src/Domain                  #Entities layer
dotnet new webapi -n API -o src/API                          #Use case layer
dotnet new classlib -n Persistence -o src/Persistence        #Frameworks & Drivers layer

Write-Host 'Tidying up project files' -ForegroundColor Green
((Get-Content -path .\src\API\API.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\API\API.csproj
((Get-Content -path .\src\Application\Application.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\Application\Application.csproj
((Get-Content -path .\src\Domain\Domain.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\Domain\Domain.csproj
((Get-Content -path .\src\Persistence\Persistence.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\Persistence\Persistence.csproj
Remove-Item * -include Class1.cs -Recurse
Remove-Item * -include WeatherForecast* -Recurse

Write-Host 'Adding projects to solution' -ForegroundColor Green
dotnet sln add src/API/API.csproj
dotnet sln add src/Application/Application.csproj
dotnet sln add src/Domain/Domain.csproj
dotnet sln add src/Persistence/Persistence.csproj
#TODO: Add test project here

Write-Host 'Adding references' -ForegroundColor Green
Set-Location src/API
dotnet add reference ../Application/Application.csproj
Set-Location ../Application
dotnet add reference ../Domain/Domain.csproj
dotnet add reference ../Persistence/Persistence.csproj
Set-Location ../Persistence
dotnet add reference ../Domain/Domain.csproj
#TODO: Add test project here
Set-Location ../../

Write-Host 'Adding NuGet packages' -ForegroundColor Green
$nugetSource = 'https://api.nuget.org/v3/index.json'
dotnet add .\src\Application\Application.csproj package MediatR -s $nugetSource
dotnet add .\src\Application\Application.csproj package AutoMapper.Extensions.Microsoft.DependencyInjection -s $nugetSource
dotnet add .\src\Application\Application.csproj package FluentValidation.AspNetCore -s $nugetSource
if (($useSqlite -eq 'Y') -Or ($useSqlServer -eq 'Y')) {
    dotnet add .\src\Domain\Domain.csproj package Microsoft.AspNetCore.Identity.EntityFrameworkCore -s $nugetSource
    dotnet add .\src\API\API.csproj package Microsoft.EntityFrameworkCore.Design -s $nugetSource
}
if ($useSqlite -eq 'Y') { 
    dotnet add .\src\Persistence\Persistence.csproj package Microsoft.EntityFrameworkCore.Sqlite -s $nugetSource 
}
if ($useSqlServer -eq 'Y') { 
    dotnet add .\src\Persistence\Persistence.csproj package Microsoft.EntityFrameworkCore.SqlServer -s $nugetSource 
    dotnet add .\src\API\API.csproj package Microsoft.AspNetCore.Authentication.Certificate -s $nugetSource 
}

Write-Host 'Installing global tools' -ForegroundColor Green
dotnet tool install --global dotnet-ef

Write-Host 'Executing dotnet restore' -ForegroundColor Green
dotnet restore

Write-Host 'Initialising repo' -ForegroundColor Green
Remove-Item .\.git\ -Recurse -Force
try {
    git init
    git branch -M main
}
catch {
    Write-Host 'Unable to initialise git repo - do you have GIT installed?' -ForegroundColor Red
}
Set-Content .gitignore (Invoke-WebRequest -UseBasicParsing -Uri 'https://www.toptal.com/developers/gitignore/api/visualstudio,visualstudiocode,react').Content

Write-Host 'Finishing up' -ForegroundColor Green
Write-Host 'Be sure to add your own remote GIT repo URL' - ForegroundColor Green
Remove-Item begin.ps1
