SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
      ,[new_tests]
      ,[total_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
      ,[new_tests_smoothed_per_thousand]
      ,[positive_rate]
      ,[tests_per_case]
      ,[tests_units]
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated]
      ,[new_vaccinations]
      ,[new_vaccinations_smoothed]
      ,[total_vaccinations_per_hundred]
      ,[people_vaccinated_per_hundred]
      ,[people_fully_vaccinated_per_hundred]
      ,[new_vaccinations_smoothed_per_million]
      ,[stringency_index]
      ,[population]
      ,[population_density]
      ,[median_age]
      ,[aged_65_older]
      ,[aged_70_older]
      ,[gdp_per_capita]
      ,[extreme_poverty]
      ,[cardiovasc_death_rate]
      ,[diabetes_prevalence]
      ,[female_smokers]
      ,[male_smokers]
      ,[handwashing_facilities]
      ,[hospital_beds_per_thousand]
      ,[life_expectancy]
      ,[human_development_index]
  FROM [PortfolioProjec
  tPavithran].[dbo].[CovidDeaths$]

  SELECT * 
  FROM ..CovidDeaths$
  WHERE continent is not null
  ORDER BY 3,4

  --SELECT *
  --FROM..CovidVaccinations$
  --ORDER BY 3,4

  --SELECT Location, date, total_cases, new_cases, total_deaths, population
  --from PortfolioProjectPavithran..CovidDeaths$
  --ORDER BY 1,2

  -- LOOKING AT TOTAL CASES VS  TOTAL DEATHS

  --SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
  --FROM PortfolioProjectPavithran..CovidDeaths$
  --ORDER BY 1,2

  SELECT location, date, total_cases, population, (total_cases/population)*100 as Count_percentage
  FROM PortfolioProjectPavithran..CovidDeaths$
  ORDER BY 1,2
  
  SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Count_Percentage
  FROM PortfolioProjectPavithran..CovidDeaths$
  --WHERE location like '%states%'
  GROUP BY Location, population
  ORDER BY Count_Percentage DESC

  --highest death counts with population
  SELECT Location, MAX(cast(total_deaths as int)) as totaldeaths_counts
  FROM PortfolioProjectPavithran..CovidDeaths$
  --WHERE location like '%states%'
  where location is not null
  GROUP BY Location
  ORDER BY totaldeaths_counts DESC

  -- lets break thngs down by continent
  SELECT continent, MAX(cast(total_deaths as int)) as totaldeaths_counts
  FROM PortfolioProjectPavithran..CovidDeaths$
  --WHERE location like '%states%'
  where location is not null
  GROUP BY continent
  ORDER BY totaldeaths_counts DESC

  -- showing  continents with the highest death count per population

  SELECT continent, MAX(cast(total_deaths as int)) as totaldeaths_counts
  FROM PortfolioProjectPavithran..CovidDeaths$
  --WHERE location like '%states%'
  where location is not null
  GROUP BY continent
  ORDER BY totaldeaths_counts DESC

  --global number
  SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(New_deaths as int))/SUM(New_cases)*100 as Count_percentage
  FROM PortfolioProjectPavithran..CovidDeaths$
  --WHERE location '%states%'
  WHERE continent is not null
  GROUP BY date
  ORDER BY 1,2


-- looking at Total Population vs Vaccination
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, (RollingpeopleVaccinated/population)*100
  FROM PortfolioProjectPavithran..CovidDeaths$ dea
  JOIN  PortfolioProjectPavithran..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  ORDER BY 1,2,3

  -- use cte
  With popvsVac (contienent, location, date, population, new_vaccination,  RollingPeopleVaccinated)
  as
  (

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  FROM PortfolioProjectPavithran..CovidDeaths$ dea
  JOIN  PortfolioProjectPavithran..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  --ORDER BY 1,2,3
  )
  Select *, (RollingPeopleVaccinated/population)*100
  from popvsVac

  --Temp table
  DROP Table if exists #PercentPopulationVaccinated
  
  CREATE TABLE #PercentPopulationVaccinated
  (
  Contienent nvarchar(255),
  loacation nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccination numeric,
  RollingPeopleVaccinated numeric
  )

  Insert Into
  Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  FROM PortfolioProjectPavithran..CovidDeaths$ dea
  JOIN  PortfolioProjectPavithran..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  --WHERE dea.continent is not null
  --ORDER BY 1,2,3
  
  Select *, (RollingPeopleVaccinated/population)*100
  from #PercentPopulationVaccinated

  -- Create view  to store data for later visulazation
  Create view #PercentPopulationVaccinated as 
  Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  FROM PortfolioProjectPavithran..CovidDeaths$ dea
  JOIN  PortfolioProjectPavithran..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 1,2,

 Select  *
 From  #PercentPopulationVaccinated