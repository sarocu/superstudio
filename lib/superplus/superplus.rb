require_relative 'standard'
require_relative '../templates/templates'
require_relative '../templates/basics'
require 'openstudio'
require 'json'

module Superplus
    def self.create_standard_model(building_type, climate_zone, standard, build_dir, debug)
        puts 'creating a new standards based prototype model 🏠 🏥 🏢 🏬 🏰 '
        modeler = StandardModeler.new(building_type, climate_zone, standard, build_dir)
        modeler.init_model(debug)
        return modeler.get_model
    end

    def self.load_model(model_path)
        p = File.expand_path(model_path)
        begin
            return OpenStudio::Model::Model.load(p)
        rescue => exception
            puts '💣  error!! 💣'
            puts 'could not load OSM file'
            puts exception
            
        end
    end

    def self.merge_geometry(json_file, model)
        puts
        puts '📂 reading JSON geometry...'
        floorplan = OpenStudio::FloorplanJS::load(json_file)

        threeJS = OpenStudio::Model::ThreeJSReverseTranslator.new
        reverse_translate = threeJS.modelFromThreeJS(floorplan.get.toThreeScene(true))
        puts
        puts '🔷 merging model with the new geometry... 🔷'
        merge = OpenStudio::Model::ModelMerger.new
        merge.mergeModels(model, reverse_translate.get, threeJS.handleMapping())
        puts
        puts '🚚 success, returning model with 🥬 fresh 🥬 geometry 🚚'
        return model
    end

    def self.persist(model, path)
        p = OpenStudio::Path.new(path)
        model.toIdfFile.save(p, true)
        puts '💾 saved model to disc 💾'
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
        return model
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
                    OpenStudio::logFree(OpenStudio::Info, 'openstudio.weather.Model', "Added #{d.name} design day.")
                end
            end
            # Check to ensure that some design days were added
            if model.getDesignDays.size.zero?
              OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "No design days were loaded, check syntax of .ddy file: #{ddy_file}.")
            end
        else
            OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "Could not find .ddy file for: #{ddy_file}.")
            puts "Could not find .ddy file for: #{ddy_file}."
            success = false
        end
        return model
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

        return model
    end

    def self.get_space_list(model)
        return model.getSpaces
    end

    def self.get_surface_list(model)
        return model.getSurfaces
    end

    def self.apply_wwr(model, wwr)
        surface_list = get_surface_list(model)
        surface_list.each do |surface|
            # skip non-exterior walls
            next if surface.surfaceType != 'Wall'
            next if surface.outsideBoundaryCondition != 'Outdoors'

            surface.setWindowToWallRatio(wwr)
        end

        return model
    end

    def self.get_gross_area(model)
        building = model.building()
        return building.get.floorArea()
    end

    def self.scale_floor_area(model, floor_area)
        existing_area = get_gross_area(model)
        puts 'Existing gross floor area: ' + existing_area.to_s
        scalar = (floor_area / existing_area) ** 0.5

        puts '......'
        new_model = BTAP::Geometry.scale_model(model, scalar, scalar, 1)
        puts 'New gross floor area: ' + get_gross_area(new_model).to_s
        return new_model
    end

    def self.apply_template(model, template)
        mytemplates = Templates.new
        begin
            updated_model = mytemplates.__send__(template, model)
            return updated_model
        rescue => exception
            puts 'Exception occurred executing template: '
            puts exception
            return model
        end
    end
end