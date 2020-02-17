Gem::Specification.new do |s|
  s.name = 'superstudio'
  s.version = '0.1.0'
  s.date = '2019-12-19'
  s.summary = 'OpenStudio automation wrapper'
  s.description = 'CLI for bootstrapping energy models'
  s.authors = ['Sam Currie']
  s.email = 'sam@sarocu.com'
  s.files = [
    'lib/superplus/standard.rb',
    'lib/superplus/superplus.rb',
    'lib/superplus/library.rb',
    'lib/templates/basics.rb',
    'lib/templates/templates.rb',
    'lib/templates/basics.rb',
    'lib/templates/helpers.rb',
    'lib/templates/setpointmanager.rb',
    'lib/templates/schedules.rb',
    'lib/superstudio.rb',
    'assets/space-types.csv',
    'assets/example-library.json',
    'assets/construction-sets.csv'
  ]
  s.homepage = 'https://www.sarocu.com/'
end
