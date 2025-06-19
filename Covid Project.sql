Select iso_code, continent, location
From Covid.coviddeath
 where continent is null
group by iso_code, location, continent
order by continent;


-- select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from coviddeath
where continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeath
where location like '%states%'
order by location, date;

-- looking at total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from coviddeath
where location like '%states%'
order by 1, 2;

-- looking at countries with highest infection rate compared to population

Select location, date, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
from coviddeath
group by location, date
order by percentpopulationinfected;


-- this step was to alter the date from text to date type

SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'coviddeath'and column_name = 'date';  -- Standard for most DBs

SELECT date
FROM coviddeath
WHERE STR_TO_DATE(date, '%m/%d/%y') IS NULL AND date IS NOT NULL;

ALTER TABLE coviddeath ADD COLUMN date_converted DATE;

SET SQL_SAFE_UPDATES = 0;


UPDATE coviddeath
SET date_converted = STR_TO_DATE(date, '%m/%d/%y');
SET SQL_SAFE_UPDATES = 1;

SELECT DATE_FORMAT(date_converted, '%m/%d/%Y') AS formatted_date
FROM coviddeath;

ALTER TABLE coviddeath DROP COLUMN date_formatted;

ALTER TABLE coviddeath DROP COLUMN date;

ALTER TABLE coviddeath RENAME COLUMN date_converted TO date;

-- for covid vaccination table

SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'coviddeath'and column_name = 'date';  -- Standard for most DBs

SELECT date
FROM covidvaccination
WHERE STR_TO_DATE(date, '%m/%d/%y') IS NULL AND date IS NOT NULL;

ALTER TABLE covidvaccination ADD COLUMN date_converted DATE;

SET SQL_SAFE_UPDATES = 0;


UPDATE covidvaccination
SET date_converted = STR_TO_DATE(date, '%c/%e/%Y');
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE covidvaccination DROP COLUMN date;

ALTER TABLE covidvaccination RENAME COLUMN date_converted TO date;

-- showing countries with highest death count per population
-- CAST(... AS SIGNED) converts string or text-based numbers into integers.

select location, max(cast(total_deaths as signed)) as totaldeathcount
from coviddeath
where continent is null
group by location
order by totaldeathcount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population.

select continent, max(cast(total_deaths as signed)) as totaldeathcount
from coviddeath
where continent is not null
group by continent
order by totaldeathcount desc;

-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths,sum(cast(new_deaths as signed))/sum(new_cases)*100 as DeathPercentage
from coviddeath
where continent is not null
group by date
order by 1,2;

-- total death percent as per total cases
select sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths,sum(cast(new_deaths as signed))/sum(new_cases)*100 as DeathPercentage
from coviddeath
where continent is not null
order by 1,2;

-- join

-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath dea
join covidvaccination vac
	on dea.location=vac.location
    and dea.date= vac.date
where dea.continent is not null
order by 2,3;

-- use CTE

With PopvsVac ( continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath dea
join covidvaccination vac
	on dea.location=vac.location
    and dea.date= vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as percentagepeoplevaccinated
from PopvsVac;

-- Temp Table

DROP TEMPORARY TABLE IF EXISTS PercentPeopleVaccinated;

Create Temporary Table PercentPeopleVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
);
Insert into PercentPeopleVaccinated
select dea.continent, dea.location, str_to_date(dea.date, '%c/%e/%y') as date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath dea
join covidvaccination vac
	on dea.location=vac.location
    and dea.date= vac.date;
    
select *, (rollingpeoplevaccinated/population)*100 as percentagepeoplevaccinated
from PercentPeopleVaccinated;

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from coviddeath dea
join covidvaccination vac
	on dea.location=vac.location
    and dea.date= vac.date
where dea.continent is not null
order by 2,3;

select *
from percentpeoplevaccinated;

