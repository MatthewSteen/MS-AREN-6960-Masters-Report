# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class LightingDemandManagerLights < OpenStudio::Measure::EnergyPlusMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Demand Manager Lights'
  end

  # human readable description
  def description
    return 'TODO'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This EnergyPlus measure adds a `DemandManager:Lights` object to the model. The measure will also add a `DemandManagerAssignmentList` object if one is not present in the model. If one is, it will add the `DemandManager:Lights` to the existing `DemandManagerAssignmentList`. The object properties come from the `5ZoneAirCooledDemandLimiting.idf` EnergyPlus example file.'
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    # schedule names for choice args
    schedule_choices = OpenStudio::StringVector.new
    workspace.getObjectsByType('Schedule:Year'.to_IddObjectType).sort.each do |obj|
      schedule_choices << obj.getString(0).to_s
    end

    # DemandManager:Lights,
    #   Lights Manager,          !- Name
    #   ,                        !- Availability Schedule Name
    #   FIXED,                   !- Limit Control
    #   60,                      !- Minimum Limit Duration {minutes}
    #   0.5,                     !- Maximum Limit Fraction
    #   ,                        !- Limit Step Change
    #   ALL,                     !- Selection Control
    #   ,                        !- Rotation Duration {minutes}
    #   AllZones with Lights;    !- Lights 1 Name    

    availability_schedule_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('availability_schedule_name', schedule_choices, false)
    availability_schedule_name.setDisplayName('Availability Schedule Name')
    args << availability_schedule_name

    limit_control_choices = ['Fixed', 'Off']
    limit_control = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('limit_control', limit_control_choices, true)
    limit_control.setDisplayName('Limit Control')
    limit_control.setDefaultValue('Fixed')
    args << limit_control

    minimum_limit_duration = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('minimum_limit_duration', false)
    minimum_limit_duration.setDisplayName('Minimum Limit Duration {minutes}')
    minimum_limit_duration.setDefaultValue(60)
    args << minimum_limit_duration

    maximum_limit_fraction = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('maximum_limit_fraction', false)
    maximum_limit_fraction.setDisplayName('Maximum Limit Fraction')
    maximum_limit_fraction.setDefaultValue(0.5)
    args << maximum_limit_fraction

    # 'Limit Step Change'
    # https://bigladdersoftware.com/epx/docs/9-3/input-output-reference/group-demand-limiting-controls.html#field-limit-step-change-1

    selection_control_choices = ['All', 'RotateMany', 'RotateOne']
    selection_control = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('selection_control', selection_control_choices, true)
    selection_control.setDisplayName('Selection Control')
    selection_control.setDefaultValue('All')
    args << selection_control

    rotation_duration = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('rotation_duration', false)
    rotation_duration.setDisplayName('Rotation Duration {minutes}')
    rotation_duration.setDescription('Selection Control = RotateMany or RotateOne')
    args << rotation_duration

    lights_choices = OpenStudio::StringVector.new
    lights_choices << 'ALL'
    workspace.getObjectsByType('Lights'.to_IddObjectType).sort.each do |obj|
      lights_choices << obj.getString(0).to_s
    end
    lights_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('lights_name', lights_choices, true)
    lights_name.setDisplayName('Lights Name')
    lights_name.setDefaultValue('ALL')
    args << lights_name

    # DemandManagerAssignmentList,
    #   Demand Manager,          !- Name
    #   Electricity:Facility,    !- Meter Name
    #   Limit Schedule,          !- Demand Limit Schedule Name
    #   1.0,                     !- Demand Limit Safety Fraction
    #   ,                        !- Billing Period Schedule Name
    #   ,                        !- Peak Period Schedule Name
    #   15,                      !- Demand Window Length {minutes}
    #   SEQUENTIAL,              !- Demand Manager Priority
    #   DemandManager:ExteriorLights,  !- DemandManager 1 Object Type
    #   Ext Lights Manager,      !- DemandManager 1 Name
    #   DemandManager:ElectricEquipment,  !- DemandManager 2 Object Type
    #   Eq Mgr Stage 1,          !- DemandManager 2 Name
    #   DemandManager:ElectricEquipment,  !- DemandManager 3 Object Type
    #   Eq Mgr Stage 2,          !- DemandManager 3 Name
    #   DemandManager:ElectricEquipment,  !- DemandManager 4 Object Type
    #   Eq Mgr Stage 3,          !- DemandManager 4 Name
    #   DemandManager:Lights,    !- DemandManager 5 Object Type
    #   Lights Manager,          !- DemandManager 5 Name
    #   DemandManager:Thermostats,  !- DemandManager 6 Object Type
    #   Thermostats Manager;     !- DemandManager 6 Name

    meter_name = OpenStudio::Ruleset::OSArgument::makeStringArgument('meter_name', true)
    meter_name.setDisplayName('Meter Name')
    meter_name.setDefaultValue('Electricity:Facility')
    args << meter_name

    demand_limit_schedule_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('demand_limit_schedule_name', schedule_choices, false)
    demand_limit_schedule_name.setDisplayName('Demand Limit Schedule Name')
    args << demand_limit_schedule_name

    demand_limit_safety_fraction = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('demand_limit_safety_fraction', true)
    demand_limit_safety_fraction.setDisplayName('Demand Limit Safety Fraction')
    demand_limit_safety_fraction.setDefaultValue(1.0)
    args << demand_limit_safety_fraction

    billing_period_schedule_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('billing_period_schedule_name', schedule_choices, false)
    billing_period_schedule_name.setDisplayName('Billing Period Schedule Name')
    args << billing_period_schedule_name

    peak_period_schedule_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('peak_period_schedule_name', schedule_choices, false)
    peak_period_schedule_name.setDisplayName('Peak Period Schedule Name')
    args << peak_period_schedule_name

    demand_window_length = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('demand_window_length', true)
    demand_window_length.setDisplayName('Demand Window Length {minutes}')
    demand_window_length.setDefaultValue(15)
    args << demand_window_length

    demand_manager_priority_choices = ['All', 'Sequential']
    demand_manager_priority = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('demand_manager_priority', demand_manager_priority_choices, false)
    demand_manager_priority.setDisplayName('Demand Manager Priority')
    demand_manager_priority.setDefaultValue('Sequential')
    args << demand_manager_priority

    return args
  end

  # define what happens when the measure is run
  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
      return false
    end

    # get DemandManager:Lights args
    if runner.getOptionalStringArgumentValue('availability_schedule_name', user_arguments).is_initialized
      availability_schedule_name = runner.getOptionalStringArgumentValue('availability_schedule_name', user_arguments).get
    end
    limit_control = runner.getStringArgumentValue('limit_control', user_arguments)
    if runner.getOptionalDoubleArgumentValue('minimum_limit_duration', user_arguments).is_initialized
      minimum_limit_duration = runner.getOptionalDoubleArgumentValue('minimum_limit_duration', user_arguments).get
    end
    if runner.getOptionalDoubleArgumentValue('maximum_limit_fraction', user_arguments).is_initialized
      maximum_limit_fraction = runner.getOptionalDoubleArgumentValue('maximum_limit_fraction', user_arguments).get
    end
    selection_control = runner.getStringArgumentValue('selection_control', user_arguments)
    if runner.getOptionalDoubleArgumentValue('rotation_duration', user_arguments).is_initialized
      rotation_duration = runner.getOptionalDoubleArgumentValue('rotation_duration', user_arguments).get
    end
    lights_name = runner.getStringArgumentValue('lights_name', user_arguments)

    # get DemandManagerAssignmentList args
    meter_name = runner.getStringArgumentValue('meter_name', user_arguments)
    if runner.getOptionalStringArgumentValue('demand_limit_schedule_name', user_arguments).is_initialized
      demand_limit_schedule_name = runner.getOptionalStringArgumentValue('demand_limit_schedule_name', user_arguments).get
    end
    demand_limit_safety_fraction = runner.getDoubleArgumentValue('demand_limit_safety_fraction', user_arguments)
    if runner.getOptionalStringArgumentValue('billing_period_schedule_name', user_arguments).is_initialized
      billing_period_schedule_name = runner.getOptionalStringArgumentValue('billing_period_schedule_name', user_arguments).get
    end
    if runner.getOptionalStringArgumentValue('peak_period_schedule_name', user_arguments).is_initialized
      peak_period_schedule_name = runner.getOptionalStringArgumentValue('peak_period_schedule_name', user_arguments).get
    end
    demand_window_length = runner.getDoubleArgumentValue('demand_window_length', user_arguments)
    demand_manager_priority = runner.getStringArgumentValue('demand_manager_priority', user_arguments)

    # get workspace objects
    lights = workspace.getObjectsByType('Lights'.to_IddObjectType)
    dmals = workspace.getObjectsByType('DemandManagerAssignmentList'.to_IddObjectType)

    # report initial condition
    dmls = workspace.getObjectsByType('DemandManager:Lights'.to_IddObjectType)
    runner.registerInitialCondition("DemandManager:Lights = #{dmls.size}")

    # add DemandManager:Lights object (1st) and set properties
    dml_idf_obj = OpenStudio::IdfObject.new('DemandManager:Lights'.to_IddObjectType)
    dml = workspace.addObject(dml_idf_obj).get
    dml.setString(0, 'Demand Manager Lights')
    runner.registerInfo("DemandManager:Lights object added = #{dml.nameString}")
    dml.setString(1, availability_schedule_name) if availability_schedule_name
    dml.setString(2, limit_control)
    dml.setDouble(3, minimum_limit_duration) if minimum_limit_duration
    dml.setDouble(4, maximum_limit_fraction) if maximum_limit_fraction
    dml.setString(6, selection_control)
    dml.setDouble(7, rotation_duration) if rotation_duration
    lights.sort.each_with_index do |obj, i|
      name = obj.nameString
      next if name != lights_name unless lights_name == 'ALL'
      dml.setString(i + 8, name)
      runner.registerInfo("Lights #{i + 1} Name = #{name}")
    end
    
    # add or get DemandManagerAssignmentList object (2nd) and set properties
    case dmals.size
    when 0
      runner.registerInfo('DemandManagerAssignmentList not found')
      dmal_idf_obj = OpenStudio::IdfObject.new('DemandManagerAssignmentList'.to_IddObjectType)
      dmal = workspace.addObject(dmal_idf_obj).get
      dmal.setString(0, 'Demand Manager Assignment List')
      runner.registerInfo("DemandManagerAssignmentList object added: #{dmal.nameString}")
    when 1
      dmal = dmals[0]
      runner.registerInfo("DemandManagerAssignmentList object found: #{dmal.nameString}")
    else
      runner.registerError('DemandManagerAssignmentList objects > 1')
      return false
    end
    dmal.setString(1, meter_name)
    dmal.setString(2, demand_limit_schedule_name) if demand_limit_schedule_name
    dmal.setDouble(3, demand_limit_safety_fraction) 
    dmal.setString(4, billing_period_schedule_name) if billing_period_schedule_name
    dmal.setString(5, peak_period_schedule_name) if peak_period_schedule_name
    dmal.setDouble(6, demand_window_length) 
    dmal.setString(7, demand_manager_priority)
    dmal_num_fields = dmal.numFields
    dmal.setString(dmal_num_fields, 'DemandManager:Lights')
    dmal.setString(dmal_num_fields + 1, dml.nameString.to_s)

    # report final condition
    dmls = workspace.getObjectsByType('DemandManager:Lights'.to_IddObjectType)
    runner.registerFinalCondition("DemandManager:Lights = #{dmls.size}")

    return true
  end
end

# register the measure to be used by the application
LightingDemandManagerLights.new.registerWithApplication
