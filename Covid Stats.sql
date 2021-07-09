Use PortfolioProject

Select *
From  CovidDeaths
--where location = 'canada'
--Group By location
Order By 1,2;

-- Looking at TotalCases vs TotalDeaths in my actual country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
From  CovidDeaths
Where location like '%states%'
Order By 1,2;

-- Looking at TotalCases vs Population in my actual country
-- Shows what porcentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From  CovidDeaths
Where location = 'United States'
Order By 1,2;

-- Looking at countries with the highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From  CovidDeaths
-- Where
Group By location, population
Order By PercentagePopulationInfected Desc

-- Looking at countries with the highest deaths count per population

Select location, Max(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
Where continent Is Not NULL
Group By location
Order By TotalDeaths Desc;

-- Looking at deaths per continents 

Select continent, Max(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
Where continent Is not NULL
Group By continent
Order By TotalDeaths Desc;

-- Showing the total of people whose are been vaccinated per country

Select Distinct dea.location, Max(Cast(vac.total_vaccinations as int)) As TotalVaccinations
From CovidDeaths As dea
Join CovidVaccinations As Vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location != 'World' And dea.location != 'International' and dea.continent is not null
Group By dea.location
Order By TotalVaccinations desc

--GLOBAL NUMBERS

Select  Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int)) as TotalDeaths, Sum(Cast(new_deaths as int)) / Sum(new_cases) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
--Group By date
Order By 1,2

-- Looking at total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / dea.population) * 100) as VaccinatedPercentage -- We can't use the column RollingPeopleVaccinated in the next column declaration, we must use CTE or TempTable
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.date = vac.date
	And dea.location = vac.location
Where dea.continent is not null
Order By 2,3

-- PopVSVac continuation: Using CTE

With PopVsVacCTE (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated) 
as (
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
	From CovidDeaths dea
	Join CovidVaccinations vac
		On dea.date = vac.date
		And dea.location = vac.location
	Where dea.continent is not null
	)
	Select *, (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
	From PopVsVacCTE

-- PopVSVac continuation: Using Temp Table

Drop Table If Exists #PopVsVac
Create Table #PopVsVac (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	NewVaccinations numeric,
	RollingPeopleVaccinated numeric
	)

Insert Into #PopVsVac
	Select dea.continent, dea.location, dea.date, Convert(bigint, dea.population), Cast(vac.new_vaccinations as bigint),
	Sum(Convert(float, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
	From CovidDeaths dea
	Join CovidVaccinations vac
		On dea.date = vac.date
		And dea.location = vac.location
	--Where dea.continent is not null
	Order By 2,3

Select *, (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
	From #PopVsVac


---------- VIEWS --------------------

-- Deaths per Continent View

Create View DeathPerContinent as
Select location, Max(cast(total_deaths as int)) as TotalDeaths
From CovidDeaths
Where continent Is Not NULL
Group By location


Create View PercentagePeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) Over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
	From CovidDeaths dea
	Join CovidVaccinations vac
		On dea.date = vac.date
		And dea.location = vac.location
	Where dea.continent is not null
