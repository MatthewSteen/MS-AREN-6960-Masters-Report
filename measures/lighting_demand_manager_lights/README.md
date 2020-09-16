

###### (Automatically generated documentation)

# Demand Manager Lights

## Description
TODO

## Modeler Description
This measure will add a DemandManager:Lights object to the EnergyPlus model. The measure will also add a DemandManagerAssignmentList object if one is not present in the model. If one is, it will add the DemandManager:Lights to the existing DemandManagerAssignmentList. Argument default values come from the 5ZoneAirCooledDemandLimiting.idf EnergyPlus example file.

## Measure Type
EnergyPlusMeasure

## Taxonomy


## Arguments


### Availability Schedule Name

**Name:** availability_schedule_name,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Limit Control

**Name:** limit_control,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Minimum Limit Duration {minutes}

**Name:** minimum_limit_duration,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Maximum Limit Fraction

**Name:** maximum_limit_fraction,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Selection Control

**Name:** selection_control,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Rotation Duration {minutes}
Selection Control = RotateMany or RotateOne
**Name:** rotation_duration,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Lights Name

**Name:** lights_name,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Meter Name

**Name:** meter_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Demand Limit Schedule Name

**Name:** demand_limit_schedule_name,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Demand Limit Safety Fraction

**Name:** demand_limit_safety_fraction,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Billing Period Schedule Name

**Name:** billing_period_schedule_name,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Peak Period Schedule Name

**Name:** peak_period_schedule_name,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Demand Window Length {minutes}

**Name:** demand_window_length,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Demand Manager Priority

**Name:** demand_manager_priority,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false




