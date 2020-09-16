# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class EnvelopeWindowShadingControl < OpenStudio::Measure::ModelMeasure

  # human readable name
  def name
    return 'Window Shading Control'
  end

  # human readable description
  def description
    return 'TODO'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure adds a ShadingControl object to the model by specifying a Construction with shading. Specifying a Material with a shading device is not currently supported and not all Shading Types are currently supported.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Shading Type
    shading_types = OpenStudio::StringVector.new
    shading_types << 'InteriorShade'
    # shading_types << 'ExteriorShade'
    # shading_types << 'ExteriorScreen'
    # shading_types << 'InteriorBlind'
    # shading_types << 'ExteriorBlind'
    # shading_types << 'BetweenGlassShade'
    # shading_types << 'BetweenGlassBlind'
    shading_types << 'SwitchableGlazing'
    shading_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('shading_type', shading_types, true)
    shading_type.setDisplayName('Shading Type')
    args << shading_type

    # Construction with Shading Name
    construction_handles = OpenStudio::StringVector.new
    construction_names = OpenStudio::StringVector.new
    model.getConstructions.each do |construction|
      if construction.isFenestration
        construction_handles << construction.handle.to_s
        construction_names << construction.name.to_s
      end
    end
    construction = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('construction', construction_handles, construction_names, false)
    construction.setDisplayName('Construction with Shading Name')
    args << construction

    # Shading Control Type
    shading_control_types = OpenStudio::StringVector.new
    shading_control_types << 'AlwaysOn'
    shading_control_types << 'AlwaysOff'
    shading_control_types << 'OnIfScheduleAllows'
    shading_control_types << 'OnIfHighSolarOnWindow'
    shading_control_types << 'OnIfHighHorizontalSolar'
    shading_control_types << 'OnIfHighOutdoorAirTemperature'
    shading_control_types << 'OnIfHighZoneAirTemperature'
    shading_control_types << 'OnIfHighZoneCooling'
    shading_control_types << 'OnIfHighGlare'
    shading_control_types << 'MeetDaylightIlluminanceSetpoint'
    shading_control_types << 'OnNightIfLowOutdoorTempAndOffDay'
    shading_control_types << 'OnNightIfLowInsideTempAndOffDay'
    shading_control_types << 'OnNightIfHeatingAndOffDay'
    shading_control_types << 'OnNightIfLowOutdoorTempAndOnDayIfCooling'
    shading_control_types << 'OnNightIfHeatingAndOnDayIfCooling'
    shading_control_types << 'OffNightAndOnDayIfCoolingAndHighSolarOnWindow'
    shading_control_types << 'OnNightAndOnDayIfCoolingAndHighSolarOnWindow'
    shading_control_types << 'OnIfHighOutdoorAirTempAndHighSolarOnWindow'
    shading_control_types << 'OnIfHighOutdoorAirTempAndHighHorizontalSolar'
    shading_control_types << 'OnIfHighZoneAirTempAndHighSolarOnWindow'
    shading_control_types << 'OnIfHighZoneAirTempAndHighHorizontalSolar'
    shading_control_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('shading_control_type', shading_control_types, true)
    shading_control_type.setDisplayName('Shading Control Type')
    args << shading_control_type

    # Schedule Name
    schedule_handles = OpenStudio::StringVector.new
    schedule_names = OpenStudio::StringVector.new
    model.getScheduleRulesets.each do |schedule|
      schedule_handles << schedule.handle.to_s
      schedule_names << schedule.name.to_s
    end
    schedule = OpenStudio::Measure::OSArgument.makeChoiceArgument('schedule', schedule_handles, schedule_names, false)
    schedule.setDisplayName('Schedule Name')
    args << schedule

    # Setpoint
    setpoint = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('setpoint', false)
    setpoint.setDisplayName('Setpoint')
    setpoint.setDescription('W/m2, W, or C')
    args << setpoint

    # Shading Control Is Scheduled
    # Glare Control Is Active

    # Shading Device Material Name' 
    material_handles = OpenStudio::StringVector.new
    material_names = OpenStudio::StringVector.new
    model.getShadingMaterials.each do |material|
      material_handles << material.handle.to_s
      material_names << material.name.to_s
    end
    material = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('material', material_handles, material_names, false)
    material.setDisplayName('Shading Device Material Name')
    material.setDescription('(NOT SUPPORTED)')
    args << material

    # Type of Slat Angle Control for Blinds
    # Slat Angle Schedule Name
    # Setpoint 2

    subsurface_types = OpenStudio::StringVector.new
    subsurface_types << 'ALL'
    subsurface_types << 'FixedWindow'
    subsurface_types << 'OperableWindow'
    subsurface_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('subsurface_type', subsurface_types, true)
    subsurface_type.setDisplayName('SubSurface Type')
    subsurface_type.setDefaultValue('ALL')
    args << subsurface_type

    output_variables_bool = OpenStudio::Ruleset::OSArgument.makeBoolArgument('output_variables_bool', true)
    output_variables_bool.setDisplayName('Add Output Variables?')
    output_variables_bool.setDefaultValue(false)
    args << output_variables_bool

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    shading_type = runner.getStringArgumentValue('shading_type', user_arguments)
    if runner.getOptionalWorkspaceObjectChoiceValue('construction', user_arguments, model).is_initialized
      construction = runner.getOptionalWorkspaceObjectChoiceValue('construction', user_arguments, model).get
    else
      construction = nil
    end
    shading_control_type = runner.getStringArgumentValue('shading_control_type', user_arguments)
    if runner.getOptionalWorkspaceObjectChoiceValue('schedule', user_arguments, model).is_initialized
      schedule = runner.getOptionalWorkspaceObjectChoiceValue('schedule', user_arguments, model).get
    else
      schedule = nil
    end
    if runner.getOptionalDoubleArgumentValue('setpoint', user_arguments).is_initialized
      setpoint = runner.getOptionalDoubleArgumentValue('setpoint', user_arguments).get
    else
      setpoint = nil
    end
    if runner.getOptionalWorkspaceObjectChoiceValue('material', user_arguments, model).is_initialized
      material = runner.getOptionalWorkspaceObjectChoiceValue('material', user_arguments, model).get
    else
      material = nil
    end
    subsurface_type = runner.getStringArgumentValue('subsurface_type', user_arguments)
    output_variables_bool = runner.getBoolArgumentValue('output_variables_bool', user_arguments)

    #TODO - error checking for shading type, shading control type, schedule, and setpoint combinations

    # report initial condition of model
    runner.registerInitialCondition("ShadingControl objects = #{model.getShadingControls.size}")
    
    # get construction or material object
    if construction && material
      runner.registerError('Choose EITHER a Construction OR a Material.')
      return false
    elsif construction
      construction_or_material = construction.to_Construction.get
    elsif material
      construction_or_material = material.to_Material.get
    end

    # add shading control object and set properties
    shading_control = OpenStudio::Model::ShadingControl.new(construction_or_material)
    shading_control.setShadingType(shading_type)
    shading_control.setShadingControlType(shading_control_type)
    shading_control.setSchedule(schedule.to_ScheduleRuleset.get) if schedule
    shading_control.setSetpoint(setpoint)

    # set subsurface shading control
    subsurface_count = 0
    model.getSubSurfaces.each do |subsurface|
      if subsurface.subSurfaceType.to_s == subsurface_type || subsurface_type == 'ALL'
        subsurface.setShadingControl(shading_control)
        subsurface_count += 1
      end
    end
    runner.registerAsNotApplicable("#{subsurface_type} not found in model") if subsurface_count == 0
    runner.registerInfo("SubSurfaces in model (total) = #{model.getSubSurfaces.size}")
    runner.registerInfo("SubSurfaces with Shading Control = #{subsurface_count}")

    # add output variables
    if output_variables_bool

      case shading_type
      when 'InteriorShade'
        output_variable_strings = ['Surface Shading Device Is On Time Fraction',
                                  'Surface Window Shading Device Absorbed Solar Radiation Rate',
                                  'Surface Window Shading Device Absorbed Solar Radiation Energy']
      # shading_types << 'ExteriorShade'
      # shading_types << 'ExteriorScreen'
      # shading_types << 'InteriorBlind'
      # shading_types << 'ExteriorBlind'
      # shading_types << 'BetweenGlassShade'
      # shading_types << 'BetweenGlassBlind'
      when 'SwitchableGlazing'
        output_variable_strings = ['Surface Window Switchable Glazing Switching Factor',
                                  'Surface Window Switchable Glazing Visible Transmittance']
      end

      output_variable_strings.each do |str|
        obj = OpenStudio::Model::OutputVariable.new(str, model)
        obj.setReportingFrequency('hourly')
        # outputVariable.setKeyValue(key_value)
        runner.registerInfo("adding OutputVariable = #{str}")
      end

    end

    # report final condition of model
    runner.registerFinalCondition("ShadingControl objects = #{model.getShadingControls.size}")

    return true

  end

end

# register the measure to be used by the application
EnvelopeWindowShadingControl.new.registerWithApplication
