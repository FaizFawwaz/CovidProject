select *
from covid..CovidDeaths
order by 3,4

--select *
--from covid..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from covid..CovidDeaths
order by 1,2

--Death percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid..CovidDeaths
where location like 'malay%'
order by 1,2

--Percentage Infected

select location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
from covid..CovidDeaths
where location like 'malay%'
order by 1,2 

--Population infected

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected 
from covid..CovidDeaths
--where location like 'malay%'
group by location, population
order by PercentagePopulationInfected desc

--Country highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths
--where location like 'malay%'
where continent is not null
group by location
order by TotalDeathCount desc

--select location, max(cast(total_deaths as int)) as TotalDeathCount
--from covid..CovidDeaths
----where location like 'malay%'
--where continent is null
--group by location
--order by TotalDeathCount desc

--Continent death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covid..CovidDeaths
--where location like 'malay%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global cases

select sum(new_cases) as SumNewCases, sum(cast(new_deaths as int)) as SumNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid..CovidDeaths
where continent is not null
--group by date
order by 1,2


select date, sum(new_cases) as SumNewCases, sum(cast(new_deaths as int)) as SumNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from covid..CovidDeaths
where continent is not null
group by date
order by 1,2


--Join table

select *
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Vaccine population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as CommulativePeopleVaccinated 
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (continent, location, date, population, new_vaccinations, CommulativePeopleVaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as CommulativePeopleVaccinate 
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (CommulativePeopleVaccinated/population)*100
from PopvsVac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CommulativePeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as CommulativePeopleVaccinate 
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
select *, (CommulativePeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--create view for later

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as CommulativePeopleVaccinate 
from covid..CovidDeaths dea
join covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated
