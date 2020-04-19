require_relative 'standard'
require_relative 'library'
require_relative 'simulation'
require_relative '../templates/templates'
require_relative '../templates/basics'
require 'openstudio'
require 'json'
require 'rainbow'
require 'whirly'
require 'fileutils'

module Superplus
  include StandardsLibrary

  def self.create_standard_model(building_type, climate_zone, standard, build_dir, debug)
    puts 'creating a new standards based prototype model 🏠 🏥 🏢 🏬 🏰 '
    modeler = StandardModeler.new(building_type, climate_zone, standard, build_dir)
    modeler.init_model(debug)
    modeler.get_model
  end

  def self.load_model(model_path)
    p = File.expand_path(model_path)
    if File.extname(p) == '.xml'
      puts 'Identified gbXML file, translating...'
      load_gbxml(p)
      return
    end

    begin
      return OpenStudio::Model::Model.load(p)
    rescue StandardError => exception
      puts '💣  error!! 💣'
      puts 'could not load OSM file'
      puts exception
    end
  end

  def self.load_gbxml(model_path)
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    begin
      model = translator.loadModel(model_path)
      puts model.get
      raise ModelLoadException, 'The gbXML file is malformed' if model.nil?
      return model
    rescue StandardError => exception
      puts '💣  error!! 💣'
      puts 'could not load XML file'
      puts exception
    end
  end

  def self.merge_geometry(json_file, model, assumptions = false)
    puts
    puts '📂 reading JSON geometry...'
    floorplan = OpenStudio::FloorplanJS.load(json_file)

    threeJS = OpenStudio::Model::ThreeJSReverseTranslator.new
    reverse_translate = threeJS.modelFromThreeJS(floorplan.get.toThreeScene(true))
    puts
    puts '🔷 merging model with the new geometry... 🔷'
    merge = OpenStudio::Model::ModelMerger.new
    Whirly.start spinner: 'dots' do
      suppress_output do
        merge.mergeModels(model, reverse_translate.get, threeJS.handleMapping)
      end
    end

    if assumptions
      puts
      puts '✍🏽  Assigning standards based assumptions...'
      model = StandardsLibrary.find_and_apply_space_types(model)
    end

    puts
    puts Rainbow('🚚 success, returning model with 🥬 fresh 🥬 geometry 🚚').blue
    model
  end

  def self.persist(model, path)
    p = OpenStudio::Path.new(path)
    model.toIdfFile.save(p, true)
    puts '💾 saved model to disc 💾'
  end

  def self.persist_xml(model, path)
    persist(model, path)

    path += '.xml'
    puts path
    p = OpenStudio::Path.new(path)
    translator = OpenStudio::GbXML::GbXMLForwardTranslator.new
    translator.modelToGbXML(model, path)
  end

  def self.add_epw(model, weather_path)
    p = File.expand_path(weather_path)
    epw = OpenStudio::EpwFile.new(p)
    OpenStudio::Model::WeatherFile.setWeatherFile(model, epw).get

    # These come straight from OS-Standards:
    weather_name = "#{epw.city}_#{epw.stateProvinceRegion}_#{epw.country}"
    weather_lat = epw.latitude
    weather_lon = epw.longitude
    weather_time = epw.timeZone
    weather_elev = epw.elevation

    site = model.getSite
    site.setName(weather_name)
    site.setLatitude(weather_lat)
    site.setLongitude(weather_lon)
    site.setTimeZone(weather_time)
    site.setElevation(weather_elev)
    model
  end

  def self.add_ddy(model, weather_path)
    ddy_file = File.expand_path(weather_path)
    if File.exist? ddy_file
      ddy_model = OpenStudio::EnergyPlus.loadAndTranslateIdf(ddy_file).get
      ddy_model.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType).sort.each do |d|
        # Import the 99.6% Heating and 0.4% Cooling design days
        ddy_list = /(Htg 99.6. Condns DB)|(Clg .4% Condns DB=>MWB)|(Clg 0.4% Condns DB=>MCWB)/
        if d.name.get =~ ddy_list
          model.addObject(d.clone)
          OpenStudio.logFree(OpenStudio::Info, 'openstudio.weather.Model', "Added #{d.name} design day.")
        end
      end
      # Check to ensure that some design days were added
      if model.getDesignDays.size.zero?
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "No design days were loaded, check syntax of .ddy file: #{ddy_file}.")
      end
    else
      OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "Could not find .ddy file for: #{ddy_file}.")
      puts Rainbow("Could not find .ddy file for: #{ddy_file}.").red
      success = false
    end
    model
  end

  def self.assign_zone_per_space(model)
    puts 'Getting all of the 🏢 spaces 🏢 in your model...'
    space_list = get_space_list(model)
    puts 'Assigning a 🔥 thermal zone ❄️ to each space...'
    space_list.each do |space|
      zone = OpenStudio::Model::ThermalZone.new(model)
      space.setThermalZone(zone)
      zone.setName(space.name.get)
    end

    model
  end

  def self.get_space_list(model)
    model.getSpaces
  end

  def self.get_surface_list(model)
    model.getSurfaces
  end

  def self.apply_wwr(model, wwr)
    surface_list = get_surface_list(model)
    surface_list.each do |surface|
      # skip non-exterior walls
      next if surface.surfaceType != 'Wall'
      next if surface.outsideBoundaryCondition != 'Outdoors'

      surface.setWindowToWallRatio(wwr)
    end

    model
  end

  def self.get_gross_area(model)
    building = model.building()
    building.get.floorArea
  end

  def self.scale_floor_area(model, floor_area)
    existing_area = get_gross_area(model)
    puts Rainbow('Existing gross floor area: ' + existing_area.to_s).yellow
    Whirly.start spinner: 'pong' do
      Whirly.status = 'Scaling geometry...'
      scalar = (floor_area / existing_area)**0.5
      new_model = BTAP::Geometry.scale_model(model, scalar, scalar, 1)
      puts Rainbow('New gross floor area: ' + get_gross_area(new_model).to_s).green
      return new_model
    end
  end

  def self.apply_template(model, template)
    mytemplates = Templates.new
    begin
      updated_model = mytemplates.__send__(template, model)
      return updated_model
    rescue StandardError => exception
      puts Rainbow('Exception occurred executing template: ').red
      puts Rainbow(exception).red
      return model
    end
  end

  def self.export_library(templates = 'all', building_types = 'all', _climate_zone = nil)
    template_path = File.join(File.dirname(__FILE__), '../../assets/example-library.json')
    raw_template = File.read(template_path)
    template_library = JSON.parse(raw_template)

    space_types = []
    os_space_types = File.join(File.dirname(__FILE__), '../../assets/space-types.csv')
    CSV.foreach(os_space_types, headers: true) do |row|
      unless templates == 'all'
        next unless templates.include? row['Template']
      end

      unless building_types == 'all'
        next unless building_types.include? row['Building Type']
      end

      uuid = SecureRandom.uuid
      space_name = row['Template'] + ' - ' + row['Building Type'] + ' - ' + row['Space Type']
      color = Random.new.bytes(3).unpack('H*')[0]
      space = { id: SecureRandom.hex(10), handle: "{#{uuid}}", name: space_name, color: "##{color}" }
      space_types.push(space)
    end

    construction_sets = []
    os_sets = File.join(File.dirname(__FILE__), '../../assets/construction-sets.csv')
    CSV.foreach(os_sets, headers: true) do |row|
      next if row['Building Type'].nil?
      unless templates == 'all'
        next if templates != row['Template']
      end

      unless building_types == 'all'
        next if building_types != row['Building Type']
      end

      uuid = SecureRandom.uuid
      set_name = row['Template'] + ' - ' + row['Building Type']
      color = Random.new.bytes(3).unpack('H*')[0]
      construction_set = { id: SecureRandom.hex(10), handle: "{#{uuid}}", name: set_name, color: "##{color}" }
      construction_sets.push(construction_set)
    end

    template_library['space_types'] = space_types
    template_library['construction_sets'] = construction_sets
    template_library
  end

  def self.suppress_output
    original_stdout = $stdout.clone
    original_stderr = $stderr.clone
    log_path = File.join(Dir.pwd, 'logs')
    FileUtils.mkdir_p(log_path) unless File.directory?(log_path)
    $stderr.reopen File.new(File.join(Dir.pwd, 'logs', 'os-stderr.txt'), 'w')
    $stdout.reopen File.new(File.join(Dir.pwd, 'logs', 'os-stdout.txt'), 'w')
    yield
  ensure
    $stdout.reopen original_stdout
    $stderr.reopen original_stderr
  end
end

class ModelLoadException < StandardError
  def initialize(msg = 'The Model Failed to Load', exception_type = 'custom')
    @exception_type = exception_type
    super(msg)
  end
end
