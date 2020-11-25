

###### (Automatically generated documentation)

# Dehumidifier Desiccant System

## Description
TODO

## Modeler Description
This EnergyPlus measure adds a `Dehumidifier:Desiccant:System` on the selected air stream (outdoor air or supply air) of one or all air loops in the model. The measure works by replacing a surrogate object in the desired location in the air stream with the desiccant dehumidifier system. A setpoint manager must be present on the outlet node of the surrogate object to control humidity. If the system will be added to the supply air stream, the surrogate object must be directly downstream of a cooling coil, which will be the companion cooling coil to the desiccant system. The measure uses objects from the `DesiccantDehumidifierWithCompanionCoil.idf` EnergyPlus example file, which are included in the resources folder.

## Measure Type
EnergyPlusMeasure

## Taxonomy


## Arguments


### Location

**Name:** location,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Choose Air Loop(s)

**Name:** air_loop_choice,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### String Included in Surrogate Object(s) Name
word included in the surrogate object(s) name
**Name:** string,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false




