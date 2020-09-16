

###### (Automatically generated documentation)

# Generator Micro Turbine

## Description
TODO

## Modeler Description
This measure adds an OpenStudio GeneratorMicroTurbineHeatRecovery object (EnergyPlus object Generator:MicroTurbine) to the supply side of a plant loop with a WaterHeater object. The GeneratorMicroTurbine is the Capstone C65 from the EnergyPlus HeatRecoveryPlantLoopAuto.idf example file (and others), which generates electric energy for the building and waste thermal energy that is used for service hot water. The code and topology is based on https://github.com/NREL/OpenStudio-resources/blob/develop/model/simulationtests/generator_microturbine.rb. The topology differs from the example file because OpenStudio does not allow WaterHeater objects on the same side of two different plant loops.

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




