SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
order by 3, 4

--SELECT * 
--FROM PortfolioProject..CovidVacc
--order by 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at total cases vs total deaths (Death Pourcentage)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases*100) AS 'DeathPercentage (%)'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%China%'
order by 1, 2

-- Looking at total cases vs population (Chances of getting covid)

SELECT location, date, total_cases, population, (total_cases/population*100) AS 'InfectionRate (%)'
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Morocco%'
order by 1, 2

-- Looking at countries with the highest infection rate 

SELECT location, date, total_cases, population, (total_cases/population*100) AS 'InfectionRate (%)'
FROM PortfolioProject..CovidDeaths
WHERE date = ' 2021-04-30 00:00:00:000 '
ORDER BY 'InfectionRate (%)' DESC

-- OR

SELECT location, MAX(total_cases) AS TotalCases, population, MAX((total_cases/population))*100AS 'InfectionRate (%)'             
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 'InfectionRate (%)' DESC

-- Looking at total deaths vs population

SELECT location, MAX(total_deaths) AS TotalDeathCount, population, MAX(total_deaths/population*100) AS 'DeathPercentage (%)'
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 'DeathPercentage (%)' DESC

-- Looking at death counts per continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population (death rate per continent)

SELECT continent, MAX(cast(total_deaths as int)/population) AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not Null
GROUP BY continent
ORDER BY DeathRate DESC

-- Global Numbers
-- per day

SELECT date, SUM(new_cases) AS TotalCases, 
SUM(cast(new_deaths as int)) AS TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage

FROM PortfolioProject..CovidDeaths

WHERE continent is not Null 

GROUP BY date

ORDER BY 4 DESC

-- from january 2020 until april 2021

SELECT SUM(new_cases) AS Total_Cases, 
SUM(cast(new_deaths as int)) AS Total_Deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases)*100) AS GlobalDeathPercentage

FROM PortfolioProject..CovidDeaths

WHERE continent is not Null 

-- Looking at the number of fully vaccinated people in the world

SELECT SUM(cast(people_fully_vaccinated as float))
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not Null


-- Looking at Rolling Count of Vaccinated People 

SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(CONVERT(int, new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not Null 

-- Looking at Total Population vs Vaccinations (CTE)

WITH CTE_vacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS 
(
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(CONVERT(int, new_vaccinations)) 
OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not Null 
)
SELECT *, 
(RollingPeopleVaccinated/Population*100) AS VaccinationRate
FROM CTE_vacc
ORDER BY 1,2

-- Temp Table

DROP TABLE if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(CONVERT(int, new_vaccinations)) 
OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not Null

SELECT *, 
(RollingPeopleVaccinated/Population*100) AS VaccinationRate
FROM PercentPopulationVaccinated
ORDER BY 1,2

-- Creating View to store data for later visualisation

CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(CONVERT(int, new_vaccinations)) 
OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not Null

CREATE VIEW InfectionRateView AS
SELECT location, date, total_cases, population, (total_cases/population*100) AS 'InfectionRate (%)'
FROM PortfolioProject..CovidDeaths
WHERE date = ' 2021-04-30 00:00:00:000 '
