# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class EnvelopeMaterialPropertyPhaseChange < OpenStudio::Measure::EnergyPlusMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Material Property Phase Change'
  end

  # human readable description
  def description
    return 'Adds a MaterialProperty:PhaseChange object to the model that references the interior layer of the selected Construction.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Gets the interior layer name of the selected Construction object from the number of fields and sets the MaterialProperty:PhaseChange Name field to reference it.'
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    # get construction names from workspace for choice argument
    construction_names = []
    workspace.getObjectsByType('Construction'.to_IddObjectType).sort.each do |obj|
      construction_names << obj.getString(0).to_s
    end
    
    # argument for construction name
    construction_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('construction_name', construction_names, true)
    construction_name.setDisplayName('Construction Name')
    construction_name.setDescription('Phase Change Material will be added to interior material')
    args << construction_name

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
    construction_name = runner.getStringArgumentValue('construction_name', user_arguments)

    # reporting initial condition of model
    objs = workspace.getObjectsByType('MaterialProperty:PhaseChange'.to_IddObjectType)
    runner.registerInitialCondition("MaterialProperty:PhaseChange objects = #{objs.size}")

    # get objects 
    construction = workspace.getObjectByTypeAndName('Construction'.to_IddObjectType, construction_name).get
    construction_num_fields = construction.numFields - 1
    construction_interior_layer_name = construction.getString(construction_num_fields).to_s

    # add object from ~/EnergyPlus-x-x-x/ExampleFiles/MaterialPropertyPhaseChange.idf 
    idf_str = "
      MaterialProperty:PhaseChange,
        #{construction_interior_layer_name},  !- Name
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

    # report final condition of model
    objs = workspace.getObjectsByType('MaterialProperty:PhaseChange'.to_IddObjectType)
    runner.registerFinalCondition("MaterialProperty:PhaseChange objects = #{objs.size}")

    return true
  end
end

# register the measure to be used by the application
EnvelopeMaterialPropertyPhaseChange.new.registerWithApplication
