require_relative './helpers'

class Basics
    include SystemHelpers

    def initialize(model)
        @model = model
    end

    def basic_hot_water
        @hw = OpenStudio::Model::PlantLoop.new(@model)
        @hw.setName('Baseline Hot Water Plant Loop')
        sizing_object = @hw.sizingPlant
        sizing_object.setLoopType('Heating')

        boiler = OpenStudio::Model::BoilerHotWater.new(@model)
        boiler.setName('Baseline Boiler')
        @hw.addSupplyBranchForComponent(boiler)

        pump = OpenStudio::Model::PumpVariableSpeed.new(@model)
        pump.setName('Baseline Pump')
        pump.addToNode(@hw.supplyInletNode())

        return @hw
    end

    def basic_chilled_water
        @chw = OpenStudio::Model::PlantLoop.new(@model)
        @chw.setName('Baseline Chilled Water Plant Loop')
        sizing_object = @chw.sizingPlant
        sizing_object.setLoopType('Cooling')

        chiller = OpenStudio::Model::ChillerElectricEIR.new(@model)
        chiller.setName('Baseline Chiller')
        @chw.addSupplyBranchForComponent(chiller)

        pump = OpenStudio::Model::PumpVariableSpeed.new(@model)
        pump.setName('Baseline Pump')
        pump.addToNode(@chw.supplyInletNode())

        if @cw
            @cw.addDemandBranchForComponent(chiller)
        else
            basic_condenser_water
            @cw.addDemandBranchForComponent(chiller)
        end

        return @chw
    end

    def basic_condenser_water
        @cw = OpenStudio::Model::PlantLoop.new(@model)
        @cw.setName('Baseline Condenser Water Plant Loop')
        sizing_object = @cw.sizingPlant
        sizing_object.setLoopType('Condenser')

        cooling_tower = OpenStudio::Model::CoolingTowerVariableSpeed.new(@model)
        cooling_tower.setName('Baseline Cooling Tower')
        @cw.addSupplyBranchForComponent(cooling_tower)

        pump = OpenStudio::Model::PumpVariableSpeed.new(@model)
        pump.setName('Baseline Pump')
        pump.addToNode(@cw.supplyInletNode())

        return @cw
    end

    def vav_terminal(reheat=nil, availability_schedule)
        unless reheat
            return OpenStudio::Model::AirTerminalSingleDuctVAVNoReheat.new(@model, availability_schedule)
        else
            return OpenStudio::Model::AirTerminalSingleDuctVAVReheat.new(@model, availability_schedule, reheat)
        end
    end

    def air_system(fan_type)
        air_loop =  OpenStudio::Model::AirLoopHVAC.new(@model, false)
        sizing_object = OpenStudio::Model::SizingSystem.new(@model, air_loop)
        outdoor_air_control = OpenStudio::Model::ControllerOutdoorAir.new(@model)
        outdoor_air = OpenStudio::Model::AirLoopHVACOutdoorAirSystem.new(@model, outdoor_air_control)
        outdoor_air.addToNode(air_loop.supplyOutletNode)

        begin
            fan = __send__(fan_type)
            add_to_supply_outlet(fan, air_loop)
        rescue => exception
            puts 'Error creating fan, incorrect argument supplied'
            puts 'Got ' + fan_type.to_s
            puts 'Making a single speed fan instead '
            fan = single_speed_fan
            add_to_supply_outlet(fan, air_loop)
        end

        return air_loop
    end

    def single_speed_fan
        return OpenStudio::Model::FanConstantVolume.new(@model)
    end

    def variable_volume_fan
        return OpenStudio::Model::FanVariableVolume.new(@model)
    end

    def hot_water_coil
        return OpenStudio::Model::CoilHeatingWater.new(@model)
    end

    def chilled_water_coil
        return OpenStudio::Model::CoilCoolingWater.new(@model)
    end

    def add_to_supply_outlet(component, loop)
        component.addToNode(loop.supplyOutletNode)
    end

    def add_to_supply_inlet(component, loop)
        component.addToNode(loop.supplyInletNode)
    end

    def add_demand_to_loop(component, loop)
        loop.addDemandBranchForComponent(component)
    end

    def add_equip_to_zone(component, zone)
        component.addToThermalZone(zone)
    end

    def add_zone_to_loop(zone, loop)
        loop.addBranchForZone(zone)
    end

    def add_terminal_to_loop(component, loop)
        loop.addBranchForHVACComponent(component)
    end

    def get_zone_list
        return @model.getThermalZones
    end

    def get_model
        return @model
    end
end