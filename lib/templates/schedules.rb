module BasicSchedules
    def simple_setpoint_schedule(setpoint)
        ruleset = OpenStudio::Model::ScheduleRuleset.new(@model)

        # winter:
        winter_design = OpenStudio::Model::ScheduleDay.new(@model)
        winter_design.addValue(OpenStudio::Time.new(0, 24, 0, 0), setpoint)
        ruleset.setWinterDesignDaySchedule(winter_design)

        # summer:
        summer_design = OpenStudio::Model::ScheduleDay.new(@model)
        summer_design.addValue(OpenStudio::Time.new(0, 24, 0, 0), setpoint)
        ruleset.setSummerDesignDaySchedule(summer_design)

        # default:
        default_day = ruleset.defaultDaySchedule
        default_day.addValue(OpenStudio::Time.new(0, 24, 0, 0), setpoint)

        return ruleset
    end
end