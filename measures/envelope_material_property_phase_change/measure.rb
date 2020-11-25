# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class EnvelopeMaterialPropertyPhaseChange < OpenStudio::Measure::EnergyPlusMeasure
  
  # constants
  MAX = 5
  
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Material Property Phase Change'
  end

  # human readable description
  def description
    return ''
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This EnergyPlus measure changes the selected construction layer to a `MaterialProperty:PhaseChange` object. This object requires the conduction finite difference heat balance algorithm rather than the default conduction transfer function algorithm, which requires constant material properties (e.g. specific heat). The object properties come from the `CondFD1ZonePurchAirAutoSizeWithPCM.idf` EnergyPlus example file.'
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    # get construction names from workspace for choice argument
    construction_names = OpenStudio::StringVector.new
    workspace.getObjectsByType('Construction'.to_IddObjectType).sort.each do |obj|
      construction_names << obj.name.to_s
    end
    
    (1..MAX).each do |num|
      
      # construction name
      construction_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("construction_name_#{num}", construction_names, false)
      construction_name.setDisplayName("Construction Name #{num}")
      args << construction_name

      # construction layer number
      construction_layer_number = OpenStudio::Ruleset::OSArgument::makeIntegerArgument("construction_layer_number_#{num}", false)
      construction_layer_number.setDisplayName("Construction Layer Number #{num}")
      construction_layer_number.setDescription('from outside to inside')
      args << construction_layer_number

    end

    return args
  end

  # define what happens when the measure is run
  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
      return false
    end

    # assign the user inputs to variables
    construction_hash = {}
    (1..MAX).each do |num|
      if runner.getOptionalStringArgumentValue("construction_name_#{num}", user_arguments).is_initialized
        construction_name = runner.getOptionalStringArgumentValue("construction_name_#{num}", user_arguments).get
        if runner.getOptionalIntegerArgumentValue("construction_layer_number_#{num}", user_arguments).is_initialized
          construction_layer_number = runner.getOptionalIntegerArgumentValue("construction_layer_number_#{num}", user_arguments).get
          construction_hash[construction_layer_number] = construction_name
        else
          runner.registerError("missing user argument = Construction Layer Number #{num}")
          return false
        end
      end
    end

    # reporting initial condition of model
    objs = workspace.getObjectsByType('MaterialProperty:PhaseChange'.to_IddObjectType)
    runner.registerInitialCondition("MaterialProperty:PhaseChange objects = #{objs.size}")

    # add objects
    construction_hash.each do |construction_layer_number, construction_name|
    
      # if the layer number is greater than the number of fields, it's skipped so error handling doesn't work
      construction = workspace.getObjectByTypeAndName('Construction'.to_IddObjectType, construction_name).get 
      construction_layer_name = construction.getString(construction_layer_number).to_s

      runner.registerInfo("Construction = #{construction_name}")
      runner.registerInfo("    Material = #{construction_layer_name}")

      # add object from ~/EnergyPlus-x-x-x/ExampleFiles/MaterialPropertyPhaseChange.idf 
      idf_str = "
        MaterialProperty:PhaseChange,
          #{construction_layer_name},  !- Name
          0,                       !- Temperature Coefficient for Thermal Conductivity {W/m-K2}
          -20,                     !- Temperature 1 {C}
          0.1,                     !- Enthalpy 1 {J/kg}
          22,                      !- Temperature 2 {C}
          18260,                   !- Enthalpy 2 {J/kg}
          22.1,                    !- Temperature 3 {C}
          32000,                   !- Enthalpy 3 {J/kg}
          60,                      !- Temperature 4 {C}
          71000;                   !- Enthalpy 4 {J/kg}
        "
      idf_obj = OpenStudio::IdfObject.load(idf_str).get
      workspace.addObject(idf_obj)

    end

    # HeatBalanceAlgorithm
    hba = workspace.getObjectsByType('HeatBalanceAlgorithm'.to_IddObjectType).first
    unless hba.getString(0).to_s == 'ConductionFiniteDifference'
      hba.setString(0, 'ConductionFiniteDifference')
      runner.registerInfo('HeatBalanceAlgorithm = ConductionFiniteDifference')
    end

    # report final condition of model
    objs = workspace.getObjectsByType('MaterialProperty:PhaseChange'.to_IddObjectType)
    runner.registerFinalCondition("MaterialProperty:PhaseChange objects = #{objs.size}")

    return true
  end
end

# register the measure to be used by the application
EnvelopeMaterialPropertyPhaseChange.new.registerWithApplication
