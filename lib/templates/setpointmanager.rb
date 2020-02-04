module SetpointManagers
    def outdoor_air_reset
        return OpenStudio::Model::SetpointManagerOutdoorAirReset.new(@model)
    end

    def single_zone_reheat
        return OpenStudio::Model::SetpointManagerSingleZoneReheat.new(@model)
    end

    def scheduled(setpoint_schedule)
        return OpenStudio::Model::SetpointManagerScheduled.new(@model, setpoint_schedule)
    end

    def follow_outdoor_air_temperature
        return OpenStudio::Model::SetpointManagerFollowOutdoorAirTemperature.new(@model)
    end
end