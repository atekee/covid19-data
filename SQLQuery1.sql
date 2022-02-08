Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2


--Looking at Total cases vs cotal Deaths
--Shows likelihood of dying if you contract covid in united states
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2


--Looking at the total cases vs population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as percent_pop_infected
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2


--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as percent_pop_infected
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
Order by percent_pop_infected desc


--Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null -- if null, it means that the location is a continent
Group by location
Order by total_death_count desc


--Breaking things down by continent
--1
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
Order by total_death_count desc


--Showing continets with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order by total_death_count desc


--Global Numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
Order by 1,2


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
Order by 1,2


--Joining both tables
--Looking at total population vs vaccination
select *
From PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated,
rolling_people_vaccinated/population*100

From PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select * , (rolling_people_vaccinated/population)*100
from popvsvac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select * , (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated


--Creating views to store data for later visualizations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated
