# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class HVACDehumidifierDesiccantSystem < OpenStudio::Measure::EnergyPlusMeasure

  # constants
  INDENT = '    '

  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Dehumidifier Desiccant System'
  end

  # human readable description
  def description
    return 'TODO'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure adds Dehumidifier:Desiccant:System (DDS) object(s) to the outdoor air (OA) or supply air (SA) stream of one or all air loops by replacing a surrogate object (e.g. CoilHeatingGas). 
    In either case, a SetpointManager must be on the outlet node of the surrogate object to control humidity.
    If the DDS will be added to the SA stream, the surrogate object must be directly downstream of a cooling coil, which will be the Companion Cooling Coil to the DDS.
    The measure uses objects from the EnergyPlus example file DesiccantDehumidifierWithCompanionCoil.idf, which are included in the resources folder.'
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    location_choices = []
    location_choices << 'Outdoor Air Stream'
    location_choices << 'Supply Air Stream'
    location = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('location', location_choices, true)
    location.setDisplayName('Location')
    args << location

    # air loop
    air_loop_choices = []
    air_loop_choices << 'ALL'
    workspace.getObjectsByType('AirLoopHVAC'.to_IddObjectType).sort.each do |obj|
      air_loop_choices << obj.getString(0).to_s
    end
    air_loop_choice = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('air_loop_choice', air_loop_choices, true)
    air_loop_choice.setDisplayName('Choose Air Loop(s)')
    args << air_loop_choice

    string = OpenStudio::Ruleset::OSArgument::makeStringArgument('string', true)
    string.setDisplayName('String Included in Surrogate Object(s) Name')
    string.setDescription('word included in the surrogate object(s) name')
    args << string

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
    location = runner.getStringArgumentValue('location', user_arguments)
    air_loop_choice = runner.getStringArgumentValue('air_loop_choice', user_arguments)
    string = runner.getStringArgumentValue('string', user_arguments)

    # reporting initial condition of model
    ddss = workspace.getObjectsByType('Dehumidifier:Desiccant:System'.to_IddObjectType)
    runner.registerInitialCondition("Dehumidifier:Desiccant:System = #{ddss.size}")

    # abbreviate location
    if location == 'Outdoor Air Stream'
      stream = 'OA'
    elsif   location == 'Supply Air Stream'
      stream = 'SA'
    end    
    
    # get IDF
    idf_path = OpenStudio::Path.new("#{File.dirname(__FILE__)}/resources/DesiccantDehumidifierWithCompanionCoil-#{stream}.idf")
    idf_file = OpenStudio::IdfFile.load(idf_path)
    if idf_file.empty?
      runner.registerError("Unable to find the IDF")
      return false
    else
      idf_file = idf_file.get
    end

    # get air loop(s)
    air_loops = []
    if air_loop_choice == 'ALL'
      workspace.getObjectsByType('AirLoopHVAC'.to_IddObjectType).each { |obj| air_loops << obj }
    else
      air_loops << workspace.getObjectsByName(air_loop_choice)[0]
    end

    # add objects from IDF for both OA and SA locations
    hx_perf = idf_file.getObjectsByType('HeatExchanger:Desiccant:BalancedFlow:PerformanceDataType1'.to_IddObjectType)[0]
    workspace.addObject(hx_perf)

    # add objects from IDF for SA location
    if stream == 'SA'
      fan_curve = idf_file.getObjectsByType('Curve:Cubic'.to_IddObjectType)[0]
      workspace.addObject(fan_curve)
    end

    # loop through air loops and add the objects to the OA or SA stream
    air_loops.sort.each_with_index do |air_loop, i|

      air_loop_name = air_loop.getString(0).to_s
      runner.registerInfo("FOUND AIR LOOP = #{air_loop_name.upcase}")

      # get object names and objects depending on location
      # oa_node_name = air_loop_name + ' Outdoor Air Node'
      case stream
      when 'OA'
        # coil_inlet_node = air_loop_name + ' Relief Air Node'
        oa_sys_name = air_loop_name + ' OA System'
        oa_sys_eqpt_list_name = oa_sys_name + ' Equipment List'
        location_obj = workspace.getObjectsByName(oa_sys_eqpt_list_name)[0]
      when 'SA'
        branch_name = air_loop_name + ' Main Branch'
        # coil_inlet_node = air_loop_name + ' Outdoor Air Node'
        location_obj = workspace.getObjectsByName(branch_name)[0]
      end

      # number for object names
      n = i + 1

      (0..location_obj.numFields.to_i - 1).each do |j|
  
        field = location_obj.getString(j).to_s
        
        # get clg coil name for SA location, which should be upstream of dehumidifier
        if stream == 'SA'
          if field == 'CoilSystem:Cooling:DX'
            # get clg coil system object from next field
            coil_sys_name = location_obj.getString(j + 1).to_s
            coil_sys = workspace.getObjectsByName(coil_sys_name)[0]
            # get clg coil name
            clg_coil_name_idx = coil_sys.iddObject.getFieldIndex('Cooling Coil Name').to_i
            @clg_coil_name = coil_sys.getString(clg_coil_name_idx).get
          end
        end
        
        # 
        if field.to_s.downcase.include?(string)

          # get surrogate object
          surrogate = workspace.getObjectsByName(field)[0]
          surrogate_name = surrogate.getString(0).to_s
          runner.registerInfo(INDENT + "Found surrogate object = #{surrogate_name}")
          
          # get inlet node
          surrogate_inlet_node = surrogate.getString(surrogate.iddObject.getFieldIndex('Air Inlet Node Name').to_i).get    
          
          # get outlet node
          surrogate_outlet_node = surrogate.getString(surrogate.iddObject.getFieldIndex('Air Outlet Node Name').to_i).get    
          
          # HeatExchanger:Desiccant:BalancedFlow

          # add object
          hx_idf_obj = idf_file.getObjectsByType('HeatExchanger:Desiccant:BalancedFlow'.to_IddObjectType)[0]
          hx = workspace.addObject(hx_idf_obj).get

          # rename object
          hx_name = hx.getString(0).to_s + " #{n}"
          hx.setString(0, hx_name)
          runner.registerInfo(INDENT + "Added object = #{hx_name}")
          
          # set Regeneration Air Inlet Node Name
          hx_regen_inlet_node_idx = hx.iddObject.getFieldIndex('Regeneration Air Inlet Node Name').to_i
          hx_regen_inlet_node = hx.getString(hx_regen_inlet_node_idx).to_s + " #{n}"
          hx.setString(hx_regen_inlet_node_idx, hx_regen_inlet_node)
         
          # set Regeneration Air Outlet Node Name
          hx_regen_outlet_node_idx = hx.iddObject.getFieldIndex('Regeneration Air Outlet Node Name').to_i
          hx_regen_outlet_node = hx.getString(hx_regen_outlet_node_idx).to_s + " #{n}"
          hx.setString(hx_regen_outlet_node_idx, hx_regen_outlet_node)

          # set inlet node
          proc_air_in_node_idx = hx.iddObject.getFieldIndex('Process Air Inlet Node Name').to_i
          hx.setString(proc_air_in_node_idx, surrogate_inlet_node)
          
          # set outlet node
          proc_air_out_node_idx = hx.iddObject.getFieldIndex('Process Air Outlet Node Name').to_i
          hx.setString(proc_air_out_node_idx, surrogate_outlet_node)

          # Fan:SystemModel

          # add object
          fan_idf_obj = idf_file.getObjectsByType('Fan:SystemModel'.to_IddObjectType)[0]
          fan = workspace.addObject(fan_idf_obj).get

          # rename object
          fan_name = fan.getString(0).to_s + " #{n}"
          fan.setString(0, fan_name)
          runner.registerInfo(INDENT + "Added object = #{fan_name}")

          # set Air Inlet Node Name
          fan_inlet_node_idx = fan.iddObject.getFieldIndex('Air Inlet Node Name').to_i
          fan_inlet_node = fan.getString(fan_inlet_node_idx).to_s + " #{n}"
          fan.setString(fan_inlet_node_idx, fan_inlet_node)

          # set Air Outlet Node Name
          fan_outlet_node_idx = fan.iddObject.getFieldIndex('Air Outlet Node Name').to_i
          fan_outlet_node = fan.getString(fan_outlet_node_idx).to_s + " #{n}"
          fan.setString(fan_outlet_node_idx, fan_outlet_node)

          # OutdoorAir:NodeList

          # add object for heating coil
          oa_nodelist_idf_obj = idf_file.getObjectsByType('OutdoorAir:NodeList'.to_IddObjectType)[0]
          oa_nodelist = workspace.addObject(oa_nodelist_idf_obj).get
          htg_coil_inlet_node = oa_nodelist.getString(0).to_s + " #{stream} #{n}"
          oa_nodelist.setString(0, htg_coil_inlet_node)

          # Coil:Heating:Fuel

          # add object
          coil_idf_obj = idf_file.getObjectsByType('Coil:Heating:Fuel'.to_IddObjectType)[0]
          htg_coil = workspace.addObject(coil_idf_obj).get

          # rename object
          htg_coil_name = htg_coil.getString(0).to_s + " #{n}"
          htg_coil.setString(0, htg_coil_name)
          runner.registerInfo(INDENT + "Added object = #{htg_coil_name}")

          # set Air Inlet Node Name
          inlet_node_idx = htg_coil.iddObject.getFieldIndex('Air Inlet Node Name').to_i
          htg_coil.setString(inlet_node_idx, htg_coil_inlet_node)

          # set Air Outlet Node Name
          coil_outlet_node_idx = htg_coil.iddObject.getFieldIndex('Air Outlet Node Name').to_i
          coil_outlet_node = htg_coil.getString(coil_outlet_node_idx).to_s + " #{n}"
          htg_coil.setString(coil_outlet_node_idx, coil_outlet_node)

          # Dehumidifier:Desiccant:System

          # add object
          dds_idf_obj = idf_file.getObjectsByType('Dehumidifier:Desiccant:System'.to_IddObjectType)[0]
          dds = workspace.addObject(dds_idf_obj).get

          # rename object
          dds_name = dds.getString(0).to_s + " #{n}"
          dds.setString(0, dds_name)
          runner.registerInfo(INDENT + "Added object = #{dds_name}")

          # insert object
          location_obj.setString(j - 1, 'Dehumidifier:Desiccant:System')
          location_obj.setString(j, dds.getString(0).to_s)    
          
          # set Desiccant Heat Exchanger Name
          hx_name_idx = dds.iddObject.getFieldIndex('Desiccant Heat Exchanger Name').to_i
          dds.setString(hx_name_idx, hx_name)

          # set Sensor Node Name
          sensor_node_idx = dds.iddObject.getFieldIndex('Sensor Node Name').to_i
          dds.setString(sensor_node_idx, surrogate_outlet_node)

          # set Regeneration Air Fan Name
          fan_name_idx = dds.iddObject.getFieldIndex('Regeneration Air Fan Name').to_i
          dds.setString(fan_name_idx, fan_name)
          
          # set Regeneration Air Heater Name
          htg_coil_name_idx = dds.iddObject.getFieldIndex('Regeneration Air Heater Name').to_i
          dds.setString(htg_coil_name_idx, htg_coil_name)

          # set Companion Cooling Coil Name
          if stream == 'SA'
            clg_coil_name_idx = dds.iddObject.getFieldIndex('Companion Cooling Coil Name').to_i
            dds.setString(clg_coil_name_idx, @clg_coil_name)
          end

          # set Companion Coil Regeneration Air Heating = No to avoid EnergyPlus Error
          # ** Severe  ** Dehumidifier:Desiccant:System "DESICCANT SYSTEM 1"
          # **   ~~~   ** Exhaust Fan Maximum Flow Rate and Exhaust Fan Maximum Power must be defined if Companion Coil Regeneration Air Heating field is "Yes".
          # **  Fatal  ** Errors found in getting DESICCANT DEHUMIDIFIER input
          dds_clg_coil_regen_air_htg_idx = dds.iddObject.getFieldIndex('Companion Coil Regeneration Air Heating').to_i
          dds.setString(dds_clg_coil_regen_air_htg_idx, 'No')

          # remove surrogate object
          runner.registerInfo(INDENT + "Removed surrogate object = #{surrogate_name}")
          surrogate.remove

        end

      end
      
    end

    # report final condition of model
    ddss = workspace.getObjectsByType('Dehumidifier:Desiccant:System'.to_IddObjectType)
    runner.registerFinalCondition("Dehumidifier:Desiccant:System = #{ddss.size}")

    return true
  end
end

# register the measure to be used by the application
HVACDehumidifierDesiccantSystem.new.registerWithApplication
