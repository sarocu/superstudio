module SetpointManagers
  def outdoor_air_reset
    OpenStudio::Model::SetpointManagerOutdoorAirReset.new(@model)
  end

  def single_zone_reheat
    OpenStudio::Model::SetpointManagerSingleZoneReheat.new(@model)
  end

  def scheduled(setpoint_schedule)
    OpenStudio::Model::SetpointManagerScheduled.new(@model, setpoint_schedule)
  end

  def follow_outdoor_air_temperature
    OpenStudio::Model::SetpointManagerFollowOutdoorAirTemperature.new(@model)
  end
end
