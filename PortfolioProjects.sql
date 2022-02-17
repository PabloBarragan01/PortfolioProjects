-- Select data that we are going to be using

use PortfolioProject
Select Location, Date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where Location like '%states%'
order by 1,2	


-- Looking at the total cases vs the population
-- Shows what percentage of population got covid

Select Location, Date, total_cases, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where Location like '%states%'
order by 1,2


-- Looking at countries whit highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with highest death count per population

Select Location, max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not null
group by Location
order by Totaldeathcount desc


-- By continent

Select Continent, max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not null
group by Continent
order by Totaldeathcount desc


-- Showing the continent with the highest death count per population

Select Continent, max(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
where continent is not null
group by Continent
order by Totaldeathcount desc


-- Global Numbers

Select sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, (sum(cast(new_deaths as int)) / sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null

order by 1,2


-- Looking at total population vs Vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(bigint, v.new_vaccinations)) OVER(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2,3


-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopeVaccinated)
as
(select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(bigint, v.new_vaccinations)) OVER(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null)
Select *, (RollingPeopeVaccinated/Population)*100
from PopVsVac


-- USE TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where dea.continent is not null 
--order by 2,3


-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where dea.continent is not null 
--order by 2,3