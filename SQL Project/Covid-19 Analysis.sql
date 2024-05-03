SELECT * FROM [Portfolio Project ]..coviddeaths
where continent is not null 
order by 3,4

SELECT location,date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio Project ]..coviddeaths
order by 1,2 

-- Looking at Total cases vs. Total Deaths 
-- Shows likelihood of Dying if you contract covid in your country
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage 
FROM [Portfolio Project ]..coviddeaths
WHERE location like '%Taiwan%'
order by 1,2 

--Looking at total cases vs. population 
--Shows what percentage of population got Covid 
SELECT location,date,population, total_cases,  (total_cases/population) * 100 AS PercentPopulation
FROM [Portfolio Project ]..coviddeaths
WHERE location like '%Taiwan%'
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population 
SELECT location,population, date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM [Portfolio Project ]..coviddeaths
GROUP BY location, population, date
order by PercentPopulationInfected desc 



--Showing Countries with Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..coviddeaths
where continent is not null 
GROUP BY location 
order by TotalDeathCount desc 

-- Shwoing countries with new death per population part 2 
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..coviddeaths
where continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY location 
order by TotalDeathCount desc 


--Let's Break Things Down by Continent 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..coviddeaths
where continent is not null 
GROUP BY continent
order by TotalDeathCount desc 

-- Showing continents with the highest death count per populaton 

--Global numbers 
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage 
FROM [Portfolio Project ]..coviddeaths
WHERE continent is not null 
--GROUP BY date 
order by 1,2 



--Looking at Total Population vs. Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM [Portfolio Project ]..coviddeaths dea 
Join ['covidvaccination ] vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3


--USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)* 100
FROM [Portfolio Project ]..coviddeaths dea 
Join [Portfolio Project ]..['covidvaccination ] vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3 
)
SELECT * , (RollingPeopleVaccinated/Population)* 100 
FROM PopvsVac


--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project ]..coviddeaths dea 
Join [Portfolio Project ]..['covidvaccination ] vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations 

Create View PercentPopulationVaccinateds as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project ]..coviddeaths dea 
Join [Portfolio Project ]..['covidvaccination ] vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 

Select * 
FROM PercentPopulationVaccinateds




