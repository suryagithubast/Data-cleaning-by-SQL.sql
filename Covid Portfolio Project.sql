select *
from [Portfolio projects]..CovidDeaths
order by 3,4


select *
from [Portfolio projects]..CovidVaccinations
order by 3,4


--select location,date,total_cases,new_cases,total_deaths,population
--from [Portfolio projects]..CovidDeaths
--order by 1,2

--Looking at Total Cases VS Total Deaths
--liklihood of dying in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 as Death_Percentage
from [Portfolio projects]..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at Total Cases VS Population
--show what percentage of population got affected by covid

select location,date,population,total_cases,(total_cases/population)*100 as Affected_Persons
from [Portfolio projects]..CovidDeaths
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,Max(total_cases) as Highest_Infection_count,Max((total_cases/population))*100 as Highest_Affected_Persons
from [Portfolio projects]..CovidDeaths
group by location,population
order by Highest_Affected_Persons desc

--Looking at countries with highest death count per population

select location,MAX(cast(total_deaths as int)) as Total_Death_Count
from [Portfolio projects]..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc


--Breakdown by Continent
--Showing continent with highest deat count per population

select continent,MAX(cast(total_deaths as int)) as Total_Death_Count
from [Portfolio projects]..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc

--Global Numbers of covid deaths

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from [Portfolio projects]..CovidDeaths
where continent is not null 
order by 1,2


--Global Numbers of covid deaths by date

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from [Portfolio projects]..CovidDeaths
where continent is not null 
group by date
order by 1,2


--Looking at Total Population VS Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio projects]..CovidDeaths dea
join [Portfolio projects]..CovidVaccinations vac
     on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null and dea.location like '%ba%'
order by 2


--Use CTE

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio projects]..CovidDeaths dea
join [Portfolio projects]..CovidVaccinations vac
     on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null 
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac

--Temp Table

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
From [Portfolio projects]..CovidDeaths dea
Join [Portfolio projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

---- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio projects]..CovidDeaths dea
Join [Portfolio projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
----where dea.continent is not null 
