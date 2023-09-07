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