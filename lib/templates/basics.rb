class Basics
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
    end

    def vav_terminals

    end

    def air_system
        air_loop =  OpenStudio::Model::AirLoopHVAC.new(@model, false)
        sizing_object = OpenStudio::Model::SizingSystem.new(@model, air_loop)
    end

    def get_model
        return @model
    end
end