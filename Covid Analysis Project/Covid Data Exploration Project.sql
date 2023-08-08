exec sp_columns CovidDeaths

Select *
From PortfolioProject.dbo.CovidDeaths
order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by location, date

--Death Percentage 
--total_deaths and total_cases are nvarchar types
Select location, date, total_cases, total_deaths, round((Cast(total_deaths as float)/Cast(total_cases as float))*100, 2) as death_percentage
From PortfolioProject.dbo.CovidDeaths
order by location, date

Select location, date, total_cases, total_deaths, round((Cast(total_deaths as float)/Cast(total_cases as float))*100, 2) as death_percentage
From PortfolioProject.dbo.CovidDeaths
Where location = 'Canada'
order by date

--Total cases vs population
Select location, date, total_cases, population, round((Cast(total_cases as float)/population)*100, 2) as infection_rate
From PortfolioProject.dbo.CovidDeaths
Where location = 'Canada'
order by date

--countries with highest infecction rate
Select location, max(total_cases) as highest_case_count, population, round(max((Cast(total_cases as float)/population))*100, 2) as infection_rate
From PortfolioProject.dbo.CovidDeaths
group by location, population
order by infection_rate desc

--countries with highest death count 
Select location, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
group by location
order by total_death_count desc

--continents and other groupings with highest death count 
Select location, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject.dbo.CovidDeaths
Where continent is null
group by location
order by total_death_count desc


--Global Values
Select sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths,  sum(cast(new_deaths as int))/sum(new_cases) * 100 as global_death_percentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(cast(CV.new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location, CD.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
On CD.location = CV.location
and CD.date = CV.date
Where CD.continent is not null
order by CD.location, CD.date

--CTE Common Table Expression 
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
as 
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(cast(CV.new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location, CD.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
On CD.location = CV.location
and CD.date = CV.date
Where CD.continent is not null
)

Select *, round((rolling_vaccination_count/population)*100, 2) as vaccination_percentage
From PopvsVac


--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations float,
rolling_vaccination_count float
)

Insert into #PercentPopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(cast(CV.new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location, CD.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
On CD.location = CV.location
and CD.date = CV.date
Where CD.continent is not null

Select *, round((rolling_vaccination_count/population)*100, 2) as vaccination_percentage
From #PercentPopulationVaccinated


--Creating a View
Create View PercentPopulationVaccinated as 
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, sum(cast(CV.new_vaccinations as bigint)) OVER (Partition by CD.location order by CD.location, CD.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
On CD.location = CV.location
and CD.date = CV.date
Where CD.continent is not null