SELECT * 
FROM COVID19..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM Covid19..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location,date,total_cases,new_cases,total_deaths, population
FROM COVID19..CovidDeaths
order by 1,2

--Looking at the total cases vs total deaths
SELECT location,date,total_cases,population, (total_cases/population)*100 as DeathPercentage
FROM COVID19..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking a countries with highest infection rate compared to population
SELECT location,population,Max(total_cases) as HighestInfectionCount,MAX ((total_cases/population))*100 as PercentPopulationInfected
FROM COVID19..CovidDeaths
--where location like '%states%'
Group by location,Population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount
FROM COVID19..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

 

-- Breaking things down by continent
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount
FROM COVID19..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


--Global Numbers
SELECT SUM(new_cases)as TotalCases,SUM(cast(new_deaths as int)) as DeathCount,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM COVID19..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2



SELECT * 
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location =vac.location
	and dea.date = vac.date

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location) 
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location =vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location =vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3








--Using CTE
With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location =vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
Locatin nvarchar (255),
Date datetime,
Population numeric,
NewVacccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location =vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null

	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM #PercentPopulationVaccinated


--Creating view
CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
	ON dea.location =vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null

	SELECT *
	FROM PercentPopulationVaccinated