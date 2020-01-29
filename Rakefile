require 'bundler/gem_tasks'
task default: :spec

task :test_update do
  sh './test/test_update_model.sh'
end

task :test_create do
  sh './test/test_create_standard_model.sh'
end

task :test_gbxml do
  puts 'test create first:'
  sh './test/test_create_gbxml.sh'
  puts
  puts 'test update:'
  sh './test/test_update_gbxml.sh'
  puts
end
