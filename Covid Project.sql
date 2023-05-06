select * from PortfoilioProject..CovidDeaths
order by 3,4


select * from PortfoilioProject..CovidVaccinations
order by 3,4

--select the data to be calculated 
select location,date,total_cases,new_cases,total_deaths,population
from PortfoilioProject..CovidDeaths
order by 1,2

--total deaths vs total cases 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfoilioProject..CovidDeaths
where location like '%states%'
order by 1,2

--total cases vs population 
select location,date,total_cases,population,(total_cases/population)*100 as CasePercentage
from PortfoilioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Highest infection rates per country
select location,max(total_cases) as HighestInfectionCount,population,round(max((total_cases/population))*100,2) as HighestInfectionRate
from PortfoilioProject..CovidDeaths
where continent is not null
group by location,population
order by HighestInfectionRate desc

--Total Death Count Per Country 
select location,max(cast(total_deaths as int)) as TotalDeathsCount
from PortfoilioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount desc

--Highest death count/population rate per country 
select location,max(cast(total_deaths as int)) as TotalDeaths,population,round((max(cast(total_deaths as int))/population)*100,5)as HighestDeathRate
from PortfoilioProject..CovidDeaths
where continent is not null
group by location,population
order by HighestDeathRate desc

--Total Death Count per continent
select location,max(cast(total_deaths as int)) as TotalDeathsCount
from PortfoilioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathsCount desc

--Severe Cases rate 
select continent,location,date,total_cases, icu_patients, (icu_patients/total_cases) as ICUPercentagetoTotalCases
from PortfoilioProject..CovidDeaths
order by 2,3

--Global Numbers per day
select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfoilioProject..CovidDeaths
where continent is not null
group by date
order by 1

--Global Numbers in total
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfoilioProject..CovidDeaths
where continent is not null
order by 1


--Total population VS Vaccinations
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as Total_vaccinations_to_date
from PortfoilioProject..CovidDeaths cd
join PortfoilioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3



--Vaccinations to population rate 
--Use CTE
with VACvsPOP (continent, location,date,population,new_vaccinations,Total_vaccinations_to_date) 
as 
(select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as Total_vaccinations_to_date
from PortfoilioProject..CovidDeaths cd
join PortfoilioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null) 
select*, (Total_vaccinations_to_date/population)*100 as Percentageofvaccinatedpopulation
from VACvsPOP
order by 2,3


--Use Temp table
Drop table if exists Percentageofvaccinatedpopulation
create table Percentageofvaccinatedpopulation
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Total_vaccinations_to_date numeric
)

Insert into Percentageofvaccinatedpopulation
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as Total_vaccinations_to_date
from PortfoilioProject..CovidDeaths cd
join PortfoilioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

select *, (Total_vaccinations_to_date/population)*100 as Percentageofvaccinatedpopulation
from Percentageofvaccinatedpopulation
order by 2,3


--Create Views for visulization 
use PortfoilioProject
go
create view TotalDeathsCountperContinent as
select location,max(cast(total_deaths as int)) as TotalDeathsCount
from PortfoilioProject..CovidDeaths
where continent is null and location not in ('World','European Union','International')
group by location

create view GlobalNumbersperDay as
select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from PortfoilioProject..CovidDeaths
where continent is not null 
group by date


create view TotalVaccinationtoDateperCountry as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as Total_vaccinations_to_date
from PortfoilioProject..CovidDeaths cd
join PortfoilioProject..CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

use PortfoilioProject
go
create view ICUpercentagetoTotalCases as
select continent,location,date,total_cases, icu_patients, (icu_patients/total_cases) as ICUPercentagetoTotalCases
from PortfoilioProject..CovidDeaths
where continent is not null


create view TotalInfectionpercountry as
select location,max(total_cases) as HighestInfectionCount,population,round(max((total_cases/population)),2) as HighestInfectionRate
from PortfoilioProject..CovidDeaths
where continent is not null
group by location,population 
 

