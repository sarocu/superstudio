require 'superstudio'

module CentralHwChwVavBasic
    def bootstrapCentralHwChwVavBasic(model)
        base = Basics.new(model)
        hw = base.basic_hot_water
        cw = base.basic_condenser_water
        chw = base.basic_chilled_water
        air = base.air_system(:single_speed_fan)
        hw_coil = base.hot_water_coil
        chw_coil = base.chilled_water_coil

        # Hook up components:
        base.add_to_supply_outlet(hw_coil, air)
        base.add_to_supply_outlet(chw_coil, air)
        base.add_demand_to_loop(hw_coil, hw)
        base.add_demand_to_loop(chw_coil, chw)

        # Add VAVs for each zone and add zone to air system:
        availability_schedule = base.always_on_availability_schedule
        zone_list = base.get_zone_list
        zone_list.each do |zone|
            reheat = base.hot_water_coil
            base.add_demand_to_loop(reheat, hw)
            vav = base.vav_terminal(reheat, availability_schedule)
            base.add_terminal_to_loop(vav, air)
            base.add_zone_to_loop(zone, air)
        end

        return base.get_model
    end
end

class Templates
    include CentralHwChwVavBasic
end