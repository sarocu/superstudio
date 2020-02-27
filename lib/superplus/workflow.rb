require 'openstudio-model-articulation'

# Require all of the measures from the articulation gem:
include OpenStudio::ModelArticulation
ext = Extension.new
measure_path = File.join(ext.root_dir, 'lib', 'measures', '**', 'measure.rb')
Dir.glob(measure_path).each { |f| require f }

module WorkflowHelper
  def new_workflow
    empty_workflow = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(empty_workflow)
    [empty_workflow, runner]
  end
end
