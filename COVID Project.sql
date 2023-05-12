SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Shows likelihood of death by COVID in a country
SELECT location, date, total_cases, total_deaths, 
	(CONVERT(decimal,D.total_deaths)/CONVERT(decimal, D.total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths AS D
WHERE location like '%states' AND continent IS NOT NULL
ORDER BY 1,2


--Shows percentage of population that has gotten COVID in a country
SELECT location, date, population, total_cases,
	(CONVERT(decimal,D.total_cases)/CONVERT(decimal, D.population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths AS D
WHERE location like '%states' AND continent IS NOT NULL
ORDER BY 1,2


--Countries with highest infection rate relative to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
	MAX(CONVERT(decimal,D.total_cases)/CONVERT(decimal, D.population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths AS D
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC

		--CREATE VIEW TO STORE DATA FOR VISUALIZATION(S)
		CREATE VIEW PopulationInfectedPercentage AS
			SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
				MAX(CONVERT(decimal,D.total_cases)/CONVERT(decimal, D.population))*100 AS PopulationInfectedPercentage
			FROM PortfolioProject..CovidDeaths AS D
			WHERE continent IS NOT NULL
			GROUP BY location, population
			--ORDER BY PopulationInfectedPercentage DESC


--Countries with highest death count relative to population
SELECT location, MAX(CONVERT(int,D.total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths AS D
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

		--CREATE VIEW TO STORE DATA FOR VISUALIZATION(S)
		CREATE VIEW CountryDeathCount AS
			SELECT location, MAX(CONVERT(int,D.total_deaths)) AS TotalDeathCount
			FROM PortfolioProject..CovidDeaths AS D
			WHERE continent IS NOT NULL
			GROUP BY location
			--ORDER BY TotalDeathCount DESC


--Showing continents with the highest death count relative to population
SELECT continent, MAX(CONVERT(int,D.total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths AS D
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

		--CREATING VIEW TO STORE DATA FOR VISUALIZATION(S)
		CREATE VIEW ContinentDeathCount AS
			SELECT continent, MAX(CONVERT(int,D.total_deaths)) AS TotalDeathCount
			FROM PortfolioProject..CovidDeaths AS D
			WHERE continent IS NOT NULL
			GROUP BY continent
			--ORDER BY TotalDeathCount DESC


--GLOBAL numbers
SELECT SUM(new_cases) AS total_cases, SUM(CONVERT(int,D.new_deaths)) AS total_deaths, 
	SUM(CONVERT(int,D.new_deaths))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths AS D
WHERE continent IS NOT NULL AND new_cases<>0
ORDER BY 1,2


--GLOBAL numbers by date
SELECT date, SUM(new_cases) AS total_cases, SUM(CONVERT(int,D.new_deaths)) AS total_deaths, 
	SUM(CONVERT(int,D.new_deaths))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths AS D
WHERE continent IS NOT NULL AND new_cases<>0
GROUP BY date
ORDER BY 1,2

		--CREATING VIEW TO STORE DATA FOR VISUALIZATION(S)
		CREATE VIEW GlobalDeathPercentage AS
			SELECT SUM(new_cases) AS total_cases, SUM(CONVERT(int,D.new_deaths)) AS total_deaths, 
				SUM(CONVERT(int,D.new_deaths))/SUM(new_cases)*100 AS DeathPercentage
			FROM PortfolioProject..CovidDeaths AS D
			WHERE continent IS NOT NULL AND new_cases<>0
			--ORDER BY 1,2




--APPROACH 1: CTE (pVc = population vs vaccination)
WITH pVc (continent, location, date, population, new_vaccinations, CumulativeVaccination)
AS
(
--Total Population vs Vaccinations
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(bigint,V.new_vaccinations)) 
	OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS CumulativeVaccination
	--,(CumulativeVaccination/population)*100
FROM PortfolioProject..CovidDeaths AS D
JOIN  PortfolioProject..CovidVaccinations AS V
	ON D.location = v.location
	AND D.date = v.date
WHERE D.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (CumulativeVaccination/population)*100 AS VaccinationPercentage
FROM pVc


--APPROACH 2: Temp Table
DROP TABLE IF EXISTS #PopulationVaccinatedPercentage
CREATE TABLE #PopulationVaccinatedPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVaccination numeric
)

INSERT INTO #PopulationVaccinatedPercentage
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(bigint,V.new_vaccinations)) 
	OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS CumulativeVaccination
	--,(CumulativeVaccination/population)*100
FROM PortfolioProject..CovidDeaths AS D
JOIN  PortfolioProject..CovidVaccinations AS V
	ON D.location = v.location
	AND D.date = v.date
WHERE D.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (CumulativeVaccination/population)*100 AS VaccinationPercentage
FROM #PopulationVaccinatedPercentage

		--CREATING VIEW TO STORE DATA FOR VISUALIZATION(S)
		CREATE VIEW PopulationVaccinatedPercentage AS
			SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
			SUM(CONVERT(bigint,V.new_vaccinations)) 
				OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS CumulativeVaccination
				--,(CumulativeVaccination/population)*100
			FROM PortfolioProject..CovidDeaths AS D
			JOIN  PortfolioProject..CovidVaccinations AS V
				ON D.location = v.location
				AND D.date = v.date
			WHERE D.continent IS NOT NULL
			--ORDER BY 2,3