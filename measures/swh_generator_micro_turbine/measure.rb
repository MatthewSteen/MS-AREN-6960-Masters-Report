# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class SWHGeneratorMicroTurbine < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Generator Micro Turbine'
  end

  # human readable description
  def description
    return 'TODO'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure adds an OpenStudio GeneratorMicroTurbineHeatRecovery object (EnergyPlus object Generator:MicroTurbine) to the supply side of a plant loop with a WaterHeater object. The GeneratorMicroTurbine is the Capstone C65 from the EnergyPlus HeatRecoveryPlantLoopAuto.idf example file (and others), which generates electric energy for the building and waste thermal energy that is used for service hot water. The code and topology is based on https://github.com/NREL/OpenStudio-resources/blob/develop/model/simulationtests/generator_microturbine.rb. The topology differs from the example file because OpenStudio does not allow WaterHeater objects on the same side of two different plant loops.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # plant loop
    plant_loop_names = OpenStudio::StringVector.new
    model.getPlantLoops.sort.each do |plant_loop|
      plant_loop_names << plant_loop.name.to_s
    end
    plant_loop_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('plant_loop_name', plant_loop_names, true)
    plant_loop_name.setDisplayName('Plant Loop Name')
    args << plant_loop_name

    # ElectricLoadCenterDistribution arguments
    generator_operation_scheme_type_choices = OpenStudio::StringVector.new
    generator_operation_scheme_type_choices << 'Baseload'
    generator_operation_scheme_type_choices << 'DemandLimit'
    generator_operation_scheme_type_choices << 'FollowThermal'
    generator_operation_scheme_type_choices << 'FollowThermalLimitElectrical'
    generator_operation_scheme_type_choices << 'TrackElectrical'
    # generator_operation_scheme_type_choices << 'TrackMeter'
    generator_operation_scheme_type_choices << 'TrackSchedule'
    generator_operation_scheme_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('generator_operation_scheme_type', generator_operation_scheme_type_choices, true)
    generator_operation_scheme_type.setDisplayName('Generator Operation Scheme Type')
    generator_operation_scheme_type.setDescription('ElectricLoadCenter:Distribution')
    generator_operation_scheme_type.setDefaultValue('Baseload')
    args << generator_operation_scheme_type

    demand_limit = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('demand_limit', false)
    demand_limit.setDisplayName('Demand Limit Scheme Purchased Electric Demand Limit (W)')
    demand_limit.setDescription('Generator Operation Scheme Type = DemandLimit')
    args << demand_limit

    # 'Track Meter Scheme Meter Name'

    schedule_names = OpenStudio::StringVector.new
    model.getScheduleRulesets.sort.each do |schedule|
      schedule_names << schedule.name.to_s
    end
    track_schedule_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('track_schedule_name', schedule_names, false)
    track_schedule_name.setDisplayName('Track Schedule Name Scheme Schedule Name')
    track_schedule_name.setDescription('Generator Operation Scheme Type = TrackSchedule')
    args << track_schedule_name

    # output variables
    output_variables_bool = OpenStudio::Ruleset::OSArgument::makeBoolArgument('output_variables_bool', false)
    output_variables_bool.setDisplayName('Output Variables')
    output_variables_bool.setDescription('GeneratorMicroTurbine, GeneratorMicroTurbineHeatRecovery, ElectricLoadCenterDistribution')
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
    plant_loop_name = runner.getStringArgumentValue('plant_loop_name', user_arguments)
    generator_operation_scheme_type = runner.getStringArgumentValue('generator_operation_scheme_type', user_arguments)
    case generator_operation_scheme_type
    when 'DemandLimit'
      if runner.getOptionalDoubleArgumentValue('demand_limit', user_arguments).is_initialized
        demand_limit = runner.getOptionalDoubleArgumentValue('demand_limit', user_arguments).get
      else
        runner.registerError('Demand Limit Scheme Purchased Electric Demand Limit')
        return false
      end
    when 'TrackMeter'
      # TODO
    when 'TrackSchedule'
      if runner.getOptionalStringArgumentValue('track_schedule_name', user_arguments).is_initialized
        track_schedule_name = runner.getOptionalStringArgumentValue('track_schedule_name', user_arguments).get
      else
        runner.registerError('Track Schedule Name Scheme Schedule Name')
        return false
      end
    end
    output_variables_bool = runner.getBoolArgumentValue('output_variables_bool', user_arguments)

    # report initial condition of model
    runner.registerInitialCondition("GeneratorMicroTurbines = #{model.getGeneratorMicroTurbines.size}")

    # get objects
    plant_loop = model.getPlantLoopByName(plant_loop_name).get
  
    # the remaining code is based on the following
    # https://github.com/NREL/OpenStudio-resources/blob/develop/model/simulationtests/generator_microturbine.rb

    # add GeneratorMicroTurbine
    gmt = OpenStudio::Model::GeneratorMicroTurbine.new(model)
    runner.registerInfo("Added #{gmt.class}")

    # set GeneratorMicroTurbine properties
    #   Capstone C65,            !- Name
    #   65000,                   !- Reference Electrical Power Output {W}
    #   29900,                   !- Minimum Full Load Electrical Power Output {W}
    #   65000,                   !- Maximum Full Load Electrical Power Output {W}
    #   0.29,                    !- Reference Electrical Efficiency Using Lower Heating Value
    #   15.0,                    !- Reference Combustion Air Inlet Temperature {C}
    #   0.00638,                 !- Reference Combustion Air Inlet Humidity Ratio {kgWater/kgDryAir}
    #   0.0,                     !- Reference Elevation {m}
    #   Capstone C65 Power_vs_Temp_Elev,  !- Electrical Power Function of Temperature and Elevation Curve Name
    #   Capstone C65 Efficiency_vs_Temp,  !- Electrical Efficiency Function of Temperature Curve Name
    #   Capstone C65 Efficiency_vs_PLR,  !- Electrical Efficiency Function of Part Load Ratio Curve Name
    #   NaturalGas,              !- Fuel Type
    #   50000,                   !- Fuel Higher Heating Value {kJ/kg}
    #   45450,                   !- Fuel Lower Heating Value {kJ/kg}
    #   300,                     !- Standby Power {W}
    #   4500,                    !- Ancillary Power {W}
    #   ,                        !- Ancillary Power Function of Fuel Input Curve Name
    gmt.setName('Capstone C65')
    gmt.setReferenceElectricalPowerOutput(65000)    
    gmt.setMinimumFullLoadElectricalPowerOutput(29900)    
    gmt.setMaximumFullLoadElectricalPowerOutput(65000)    
    gmt.setReferenceElectricalEfficiencyUsingLowerHeatingValue(0.29)    
    gmt.setReferenceCombustionAirInletTemperature(15.0)    
    gmt.setReferenceCombustionAirInletHumidityRatio(0.00638)    
    gmt.setReferenceElevation(0)    
    # change names of electrical curves, which are automatically created
    gmt.electricalPowerFunctionofTemperatureandElevationCurve.setName('Capstone C65 Power_vs_Temp_Elev')
    gmt.electricalEfficiencyFunctionofTemperatureCurve.setName('Capstone C65 Efficiency_vs_Temp')
    gmt.electricalEfficiencyFunctionofPartLoadRatioCurve.setName('Capstone C65 Efficiency_vs_PLR')
    gmt.setFuelType('NaturalGas')
    gmt.setFuelHigherHeatingValue(50000)    
    gmt.setFuelLowerHeatingValue(45450)    
    gmt.setStandbyPower(300)
    gmt.setAncillaryPower(4500)
    # gmt.setAncillaryPowerFunctionofFuelInputCurve
    
    # add GeneratorMicroTurbineHeatRecovery, which is part of the Generator:MicroTurbine object in EnergyPlus
    gmthr =  OpenStudio::Model::GeneratorMicroTurbineHeatRecovery.new(model, gmt)
    runner.registerInfo("Added #{gmthr.class}")

    # add GeneratorMicroTurbineHeatRecovery plant loop upstream of and in series with WaterHeater
    # https://github.com/NREL/OpenStudio-resources/blob/develop/model/simulationtests/generator_microturbine.rb#L369-L379
    #   Capstone C65 Heat Recovery Water Inlet Node,  !- Heat Recovery Water Inlet Node Name
    #   Capstone C65 Heat Recovery Water Outlet Node,  !- Heat Recovery Water Outlet Node Name
    supply_components = plant_loop.supplyComponents('OS:WaterHeater:Mixed'.to_IddObjectType)
    if supply_components.size == 0
      runner.registerAsNotApplicable('WaterHeater object not found on plant loop.')
      return false
    else
      waterheater = supply_components.first.to_WaterHeaterMixed.get
      inlet_node = waterheater.supplyInletModelObject.get.to_Node.get
      gmthr.addToNode(inlet_node)
    end

    # set GeneratorMicroTurbineHeatRecovery properties
    #   0.4975,                  !- Reference Thermal Efficiency Using Lower Heat Value
    #   60.0,                    !- Reference Inlet Water Temperature {C}
    #   PlantControl,            !- Heat Recovery Water Flow Operating Mode
    #   0.00252362,              !- Reference Heat Recovery Water Flow Rate {m3/s}
    #   ,                        !- Heat Recovery Water Flow Rate Function of Temperature and Power Curve Name
    #   Capstone C65 ThermalEff_vs_Temp_Elev,  !- Thermal Efficiency Function of Temperature and Elevation Curve Name
    #   Capstone C65 HeatRecoveryRate_vs_PLR,  !- Heat Recovery Rate Function of Part Load Ratio Curve Name
    #   Capstone C65 HeatRecoveryRate_vs_InletTemp,  !- Heat Recovery Rate Function of Inlet Water Temperature Curve Name
    #   Capstone C65 HeatRecoveryRate_vs_WaterFlow,  !- Heat Recovery Rate Function of Water Flow Rate Curve Name
    #   0.001577263,             !- Minimum Heat Recovery Water Flow Rate {m3/s}
    #   0.003785432,             !- Maximum Heat Recovery Water Flow Rate {m3/s}
    #   82.2,                    !- Maximum Heat Recovery Water Temperature {C}
    gmthr.setReferenceThermalEfficiencyUsingLowerHeatValue(0.4975)
    gmthr.setReferenceInletWaterTemperature(60)
    gmthr.setHeatRecoveryWaterFlowOperatingMode('PlantControl')
    gmthr.setReferenceHeatRecoveryWaterFlowRate(0.00252362)
    curve = OpenStudio::Model::CurveBicubic.new(model)
    curve.setName('Capstone C65 ThermalEff_vs_Temp_Elev')
    curve.setCoefficient1Constant(0.93553794)
    curve.setCoefficient2x(0.00541992)
    curve.setCoefficient3xPOW2(-0.000078902)
    curve.setCoefficient4y(-0.0000174338)
    curve.setCoefficient5yPOW2(-0.0000000251197)
    curve.setCoefficient6xTIMESY(-0.00000450373)
    curve.setCoefficient7xPOW3(0.00000149283)
    curve.setCoefficient8yPOW3(2.16866E-12)
    curve.setCoefficient9xPOW2TIMESY(0.0000000193982)
    curve.setCoefficient10xTIMESYPOW2(0.000000000673429)
    curve.setMinimumValueofx(-17.8)
    curve.setMaximumValueofx(48.9)
    curve.setMinimumValueofy(0)
    curve.setMaximumValueofy(3048)
    gmthr.setThermalEfficiencyFunctionofTemperatureandElevationCurve(curve)
    curve = OpenStudio::Model::CurveQuadratic.new(model)
    curve.setName('Capstone C65 HeatRecoveryRate_vs_PLR')
    curve.setCoefficient1Constant(0)
    curve.setCoefficient2x(1)
    curve.setCoefficient3xPOW2(0)
    curve.setMinimumValueofx(0.03)
    curve.setMaximumValueofx(1)
    gmthr.setHeatRecoveryRateFunctionofPartLoadRatioCurve(curve)
    curve = OpenStudio::Model::CurveQuadratic.new(model)
    curve.setName('Capstone C65 HeatRecoveryRate_vs_InletTemp')
    curve.setCoefficient1Constant(0.7516)
    curve.setCoefficient2x(0.00414)
    curve.setCoefficient3xPOW2(0)
    curve.setMinimumValueofx(29.44)
    curve.setMaximumValueofx(85)
    curve.setInputUnitTypeforX('Temperature')
    curve.setOutputUnitType('Dimensionless')
    gmthr.setHeatRecoveryRateFunctionofInletWaterTemperatureCurve(curve)
    curve = OpenStudio::Model::CurveQuadratic.new(model)
    curve.setName('Capstone C65 HeatRecoveryRate_vs_WaterFlow')
    curve.setCoefficient1Constant(0.83)
    curve.setCoefficient2x(88.76138)
    curve.setCoefficient3xPOW2(-8541.831)
    curve.setMinimumValueofx(0.001577263)
    curve.setMaximumValueofx(0.003785432)
    curve.setInputUnitTypeforX('VolumetricFlow')
    curve.setOutputUnitType('Dimensionless')
    gmthr.setHeatRecoveryRateFunctionofWaterFlowRateCurve(curve)
    gmthr.setMinimumHeatRecoveryWaterFlowRate(0.001577263)
    gmthr.setMaximumHeatRecoveryWaterFlowRate(0.003785432)
    gmthr.setMaximumHeatRecoveryWaterTemperature(82.2)

    # set GeneratorMicroTurbine properties (continued)
    #   Capstone C65 Combustion Air Inlet Node,  !- Combustion Air Inlet Node Name
    #   Capstone C65 Combustion Air Outlet Node,  !- Combustion Air Outlet Node Name
    #   0.489885,                !- Reference Exhaust Air Mass Flow Rate {kg/s}
    #   Capstone C65 ExhAirFlowRate_vs_InletTemp,  !- Exhaust Air Flow Rate Function of Temperature Curve Name
    #   Capstone C65 ExhAirFlowRate_vs_PLR,  !- Exhaust Air Flow Rate Function of Part Load Ratio Curve Name
    #   308.9,                   !- Nominal Exhaust Air Outlet Temperature
    #   Capstone C65 ExhaustTemp_vs_InletTemp,  !- Exhaust Air Temperature Function of Temperature Curve Name
    #   Capstone C65 ExhaustTemp_vs_PLR;  !- Exhaust Air Temperature Function of Part Load Ratio Curve Name   
    gmt.setReferenceExhaustAirMassFlowRate(0.489885)
    curve = OpenStudio::Model::CurveCubic.new(model)
    curve.setName('Capstone C65 ExhAirFlowRate_vs_InletTemp')
    curve.setCoefficient1Constant(0.9837417)
    curve.setCoefficient2x(0.0000676623)
    curve.setCoefficient3xPOW2(0.0000535766)
    curve.setCoefficient4xPOW3(-0.00000212819)
    curve.setMinimumValueofx(-20)
    curve.setMaximumValueofx(50)
    curve.setInputUnitTypeforX('Temperature')
    curve.setOutputUnitType('Dimensionless')
    gmt.setExhaustAirFlowRateFunctionofTemperatureCurve(curve)
    curve = OpenStudio::Model::CurveCubic.new(model)
    curve.setName('Capstone C65 ExhAirFlowRate_vs_PLR')
    curve.setCoefficient1Constant(0.272074)
    curve.setCoefficient2x(1.313337)
    curve.setCoefficient3xPOW2(-1.0480845)
    curve.setCoefficient4xPOW3(0.46216638)
    curve.setMinimumValueofx(0.03)
    curve.setMaximumValueofx(1)
    gmt.setExhaustAirFlowRateFunctionofPartLoadRatioCurve(curve)
    gmt.setNominalExhaustAirOutletTemperature(308.9)
    curve = OpenStudio::Model::CurveCubic.new(model)
    curve.setName('Capstone C65 ExhaustTemp_vs_InletTemp')
    curve.setCoefficient1Constant(0.9246362)
    curve.setCoefficient2x(0.0052553)
    curve.setCoefficient3xPOW2(-0.0000197367)
    curve.setCoefficient4xPOW3(-0.000000566196)
    curve.setMinimumValueofx(-20)
    curve.setMaximumValueofx(50)
    gmt.setExhaustAirTemperatureFunctionofTemperatureCurve(curve)
    curve = OpenStudio::Model::CurveCubic.new(model)
    curve.setName('Capstone C65 ExhaustTemp_vs_PLR')
    curve.setCoefficient1Constant(0.59175)
    curve.setCoefficient2x(0.87874)
    curve.setCoefficient3xPOW2(-0.880443)
    curve.setCoefficient4xPOW3(0.4107131)
    curve.setMinimumValueofx(0.03)
    curve.setMaximumValueofx(1)
    gmt.setExhaustAirTemperatureFunctionofPartLoadRatioCurve(curve)

    # get ElectricLoadCenterDistribution, which is created with GeneratorMicroTurbine
    elcd = gmt.electricLoadCenterDistribution.get

    # set ElectricLoadCenterDistribution properties
    elcd.setName('Capstone C65 ELCD')
    elcd.setGeneratorOperationSchemeType(generator_operation_scheme_type)
    elcd.setElectricalBussType('AlternatingCurrent')
    case generator_operation_scheme_type
    when 'DemandLimit'
      elcd.setDemandLimitSchemePurchasedElectricDemandLimit(demand_limit)
    when 'TrackSchedule'
      track_schedule = model.getScheduleRulesetByName(track_schedule_name).get
      elcd.setTrackScheduleSchemeSchedule(track_schedule)
    end

    # add PlantEquipmentOperationHeatingLoad and set properties
    case generator_operation_scheme_type 
    when 'FollowThermal' || 'FollowThermalLimitElectrical'
      # set ElectricLoadCenter:Generators properties
      # https://github.com/NREL/OpenStudio-resources/blob/develop/model/simulationtests/generator_microturbine.rb#L26
      # https://bigladdersoftware.com/epx/docs/9-3/input-output-reference/group-electric-load-center-generator.html#field-generator-x-rated-thermal-to-electrical-power-ratio
      # gmthr.setRatedThermaltoElectricalPowerRatio(1.72) # TODO source?
      operation = OpenStudio::Model::PlantEquipmentOperationHeatingLoad.new(model)
      operation.addEquipment(gmthr)
      operation.addEquipment(waterheater)
      plant_loop.setPlantEquipmentOperationHeatingLoad(operation)
      runner.registerInfo("Added #{operation.class}")
    end

    # output variables
    if output_variables_bool == true
      gmt.outputVariableNames.each do |name|
        OpenStudio::Model::OutputVariable.new(name, model)
        runner.registerInfo("Added OutputVariable = #{name}")
      end
      gmthr.outputVariableNames.each do |name|
        OpenStudio::Model::OutputVariable.new(name, model)
        runner.registerInfo("Added OutputVariable = #{name}")
      end
      elcd.outputVariableNames.each do |name|
        OpenStudio::Model::OutputVariable.new(name, model)
        runner.registerInfo("Added OutputVariable = #{name}")
      end
    end

    # report final condition of model
    runner.registerFinalCondition("GeneratorMicroTurbines = #{model.getGeneratorMicroTurbines.size}")

    return true
  end
end

# register the measure to be used by the application
SWHGeneratorMicroTurbine.new.registerWithApplication
