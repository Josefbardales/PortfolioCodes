-- The following SQL queries have been used on the following dataset: https://ourworldindata.org/covid-deaths in order to demonstrate how to obtain data in a publically available dataset.

SELECT * FROM dbo.CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM dbo.['Covid Vaccinations$']
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population FROM dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Percentage of dying from Covid in Honduras, my home country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Honduras%'
ORDER BY 1,2

-- Percentage of Population with Covid

SELECT Location, Date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Honduras%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(Total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY InfectedPercentage DESC

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC

-- Break down by continent area with the highest death count

SELECT Location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Global Statistics

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP by Date
ORDER by 1,2

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.['Covid Vaccinations$'] vac ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingVaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.['Covid Vaccinations$'] vac ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingVaccinations/Population)*100 FROM Popvsvac

-- View to store data for visualizations
CREATE VIEW Global_Statistics as
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP by Date

SELECT * FROM Global_Statistics
