# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class EnvelopeMaterialPropertyPhaseChange < OpenStudio::Measure::EnergyPlusMeasure
  
  # constants
  MAX = 5
  CLASS = 'MaterialProperty:PhaseChange'
  
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
    return 'This EnergyPlus measure adds phase change properties to the selected material by adding a `MaterialProperty:PhaseChange` object. This object requires the conduction finite difference heat balance algorithm rather than the default conduction transfer function algorithm, which requires constant material properties (e.g. specific heat). The object properties come from the `CondFD1ZonePurchAirAutoSizeWithPCM.idf` EnergyPlus example file.'
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    # get material names from workspace for choice argument
    material_names = OpenStudio::StringVector.new
    workspace.getObjectsByType('Material'.to_IddObjectType).sort.each do |obj|
      material_names << obj.name.to_s
    end
    
    # material name
    (1..MAX).each do |num|
      material_name = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("material_name_#{num}", material_names, false)
      material_name.setDisplayName("Material Name #{num}")
      args << material_name
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
    material_names = []
    (1..MAX).each do |num|
      if runner.getOptionalStringArgumentValue("material_name_#{num}", user_arguments).is_initialized
        material_name = runner.getOptionalStringArgumentValue("material_name_#{num}", user_arguments).get
        material_names << material_name
      end
    end

    # reporting initial condition of model
    objs = workspace.getObjectsByType(CLASS.to_IddObjectType)
    runner.registerInitialCondition("#{CLASS} objects = #{objs.size}")

    # add object from ~/EnergyPlus-x-x-x/ExampleFiles/CondFD1ZonePurchAirAutoSizeWithPCM.idf 
    material_names.uniq.each do |material_name|
      runner.registerInfo("#{CLASS} = #{material_name}")
      idf_str = "
        MaterialProperty:PhaseChange,
          #{material_name},  !- Name
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
