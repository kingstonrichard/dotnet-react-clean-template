while (($dataProvider -ne "Sqlite") -And ($dataProvider -ne "SqlServer")) {
    $dataProvider = Read-Host -Prompt "Which EntityFrameworkCore data provider would you like to use - Sqlite or SqlServer?"
}

Write-Host "Creating solution and projects" -ForegroundColor Green
dotnet new sln
dotnet new webapi -n API -o src/API
dotnet new classlib -n Application -o src/Application
dotnet new classlib -n Domain -o src/Domain
dotnet new classlib -n Persistence -o src/Persistence

Write-Host "Tidying up project files" -ForegroundColor Green
((Get-Content -path .\src\API\API.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\API\API.csproj
((Get-Content -path .\src\Application\Application.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\Application\Application.csproj
((Get-Content -path .\src\Domain\Domain.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\Domain\Domain.csproj
((Get-Content -path .\src\Persistence\Persistence.csproj -Raw) -replace '<Nullable>enable</Nullable>', '<Nullable>disable</Nullable>') | Set-Content -Path .\src\Persistence\Persistence.csproj
Remove-Item * -include Class1.cs -Recurse
Remove-Item * -include WeatherForecast* -Recurse

Write-Host "Adding projects to solution" -ForegroundColor Green
dotnet sln add src/API/API.csproj
dotnet sln add src/Application/Application.csproj
dotnet sln add src/Domain/Domain.csproj
dotnet sln add src/Persistence/Persistence.csproj
#TODO: Add test project here

Write-Host "Adding references" -ForegroundColor Green
Set-Location src/API
dotnet add reference ../Application/Application.csproj
Set-Location ../Application
dotnet add reference ../Domain/Domain.csproj
dotnet add reference ../Persistence/Persistence.csproj
Set-Location ../Persistence
dotnet add reference ../Domain/Domain.csproj
#TODO: Add test project here
Set-Location ../../

Write-Host "Adding NuGet packages" -ForegroundColor Green
$nugetSource = "https://api.nuget.org/v3/index.json
dotnet add .\src\Domain\Domain.csproj package Microsoft.AspNetCore.Identity.EntityFrameworkCore -s $nugetSource
dotnet add .\src\Persistence\Persistence.csproj package Microsoft.EntityFrameworkCore.$dataProvider -s $nugetSource
dotnet add .\src\Application\Application.csproj package MediatR -s $nugetSource
dotnet add .\src\Application\Application.csproj package AutoMapper.Extensions.Microsoft.DependencyInjection -s $nugetSource
dotnet add .\src\Application\Application.csproj package FluentValidation.AspNetCore -s $nugetSource
dotnet add .\srcAPI\API.csproj package Microsoft.EntityFrameworkCore.Design -s $nugetSource
if ($dataProvider -eq "SqlServer") { dotnet add .\/src\API\API.csproj package Microsoft.AspNetCore.Authentication.Certificate -s $nugetSource }

Write-Host "Installing global tools" -ForegroundColor Green
dotnet tool install --global dotnet-ef

Write-Host "Executing dotnet restore" -ForegroundColor Green
dotnet restore

Write-Host "Initialising repo" -ForegroundColor Green
Remove-Item .\.git\ -Recurse -Force
try {
    git init
    git branch -M main
}
catch {
    Write-Host "Unable to initialise git repo - do you have GIT installed?" -ForegroundColor Red
}
Set-Content .gitignore (Invoke-WebRequest -UseBasicParsing -Uri "https://www.toptal.com/developers/gitignore/api/visualstudio,visualstudiocode,react").Content

Write-Host "Finishing up" -ForegroundColor Green
Remove-Item begin.ps1
