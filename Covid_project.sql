select * 
from covid_project..CovidDeaths
order by 3,4

--select * 
--from covid_project..CovidVaccinations
--order by 3,4

-- Select data that we are going to be usig

select location, date, total_cases, new_cases, total_deaths, population 
from covid_project..CovidDeaths
order by 1,2


--- Looking at total_cases vs total_deaths
-- shows Likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_project..CovidDeaths
where location like '%pak%'
order by 1,2


-- Looking at total_cases vs population
--- it shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage_of_pop
from covid_project..CovidDeaths
where location like '%pak%'
order by 1,2

-- Looking at countries with Highest Infection Rate comapared to population

select location, population, max(total_cases) as Highest_Infection_Count, max(total_cases/population)*100 as 
	Infected_percentage_of_pop 
from covid_project..CovidDeaths
group by location, population
order by Infected_percentage_of_pop desc

--- Showing Countries with Highest Death Count per Population

select location,  max(cast(total_deaths as int)) as Total_Death_Count
	from covid_project..CovidDeaths
	where continent is not null
group by location
order by Total_Death_Count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--- Showing continent with the Highest death count per population 


select continent,  max(cast(total_deaths as int)) as Total_Death_Count
	from covid_project..CovidDeaths
	where continent is not null
group by continent
order by Total_Death_Count desc


--- GLOBAL NUMBERS

select  sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from covid_project..CovidDeaths
where continent is not null
--group by date
order by 1,2




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_project..CovidDeaths dea
Join covid_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_project..CovidDeaths dea
Join covid_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_project..CovidDeaths dea
Join covid_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_project..CovidDeaths dea
Join covid_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
















