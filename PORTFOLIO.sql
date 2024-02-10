SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%States%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentageofPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
ORDER BY 1,2

-- Looking at Countries with highest Infected Rate compared to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentageofPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
GROUP BY population,location
ORDER BY PercentageofPopulationInfected DESC

-- Showing Countries with Highest Death Count per population


SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
WHERE continent is not null
GROUP BY location
ORDER BY  TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTIENT

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY  TotalDeathCount DESC


-- SHOWING CONTIENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY  TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date,SUM(new_cases) AS TOTAL_CASES,SUM(CAST(new_deaths as int)) as TOTAL_DEATHS, SUM(CAST(new_deaths as int))/ SUM(new_cases) 
 *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%States%'
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
 
FROM PortfolioProject..CovidDeaths dea
join 
 PortfolioProject..CovidVaccinations vac
ON dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 1,2

SELECT *
FROM CovidVaccinations


WITH PopvsVac (Continent, Location,Date,Population,New_Vaccinations,RollingpeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
 
FROM PortfolioProject..CovidDeaths dea
join 
 PortfolioProject..CovidVaccinations vac
ON dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
select * ,(RollingpeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentaPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Contient nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingpeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
 
FROM PortfolioProject..CovidDeaths dea
join 
 PortfolioProject..CovidVaccinations vac
ON dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
select * ,(RollingpeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
 
FROM PortfolioProject..CovidDeaths dea
join 
 PortfolioProject..CovidVaccinations vac
ON dea.location =vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3

select *
from PercentPopulationVaccinated
