require 'openstudio'
require 'openstudio-standards'

class StandardModeler
    def initialize(building_type='LargeOffice', climate_zone='ASHRAE 169-2006-5A', standard='90.1-2013', build_dir=__dir__)
        @building_type = building_type
        @climate_zone = climate_zone
        @standard = standard
        @build_dir = File.expand_path(build_dir)
    end

    def init_model(debug=true)
        @model = OpenStudio::Model::Model.new()
        @standardModel = Standard.build(@standard)
        @standardModel.model_create_prm_baseline_building(@model, @building_type, @climate_zone, @build_dir, debug)
    end

    def get_model
        return @model
    end
end