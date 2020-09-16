

###### (Automatically generated documentation)

# Dehumidifier Desiccant System

## Description
TODO

## Modeler Description
This measure adds Dehumidifier:Desiccant:System (DDS) object(s) to the outdoor air (OA) or supply air (SA) stream of one or all air loops by replacing a surrogate object (e.g. CoilHeatingGas). 
    In either case, a SetpointManager must be on the outlet node of the surrogate object to control humidity.
    If the DDS will be added to the SA stream, the surrogate object must be directly downstream of a cooling coil, which will be the Companion Cooling Coil to the DDS.
    The measure uses objects from the EnergyPlus example file DesiccantDehumidifierWithCompanionCoil.idf, which are included in the resources folder.

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




