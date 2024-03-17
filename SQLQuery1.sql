
Select * from covid..CovidDeaths
where continent is not null
order by 3,4


--Select * from covid..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from covid..CovidDeaths
order by 1,2

 --Looking at Total Cases vs Total Deaths

 Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population get Covid
 Select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from covid..CovidDeaths
Where location like '%states%'
order by 1,2 

-- Looking at countries with Highest Infected rate compared to population

 Select Location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from covid..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest DeathCount per Population

 Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc
 
-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population


 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

 Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from covid..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


--GLOBAL NUMBERS BY DATE


 Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from covid..CovidDeaths
Where continent is not null
Group by date
order by 1,2

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from covid..CovidDeaths dea
Join covid..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, New_Vaccinations,  RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from covid..CovidDeaths dea
Join covid..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from covid..CovidDeaths dea
Join covid..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
--Where dea.continent is not null

Select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from covid..CovidDeaths dea
Join covid..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
from PercentPopulationVaccinated