require_relative 'standard'
require 'openstudio'
require 'json'

module Superplus
    def self.create_standard_model(building_type, climate_zone, standard, build_dir, debug)
        puts 'creating a new standards based prototype model 🏠 🏥 🏢 🏬 🏰 '
        modeler = StandardModeler.new(building_type, climate_zone, standard, build_dir)
        modeler.init_model(debug)
        return modeler.get_model
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
        p = OpenStudio::Path.new(weather_path)
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
end