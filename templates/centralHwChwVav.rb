require 'superstudio'

module CentralHwChwVavBasic
    def bootstrapCentralHwChwVavBasic(model)
        base = Basics.new(model)
        base.basic_hot_water
        base.basic_condenser_water
        base.basic_chilled_water
        base.air_system
        return base.get_model
    end
end

class Templates
    include CentralHwChwVavBasic
end