# .NET, React, Clean Architecture Template

This repo contains a Powershell script that will create a new solution, projects and references for a .NET Core and React application that uses the Clean Architecture pattern.

```
src\
|-- API (webapi)
|-- Application (classlib)
|-- Domain (classlib)
|-- Persistence (classlib)
|-- WebApp (reactjs)
|-- .gitignore
```

The class library projects will be empty to begin with whereas the API and WebApp will have their default files and settings.

The idea here to set up your domain objects, persistence layer and application logic per your requirements and have both your API and WebApp use those.

# Get Started

Clone the repo into a folder of your choice and run the script:

```
git clone --depth 1 https://github.com/kingstonrichard/dotnet-react-clean-template MySolution
cd MySolution
.\begin.ps1
```

This script will use the name of your folder to create a SLN file with the same name. It will then create the API project, Class Library projects and WebApp project. Each will be added to the SLN file and per Clean Architecture principles, refrences will be mapped between them.

- The WebApp will reference the API project
- The API project will reference the Application project
- The Application project will reference the Domain and Persistence projects
- The persistence project will reference the Domain project
- The domain project will have no references

It will also create a .gitignore file taking the latest content from http://gitignore.io tagged with VisualStudio, VisualStudioCode and React.

When the script has finished running, it will tidy up by:

- Reinitialising the git repo so you have a fresh one
- Deleting itself so that it doesn't clutter up your solution folder/files

You can now go ahead and open this solution in Visual Studio or Visual Studio Code.

# GIT and initial commit

When you open the solution you'll notice that all files are ready to be committed to the git repo. The repo has no remote origin at the moment and no branches. Let's fix that:

```
git branch -m main
git add -A
git commit -m 'Initial commit'
git remote add origin MyRemoteRepoUrl
git push -u origin main
```