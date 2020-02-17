require 'openstudio-standards'
require 'json'

module StandardsLibrary
  def self.find_and_apply_space_types(model, json_file)
    puts
    puts '🔭 looking for space types...'
    json_path = File.open(File.expand_path(json_file))
    floorspacejs = JSON.load(json_path)
    space_types = floorspacejs['space_types']
    floorspacejs['stories'].each do |story|
      story['spaces'].each do |space|
        puts space['name']
      end
    end

    model
  end
end
