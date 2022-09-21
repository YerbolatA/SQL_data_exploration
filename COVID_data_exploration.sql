select * from `Covid.CovidDeaths`
where continent is not null
order by 1,2;
 
select * from `Covid.CovidDeaths`
where  location='Albania'
order by 4;


--Select data that we are goig to be using 
select location, date, total_cases, total_deaths, population 
from `Covid.CovidDeaths`
where continent is not null
order by 1,2 ;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,round((total_deaths/total_cases)*100,2) as DeathsPercentage,  population from `Covid.CovidDeaths`
where continent is not null 
--and  location like 'Kaz%' 
order by 1,2 ;

--Looking at Total Cases vs Population 
--Shows what Percentage of population got Covid
select location, date,population, total_cases, round((total_cases/population)*100,2) as PercentPopulationInfected from `Covid.CovidDeaths`
where continent is not null
--and  location like 'Kaz%'
order by 1,2 ;

--Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max(round((total_cases/population)*100,2)) as PercentPopulationInfected from `Covid.CovidDeaths`
where continent is not null
--and  location like 'Kaz%'
group by location, population
order by PercentPopulationInfected desc;

--Showing countries with Highest Deaths Count per Population
select location,max(total_deaths) as HighestDeathsCount from `Covid.CovidDeaths`
where continent is not null
--and location like 'Kaz%'
group by location
order by HighestDeathsCount desc;

 --Let's break things down by continent 
 --Showing continents with the Highest Deaths per Population
select continent,max(total_deaths) as HighestDeathsCount from `Covid.CovidDeaths`
where continent is not null
--and location like 'Kaz%'
group by continent 
order by HighestDeathsCount desc;

--Global numbers 
select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, round(sum(new_deaths)/sum(new_cases)*100,2) as DeathsPercentage from `Covid.CovidDeaths`
where continent is not null
--group by date
Order by 1,2 ;

--Looking at Total Population  Vs Vaccinated 
--with CTE Rolling people vaccinated per Population (percentageVaccinated)
with PopVSvac 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from `Covid.CovidDeaths` dea
join `Covid.CovidVaccinations` vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null )
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated from PopVSvac;

--Temp table
create temp table PercentPopulationVaccinated as 
(
  with PopVSvac 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from `Covid.CovidDeaths` dea
join `Covid.CovidVaccinations` vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated from PopVSvac order by 2,3);

-- creating view to store data for visualizations 

create view Covid.PercentPopulationVaccinated as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from `Covid.CovidDeaths` dea
join `Covid.CovidVaccinations` vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
);