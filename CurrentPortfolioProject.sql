-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null

--Looking at total_cases vs total_deaths
-- Shows likelihood of dying if you get Covid
Select location, date, total_cases, total_deaths, nullif(total_deaths, 0)/nullif(total_cases, 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by location


--Looking at total_cases vs population
--Percent of population that got Covid

Select location, date, population, total_cases, (nullif(total_cases, 0)/population)*100 as PopulationInfected
From PortfolioProject..CovidDeaths
order by location

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PopulationInfected desc

---Break things down by continent

--Show Countries with the Highest Death Count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by continent
order by TotalDeathCount desc
--Data is showing null for continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc
--Null for continent means that location is going to be a generalization of another factor other than their actual location. (Income level, World, European Union, and Continents.

--Adjusted code to show DeathCount by continent only
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers Death Percentage
Select date, sum(new_cases) as cases, sum(new_deaths) as deaths, sum(nullif(new_deaths, 0))/sum(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date

-- Vaccinations by location and date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

-- Vaccinations by date and location with a rolling count for total vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as rolling_vacinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

--Use CTE  to see percent of poupulation vaccinated by date
With pop_vac (continent, location, date, population, new_vaccinations, rolling_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as rolling_vacinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_vaccinated/nullif(population,0))*100 as percent_vac_pop
from pop_vac

--Creating View to store data for later visualizations
Create View pop_vac as
With pop_vac (continent, location, date, population, new_vaccinations, rolling_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as rolling_vacinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_vaccinated/nullif(population,0))*100 as percent_vac_pop
from pop_vac
