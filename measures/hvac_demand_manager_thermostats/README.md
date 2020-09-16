

###### (Automatically generated documentation)

# Demand Manager Thermostats

## Description


## Modeler Description


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

### Reset Control

**Name:** reset_control,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Minimum Reset Duration {minutes}

**Name:** minimum_reset_duration,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Maximum Heating Setpoint Reset {C}

**Name:** maximum_heating_setpoint_reset,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Maximum Cooling Setpoint Reset {C}

**Name:** maximum_cooling_setpoint_reset,
**Type:** Double,
**Units:** ,
**Required:** true,
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

### Thermostat Name

**Name:** thermostat_name,
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




