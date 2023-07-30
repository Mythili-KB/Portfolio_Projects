SELECT * 
FROM PortfolioProject.dbo.CovidVaccination
ORDER BY 3,4

SELECT * 
FROM CovidDeaths
--WHERE continent=''
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths

UPDATE CovidDeaths 
SET total_cases= NULL
WHERE total_cases=0

UPDATE CovidDeaths 
SET new_cases= NULL
WHERE new_cases=0

UPDATE CovidDeaths 
SET total_deaths= NULL
WHERE total_deaths=0


--Total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM coviddeaths
WHERE location='india'

--Percentage of population could get covid

SELECT location, date, total_cases, Population, (total_cases/population)*100 AS PercentPopulationinfected 
FROM coviddeaths
--WHERE location='india'

--Countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS MaximumTotalCases, Population, MAX(total_cases/population)*100 AS PercentPopulationinfected 
FROM coviddeaths
--WHERE location='india'
GROUP BY location, population
ORDER BY PercentPopulationinfected DESC


--Total death count by countries

SELECT Location, SUM(Total_deaths) AS TotalDeathCount, AVG(population) AS Population
FROM CovidDeaths
WHERE continent!=''
GROUP BY location
ORDER BY TotalDeathCount DESC


--Countries with highest Death count per Population

SELECT Location, MAX(Total_deaths) AS MaxDeathCount
FROM CovidDeaths
WHERE continent!=''
GROUP BY location
ORDER BY MaxDeathCount DESC

--Continent with highest Death count per Population

SELECT continent, MAX(Total_deaths) AS MaxDeathCount
FROM CovidDeaths
WHERE continent!=''
GROUP BY continent
ORDER BY MaxDeathCount DESC

-- Total death by continent 

SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent!=''
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent!=''
--GROUP BY date
ORDER BY DeathPercentage DESC


--Looking at Total Population Vs Vaccinations

WITH Vccpop (continent, location, adte, population, new_vaccinations,rollingpeoplevaccinated) 
AS
(
SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations,
	SUM(vcc.new_vaccinations) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS RollingPeopleVaccinated
FROM coviddeaths dth
JOIN covidvaccination vcc
ON dth.location= vcc.location
AND dth.date= vcc.date
WHERE dth.continent!=''
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM Vccpop
--select convert(date, right(dth.date,4)+ left(dth.date,2) + substring(dth.date,3,2))
--from CovidDeaths dth

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccination
CREATE TABLE #PercentPopulationVaccination
(
continent nvarchar(50),
location nvarchar(50), 
date nvarchar(50),
population numeric, 
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

--#PercentPopulationVaccination
SELECT  dth.continent, dth.location, cast(right(dth.date,4)+'-'+right(left(dth.date,5),2)+'-'+left(dth.date,2) as date) as date,
dth.population, vcc.new_vaccinations, SUM(vcc.new_vaccinations) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS RollingPeopleVaccinated
FROM coviddeaths dth
JOIN covidvaccination vcc
ON dth.location= vcc.location
AND dth.date= vcc.date
ORDER BY date

--Create views for later visualizations

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations,
	SUM(vcc.new_vaccinations) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS RollingPeopleVaccinated
FROM coviddeaths dth
JOIN covidvaccination vcc
ON dth.location= vcc.location
AND dth.date= vcc.date
WHERE dth.continent!=''

SELECT * 
FROM PercentPopulationVaccinated