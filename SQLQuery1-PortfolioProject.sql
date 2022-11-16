SELECT*
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT*
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

---LOOKING AT THE TOTAL CASES VS TOTAL DEATHS SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN NIGERIA AND THE UNITED STATES FOR INSTANCE.

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%NIGERIA%'
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%STATES%'
ORDER BY 1,2

---LOOKINHG AT THE TOTAL CASES VS THE POPULATION
---SHOWS WHAT PERCENTAGE OF TOTAL POPULATION GOT COVID

SELECT location,date,population,total_cases,(total_cases/population)*100  CovidPercentage
FROM CovidDeaths
WHERE location LIKE '%STATES%'
ORDER BY 1,2


SELECT location,date,population,total_cases,(total_cases/population)*100  CovidPercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

SELECT location,date,population,total_cases,(total_cases/population)*100  CovidPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

---LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location,population,MAX(total_cases) AS HighestInfectionCountry,MAX(total_cases/population)*100  PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

---SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location,MAX(CAST(total_deaths as int))AS HighestDeathCount
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC


SELECT location,MAX(CAST(total_deaths as int))AS HighestDeathCount
FROM CovidDeaths 
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC


SELECT continent,MAX(CAST(total_deaths as int))AS HighestDeathCount
FROM CovidDeaths 
WHERE continent IS not NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

---showing the continents with the highest deaths

SELECT continent,MAX(CAST(total_deaths as int))AS HighestDeathCount
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

---GLOBAL NUMBERS


SELECT SUM(NEW_CASES) AS Total_Cases, SUM(CAST(NEW_DEATHS AS INT)) AS Total_deaths,SUM(CAST(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(NEW_CASES) AS Total_Cases, SUM(CAST(NEW_DEATHS AS INT)) AS Total_deaths,SUM(CAST(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT*
FROM CovidDeaths  dea
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE DEA.continent IS NOT NULL
ORDER BY 1,2,3

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
FROM CovidDeaths  dea 
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---WE CAN ALSO DO

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location)
FROM CovidDeaths  dea
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---LOOKING AT TOTAL POPULATION VS VACCINE

---USING CTE

WITH PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
FROM CovidDeaths  dea 
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY 2,3
)
SELECT*,(RollingPeopleVaccinated/population)*100
FROM PopVsVac

---TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
FROM CovidDeaths  dea 
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY 2,3
SELECT*,(RollingPeopleVaccinated/population)*100
FROM  #PercentPopulationVaccinated

---OR WE COULD DO

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
FROM CovidDeaths  dea 
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
--WHERE dea.continent IS NOT NULL
---ORDER BY 2,3
SELECT*,(RollingPeopleVaccinated/population)*100
FROM  #PercentPopulationVaccinated


----VIEWS
--1.
CREATE VIEW PercentPopulationVaccinated
as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
FROM CovidDeaths  dea 
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
--WHERE dea.continent IS NOT NULL
---ORDER BY 2,3

--2.
CREATE VIEW DeathPercentageT
as
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 1,2

--3.
CREATE VIEW TotalCasesVsPopulation
as
SELECT location,date,population,total_cases,(total_cases/population)*100  CovidPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%Nigeria%'
--ORDER BY 1,2

--4.
CREATE VIEW PercentagePopulationInfected
as
SELECT location,population,MAX(total_cases) AS HighestInfectionCountry,MAX(total_cases/population)*100  PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
---ORDER BY PercentagePopulationInfected DESC

--5.
CREATE VIEW HighestDeathCount
as
SELECT location,MAX(CAST(total_deaths as int))AS HighestDeathCount
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
---ORDER BY HighestDeathCount DESC

--6.
CREATE VIEW GlobalDeathPercentage
as
SELECT SUM(NEW_CASES) AS Total_Cases, SUM(CAST(NEW_DEATHS AS INT)) AS Total_deaths,SUM(CAST(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2

--7.
CREATE VIEW GlobalDeathPercentage
as
SELECT SUM(NEW_CASES) AS Total_Cases, SUM(CAST(NEW_DEATHS AS INT)) AS Total_deaths,SUM(CAST(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2

--8.
CREATE VIEW RollingPeopleVaccinated
as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)as RollingPeopleVaccinated
FROM CovidDeaths  dea 
JOIN CovidVaccinations  vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
---ORDER BY 2,3

