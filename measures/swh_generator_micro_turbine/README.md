

###### (Automatically generated documentation)

# Generator Micro Turbine

## Description
TODO

## Modeler Description
This OpenStudio measure adds a `GeneratorMicroTurbineHeatRecovery` object to the supply side of plant loop with a water heater. The micro turbine provides electricity generation and service water heating through exhaust air heat recovery. This object is translated to the EnergyPlus object `Generator:MicroTurbine` for simulation, which is a Capstone C65 from the EnergyPlus `HeatRecoveryPlantLoopAuto.idf` example file (and others). The measure code and topology are based on https://github.com/NREL/OpenStudio-resources/blob/develop/model/simulationtests/generator_microturbine.rb. The topology differs from the EnergyPlus example file because OpenStudio does not currently allow a water heater object on the same side of two different plant loops.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Plant Loop Name

**Name:** plant_loop_name,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Generator Operation Scheme Type
ElectricLoadCenter:Distribution
**Name:** generator_operation_scheme_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Demand Limit Scheme Purchased Electric Demand Limit (W)
Generator Operation Scheme Type = DemandLimit
**Name:** demand_limit,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Track Schedule Name Scheme Schedule Name
Generator Operation Scheme Type = TrackSchedule
**Name:** track_schedule_name,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Output Variables
GeneratorMicroTurbine, GeneratorMicroTurbineHeatRecovery, ElectricLoadCenterDistribution
**Name:** output_variables_bool,
**Type:** Boolean,
**Units:** ,
**Required:** false,
**Model Dependent:** false




