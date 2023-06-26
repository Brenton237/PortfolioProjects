SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
Order By 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

--Select  Data that we are going to be using

SELECT location,date, total_cases,new_cases,total_deaths, population  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2


-- Total Cases vs Total Deaths
-- Shows the Likelyhood of dying if you contract Covid in your Country

SELECT location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%roon%'
AND continent IS NOT NULL
order by 1,2

--Infrences: Based on the data, A Cameroonian has a 2% chance of dying if contracted with the disease in 2021 


-- Looking at Total Cases vs Population
-- Shows what percentage of the Population has gotten Covid

SELECT location,date, total_cases, population, (total_cases/population)*100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%roon%'
AND continent IS NOT NULL
order by 1,2

--Infrences: Based on the data, 0.2% of the population in Cameroon has Covid-19 in 2021 


-- Country with the highest number of Covid Cases
SELECT location,population, MAX(total_cases)as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopInfected DESC

--Inference: Andora had the highest Covid infection rate 


-- Grouping By Continents

SELECT location,MAX(cast(total_deaths as int))as TotaldeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotaldeathCount DESC

-- Grouping By Countries

SELECT location,MAX(cast(total_deaths as int))as TotaldeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'Canada'
GROUP BY location
ORDER BY TotaldeathCount DESC



-- Countries with highest Death rate

SELECT location,population, MAX(cast(total_deaths as int))as TotaldeathCount, MAX(total_deaths /population)*100 as PercentagePopdead
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopdead DESC


-- Global Numbers

SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2


-- Exploring The CovidVaccinations Table


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3


-- Joining Both Tables
-- Looking at Total pop vs Vaccinations ( total amt of people vaccinated in the World) 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVacPerCountry
--, (RollingTotalVacPerCountry/ dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Using A CTE percentage vaccinated per Pop

WITH PopVsVac (continent, location, date, population,new_vaccinations, RollingTotalVacPerCountry) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVacPerCountry
--, (RollingTotalVacPerCountry/ dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *,(RollingTotalVacPerCountry/population)*100 PercentageVacPerCounntry
FROM PopVsVac



--TEMP TABLE
DROP Table IF EXISTS #PercentPopVaccinated 
CREATE Table #PercentPopVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingTotalVacPerCountry numeric
)

INSERT INTO #PercentPopVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVacPerCountry
--, (RollingTotalVacPerCountry/ dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingTotalVacPerCountry/population)*100 PercentageVacPerCounntry
FROM #PercentPopVaccinated 



-- Creating a view to store data for later visualizations

CREATE View PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingTotalVacPerCountry
--, (RollingTotalVacPerCountry/ dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopVaccinated