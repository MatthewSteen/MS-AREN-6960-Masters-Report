# Proposal

## Scope

* 1 building type
  * CBECS most common: office, 1000-5000 ft2, built 1980-1989
* 16 climate zones
* 10 technologies, identified by independent study
* 160 combinations (not including optimizations)

## Approach

1. Determine model output(s) needed to quantify grid services (timestep, hourly, annual, etc.)
2. Determine source for energy cost and method to automate
   * [OpenEI Utility Rate Database](https://openei.org/wiki/Utility_Rate_Database)
     * [API](https://openei.org/services/doc/rest/util_rates/?version=3)
   * ~~EIA state average rates~~
3. Develop and test [OpenStudio Measures](http://nrel.github.io/OpenStudio-user-documentation/getting_started/about_measures/) for each technology
4. Develop data processing tool(s), probably in Python
5. Optimization using [OpenStudio's Parametric Analysis Tool (PAT)](http://nrel.github.io/OpenStudio-user-documentation/reference/parametric_analysis_tool_2/)