/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM [dbo].[Covid Deaths]
WHERE continent is not null
ORDER BY 3,4


SELECT *
FROM [dbo].[Covid Vaccinations]
ORDER BY 3,4

-- SELECT data that we are goung to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[Covid Deaths]
WHERE continent is not null
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows the lkelihood of dying if you contractcovid in your country

SELECT Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM [dbo].[Covid Deaths]
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2;

-- Looking at the Total Cases vs Population
-- Shows what percentage of population Infected with covid

SELECT Location, date,total_cases,population, (total_cases/population)*100 AS Deathpercentage
FROM [dbo].[Covid Deaths]
-- WHERE location like '%states%
WHERE continent is not null
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population


SELECT Location,population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)) AS PercentPopulationInfected
FROM [dbo].[Covid Deaths]
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing the Countries with the HighhestDeath Count per Population


SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [dbo].[Covid Deaths]
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT


SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [dbo].[Covid Deaths]
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Showing the continents with the highest death per population
-- GLOBAL NUMBERS


 SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS int)), SUM(CAST(new_deaths AS int))/ SUM(new_cases)*100 AS DeathPercentage
--  (total_deaths/total_cases)*100 AS Deathpercentage
FROM [dbo].[Covid Deaths]
-- WHERE location like '%states%'
 WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2;


--Looking at Total Population vs Vaccination
--Shows Percentage of Population that has received at least one Covid Vaccination


SELECT *
FROM [dbo].[Covid Deaths] dea
 JOIN [dbo].[Covid Vaccinations] vac
 ON dea.location = vac.location
 and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [dbo].[Covid Deaths] dea
 JOIN [dbo].[Covid Vaccinations] vac
      ON dea.location = vac.location
      and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT (int,vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population) *100
FROM [dbo].[Covid Deaths] dea
JOIN [dbo].[Covid Vaccinations] vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3; 
 
-- USE CTE To perform Calculation on Partition By in previous Query

With PopvsVac (continent, location, date, population,new_vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
 ,SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population) *100
FROM [dbo].[Covid Deaths] dea
JOIN [dbo].[Covid Vaccinations]vac
     ON dea.location = vac.location
     and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Using TEMP TABLE to perform Calculation on Partition By in previous Query


DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
 ,SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population) *100
FROM [dbo].[Covid Deaths] dea
JOIN [dbo].[Covid Vaccinations]vac
     ON dea.location = vac.location
     and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
 ,SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population) *100
FROM [dbo].[Covid Deaths] dea
JOIN [dbo].[Covid Vaccinations]vac
     ON dea.location = vac.location
     and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM #PercentPopulationVaccinated



