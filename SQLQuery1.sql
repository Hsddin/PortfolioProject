Select *
From CovidDeaths
where continent is not null
order by 3,4


--Select *
--From CovidVaccinations
--order by 3,4

--select Data we will be using

Select location,date,total_cases, new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

Select location, date, total_cases , total_deaths , (total_deaths/total_cases)*100 as death_percentages
from CovidDeaths
order by 1,2
-- Deaths in the U.S
Select Location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
order by 1,2

-- totalcases vs population
-- shows that % has Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as Percentageofpopulationinfected
From CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at countrys with the highest infection rate compared to population

Select Location, population, MAX(total_cases) as highestinfectioncount , MAX((total_cases/population))*100 as persentofpopulationinfected
From CovidDeaths
--Where location like '%states%'
group by location, population
order by persentofpopulationinfected desc


--Breaking down by continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathsCount
from CovidDeaths
where continent is  null
group by continent
order by  TotalDeathsCount desc




--Showing countrires with the higest count per population
Select Location, Max(cast(total_deaths as int)) as TotalDeathsCount
from CovidDeaths
--Where location like '%states%'
where continent is not null
group by location
order by  TotalDeathsCount desc

-- Showing the continents with the highest death count

Select continent, Max(cast(total_deaths as int)) as TotalDeathsCount
from CovidDeaths
where continent is  null
group by continent
order by  TotalDeathsCount desc

--Global NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , Sum(cast(new_deaths as int))/SUM
	(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
group by date
--Group By Date
order by 1,2

--Looking At Total Population Vs Vactions

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
, (rollingpeoplevaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
   on dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
	order by 2,3



	--Use CTE
	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp tabel

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view for later Vis

create view percentagepopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


