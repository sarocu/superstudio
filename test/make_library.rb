require 'csv'
require 'json'
require 'securerandom'

raw_template = File.read('./data/example-library.json')
template_library = JSON.parse(raw_template)

space_types = []

CSV.foreach('./data/space-types.csv', headers: true) do |row|
    uuid = SecureRandom.uuid
    space_name = row['Template'] + ' - ' + row['Building Type'] + ' - ' + row['Space Type'] 
    color = Random.new.bytes(3).unpack("H*")[0]
    space = {:id=>SecureRandom.hex(10), :handle=>"{#{uuid}}", :name=>space_name, :color=>"##{color}"}
    space_types.push(space)
end

template_library['space_types'] = space_types

File.open("./data/example.json", "w") do |f|
    f.write(JSON.pretty_generate(template_library))
end