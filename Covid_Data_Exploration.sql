/*
Covid 19 Data Exploration 
Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
--------------------------------------------------------------------------------------------------------------------------
Select *
From DataAnalysisProject.dbo.CovidDeaths

Select *
From DataAnalysisProject.dbo.CovidVaccinations


--------------------------------------------------------------------------------------------------------------------------
-- Selecting Data that we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From DataAnalysisProject.dbo.CovidDeaths
Where continent is not null 
order by 1,2


--------------------------------------------------------------------------------------------------------------------------
-- Total Cases vs Total Deaths (United States): Shows likelihood of dying if you contract COVID
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DataAnalysisProject.dbo.CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


--------------------------------------------------------------------------------------------------------------------------
-- Total Cases vs Population (United States): Shows what percentage of population infected with COVID
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From DataAnalysisProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2


--------------------------------------------------------------------------------------------------------------------------
-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From DataAnalysisProject.dbo.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


--------------------------------------------------------------------------------------------------------------------------
-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalysisProject.dbo.CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--------------------------------------------------------------------------------------------------------------------------
-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From DataAnalysisProject.dbo.CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--------------------------------------------------------------------------------------------------------------------------
-- Taking a look at Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From DataAnalysisProject.dbo.CovidDeaths
where continent is not null 
order by 1,2



--------------------------------------------------------------------------------------------------------------------------
-- Total Population vs Vaccinations: Shows Percentage of Population that has recieved at least one Covid Vaccine
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From DataAnalysisProject.dbo.CovidDeaths d
Join DataAnalysisProject.dbo.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3



--------------------------------------------------------------------------------------------------------------------------
-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From DataAnalysisProject.dbo.CovidDeaths d
Join DataAnalysisProject.dbo.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--------------------------------------------------------------------------------------------------------------------------
-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From DataAnalysisProject.dbo.CovidDeaths d
Join DataAnalysisProject.dbo.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--------------------------------------------------------------------------------------------------------------------------
-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From DataAnalysisProject.dbo.CovidDeaths d
Join DataAnalysisProject.dbo.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null

