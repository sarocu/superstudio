require 'openstudio-standards'
require 'json'
require 'rainbow'

module StandardsLibrary
  def self.find_and_apply_space_types(model)
    puts
    puts '🔭 looking for space types...'

    standard_spaces = {}
    modelers = {}
    model.getSpaceTypes.each do |space_type|
      next if space_type.spaces.empty?
      details = space_type.name.get.split(' - ')
      search = {
        'template' => details[0],
        'building_type' => details[1],
        'space_type' => details[2]
      }
      begin
        if modelers.key?(search['template'])
          modeler = modelers[search['template']]
        else
          modeler = Standard.build(search['template'])
          modelers[search['template']] = modeler
        end

        next if modeler.standards_data.empty?
        # properties = modeler.model_find_object(modeler.standards_data['space_types'], search)
        standard_spaces[space_type.name.get] = search
      rescue StandardError => exception
        puts Rainbow('Issues getting space type data from OS-Standards').red
        puts search
        puts exception
        next
      end
      space_type.setStandardsBuildingType(search['building_type'])
      space_type.setStandardsSpaceType(search['space_type'])
      space_type.setStandardsTemplate(search['template'])
      modeler.space_type_apply_internal_loads(space_type, true, true, true, true, true, true)
      modeler.space_type_apply_internal_load_schedules(space_type, true, true, true, true, true, true, true)
    end
    puts Rainbow("Found #{standard_spaces.length} space types defined in your model").blue
    puts Rainbow("Found #{modelers.length} energy code templates").blue

    remove_unused_space_types(model)
  end

  def self.remove_unused_space_types(model)
    model.getSpaceTypes.each do |space_type|
      space_type.remove if space_type.spaces.empty?
    end
    model
  end
end
