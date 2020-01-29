require 'openstudio-standards'

module SystemHelpers
  def get_standard(standard = '90.1-2013')
    Standard.build(standard)
  end

  def always_on_availability_schedule
    OpenStudio::Model::ScheduleCompact.new(@model, 1)
  end

  def heating_setpoint_by_occupancy(occupancy)
  end

  def cooling_setpoint_by_occupancy(occupancy)
  end
end
