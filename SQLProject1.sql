--Total Cases v Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject1..CovidDeaths
where location like '%states%'
order by 1,2

--Looking @ total cases v population
--Shows what percentage of the population contracted COVID
select location, date, total_cases, population, (total_cases/population)*100 as PercentInfected
from portfolioproject1..CovidDeaths
where location like '%states%'
order by 1,2

--What countries have highest infection rate compared to population?

select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
from portfolioProject1..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--How many people actually died
select location, max(cast(total_deaths as int)) as NumberOfDeaths
from portfolioProject1..CovidDeaths
where continent is not null
group by location
order by NumberOfDeaths desc

-- Which continents have the highest death counts?
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject1..coviddeaths
Where continent is null
group by location
order by totaldeathcount desc


--Global Number Breakdown

Select date,sum(new_cases) as newdailycases ,SUM(cast(new_deaths as int)) as newdailydeaths, sum(cast (new_deaths as int)) / Sum(new_cases)*100 as deathpercentage
from PortfolioProject1..coviddeaths
where continent is not null
Group by date
order by 1,2


--Total population v vaccinations (base query)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
 --Problem arises because we can't call back on the RollingPeople Vaccinated
from portfolioproject1..CovidDeaths dea 
JOIN portfolioproject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--With CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject1..CovidDeaths dea 
JOIN portfolioproject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (rollingpeoplevaccinated/population)*100
from Popvsvac


--With Temp Table
--That will always ensure you can re-create the table when necessary
Drop table if exists #PercentPopulationVaccianted
Create Table #PercentPopulationVaccianted
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccianted

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --Problem arises because we can't call back on the RollingPeople Vaccinated
from portfolioproject1..CovidDeaths dea 
JOIN portfolioproject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccianted



--Creating View to store data for later viz

Create View PercentPopulationVaccianted as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --Problem arises because we can't call back on the RollingPeople Vaccinated
from portfolioproject1..CovidDeaths dea 
JOIN portfolioproject1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccianted