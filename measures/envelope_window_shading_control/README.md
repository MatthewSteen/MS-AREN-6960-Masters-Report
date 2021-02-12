

###### (Automatically generated documentation)

# Window Shading Control

## Description
TODO

## Modeler Description
This OpenStudio measure adds `ShadingControl` objects to the model by specifying a Construction with shading. The `ShadingControl` objects are translated to EnergyPlus `WindowShadingControl` objects prior to simulation. The Construction must be a detailed fenestration, i.e. be composed of `WindowMaterialGlazing` rather than `WindowMaterialSimpleGlazingSystem`. Specifying a Material with a shading device is not currently supported and not all Shading Types are currently supported.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Shading Type

**Name:** shading_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Construction with Shading Name

**Name:** construction,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Shading Control Type

**Name:** shading_control_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Schedule Name

**Name:** schedule,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Setpoint
W/m2, W, or C
**Name:** setpoint,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Shading Device Material Name
(NOT SUPPORTED)
**Name:** material,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### SubSurface Type

**Name:** subsurface_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Add Output Variables?

**Name:** output_variables_bool,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false




