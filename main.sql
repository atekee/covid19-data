--Select Data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2;


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in the United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2;


--Looking at the Total Cases vs Population
--Shows what percentage of population infected with Covid
Select location, date, population, total_cases, (total_cases/population)*100 as percent_pop_infected
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
Order by 1,2;


--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as percent_pop_infected
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
Order by percent_pop_infected desc;


--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null -- if null, it means that the location is a continent
Group by location
Order by total_death_count desc;


--BREAKING THINGS BY CONTINENT
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
Order by total_death_count desc;


--Showing Continents with the Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order by total_death_count desc;


--GLOBAL NUMBERS
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
Order by 1,2;


--Looking at Total Population vs Vaccinations
select *
From PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date;


--Looking at Total Population vs Vaccinations
--Shows Percentage of Population that has received at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--rolling_people_vaccinated/population*100 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


--Using CTE to Perfom Calculation Partition By in previous query
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
from popvsvac;


--Using Temp Table to perfom Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
--order by 1,2,3

select * , (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated;


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated_ as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
