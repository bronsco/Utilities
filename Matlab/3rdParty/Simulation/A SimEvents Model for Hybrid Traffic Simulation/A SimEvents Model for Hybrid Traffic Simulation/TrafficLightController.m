classdef TrafficLightController < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    % Control zone with traffic light control applied.
    properties (Nontunable)
        capacity = 100; % Control zone capacity
        Length = 400; % Length of control zone
        simulation_step = 0.01; % Simulation step
        traffic_light_cycle = 60; % Traffic light cycle
        traffic_light_NS = 27; % Traffic light (Yellow->Red)
        traffic_light_NS_yellow = 30; % Traffic light (Red->Yellow)
        traffic_light_EW = 57; % Traffic light (Yellow->Green)
        traffic_light_EW_yellow = 60; % Traffic light (Green->Yellow)
    end
    properties (DiscreteState)
        CurrentFinalTime;
        CurrentDestination;
        numVehicles;
        numVehiclesDeparted;
        TrafficLightStatus;
        AverageFuelConsumption;
        OptimalFuelConsumption;
        AverageTravelTime;
        newArrival;
        Parallel;
        maintainFirstVehicle;
    end
    
    
    methods (Access=protected)
        
        function num = getNumInputsImpl(~)
            % Define number of inputs for system with optional inputs
            num = 2;
        end
        
        function num = getNumOutputsImpl(~)
            % Define number of outputs for system with optional outputs
            num = 2;
        end
        
        function entityTypes = getEntityTypesImpl(obj)
            % Define entity types being used in this model
            entityTypes(1) = obj.entityType('CAV', 'CAV', 1, false);
            entityTypes(2) = obj.entityType('INFO', 'INFO', 1, false);
            
        end
        
        function [input, output] = getEntityPortsImpl(~)
            % Define data types for entity ports
            input = {'CAV','INFO'};
            output = {'CAV','INFO'};
        end
        
        function [storageSpec, I, O] = getEntityStorageImpl(obj)
            % Input queue for W2E
            storageSpec(1) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for S2N
            storageSpec(2) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for E2W
            storageSpec(3) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for N2S
            storageSpec(4) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for entities /delay
            storageSpec(5) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for INFO entities
            storageSpec(6) = obj.queueFIFO('INFO', obj.capacity);
            % Input queue for INFO entities
            storageSpec(7) = obj.queueFIFO('CAV', obj.capacity);
            
            I = [5 6];
            O = [7,6];
        end
        
        function sz = getOutputSizeImpl(~)
            % Return size for each output port
            sz(1) = 1;
            sz(2) = 1;
        end
        function dt = getOutputDataTypeImpl(~)
            % Return data type for each output port
            dt(1) = 'CAV';
            dt(2) = 'INFO';
        end
        
        function cp = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            cp(1) = false;
            cp(2) = false;
        end
        
        function [name1, name2] = getInputNamesImpl(~)
            % Return input port names for System block
            name1 = 'IN';
            name2 = 'INFO';
            
        end
        
        function [name1, name2] = getOutputNamesImpl(~)
            % Return input port names for System block
            name1 = 'OUT';
            name2 = 'INFO';
            
        end
        function icon = getIconImpl(~)
            icon = sprintf('TRAFFIC LIGHT CONTROLLER');
        end
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = [1, 1];
            dt = 'double';
            cp = false;
        end
        
        function setupImpl(obj)
            obj.CurrentFinalTime = 40;
            obj.CurrentDestination = 0;
            obj.TrafficLightStatus = 0;
            obj.AverageFuelConsumption = 0;
            obj.OptimalFuelConsumption = 0;
            obj.AverageTravelTime = 0;
            obj.Parallel = 0;
            obj.numVehicles = 0;
            obj.numVehiclesDeparted = 0;
            obj.maintainFirstVehicle = 0;
            plotBGIMAGEtlc(obj.TrafficLightStatus);
        end
        
        
        function [entity, events] = INFOEntryImpl(obj, storage, entity, tag)
            if storage == 6
                obj.newArrival = entity.data.VehicleID;
                events = obj.eventDestroy();
            end
        end
        
        function [entity, events] = INFOGenerateImpl(obj, storage, entity, tag)
            switch tag
                case 'arrival'
                    entity.data.VehicleID = 0;
                    events = obj.eventForward('output', 2, 0);
            end
        end
        
        function [entity, events] = CAVGenerateImpl(obj, storage, entity, tag)
            switch tag
                case 're-generate'
                    events = obj.eventForward('output', 1, 0);
            end
        end
        
        function [entity, events] = CAVEntryImpl(obj, storage, entity, ~)
            if storage == 5 % waiting for confirmation from coordinator
                obj.numVehicles = obj.numVehicles + 1;
                [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                    dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 1);
                plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                if entity.data.ID == 1
                    events = [ obj.eventGenerate(6, 'arrival', 0, 1), ...
                        obj.eventTimer('delay',0.01), obj.eventTimer('tlc', 0.01)];
                else
                    events = [ obj.eventGenerate(6, 'arrival', 0, 1), ...
                        obj.eventTimer('delay',0.01)];
                end
                
            elseif storage == 7
                if entity.data.ID == 1
                    events = obj.eventTimer('MZ',0.01);
                else
                    events = [];
                end
            else
                if entity.data.ID == 1
                    events = obj.eventTimer('Track',0.01);
                else
                    events = [];
                end
            end
        end
        
        function [entity, events] = CAVTimerImpl(obj, storage, entity, tag)
            events = [];
            
            switch tag
                case 'Track'
                    events = [ obj.eventIterate(1, 'compute', 1), ...
                        obj.eventIterate(2, 'compute', 1), ...
                        obj.eventIterate(3, 'compute', 1), ...
                        obj.eventIterate(4, 'compute', 1), ...
                        obj.eventTimer('Track',0.01) ];
                    
                case 'delay'
                    if obj.newArrival == entity.data.ID
                        switch entity.data.Lane
                            case 1
                                events = [obj.eventIterate(5, 'compute', 1), obj.eventForward('storage', 1, 0)];
                            case 2
                                events = [obj.eventIterate(5, 'compute', 1),obj.eventForward('storage', 2, 0)];
                            case 3
                                events = [obj.eventIterate(5, 'compute', 1),obj.eventForward('storage', 3, 0)];
                            otherwise
                                events = [obj.eventIterate(5, 'compute', 1),obj.eventForward('storage', 4, 0)];
                        end
                    else
                        events = [ obj.eventIterate(5, 'compute', 1), obj.eventTimer('delay',0.01)];
                    end
                    
                case 'tlc'
                    obj.updateTrafficLight();
                    plotTLC(obj.TrafficLightStatus);
                    %                     obj.TrafficLightStatus;
                    events = obj.eventTimer('tlc',0.01);
                    
                case 'MZ'
                    events =  [obj.eventIterate(7, 'mergingzone', 1),  obj.eventTimer('MZ',0.01)];
                    %events =  obj.eventIterate(7, 'mergingzone', 1);
            end
        end
        
        function [entity, events, next] = CAVIterateImpl(obj, storage, entity, tag, status)
            events = [];
            switch tag
                case 'compute'
                    if entity.data.Position <= (obj.Length - 30) % cruising
                        [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                            dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 1);
                        plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                    elseif  entity.data.Position < 400 % adjust
                        if obj.TrafficLightStatus <= obj.traffic_light_NS % GREEN on NS, RED on EW
                            if storage == 1 || storage == 3
                                [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                                    approachIntersection(entity.data.Position, entity.data.Speed, status.position, 1);
                            else
                                [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                                    approachIntersection(entity.data.Position, entity.data.Speed, status.position, 0);
                            end
                            plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                        elseif obj.TrafficLightStatus <= obj.traffic_light_NS_yellow% RED on EW, YELLOW(RED) on NS
                            [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                                approachIntersection(entity.data.Position, entity.data.Speed, status.position, 1);
                            plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                        elseif obj.TrafficLightStatus <= obj.traffic_light_EW% GREEN on EW, RED on NS
                            if storage == 2 || storage == 4
                                [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                                    approachIntersection(entity.data.Position, entity.data.Speed, status.position, 1);
                            else
                                [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                                    approachIntersection(entity.data.Position, entity.data.Speed, status.position, 0);
                            end
                            plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                        else % YELLOW(RED) on EW, RED on NS
                            [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                                approachIntersection(entity.data.Position, entity.data.Speed, status.position, 1);
                            plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                        end
                    elseif entity.data.Position < 430 % driving in mz
                        [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                            insideIntersection(entity.data.Position, entity.data.Speed, entity.data.Acceleration);
                        
                        plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                    else % leave mz
                        events = obj.eventForward('storage', 7, 0);
                    end
                    
                    next = true;
                    
                case 'mergingzone'
                    events = [];
                    [entity.data.Position, entity.data.Speed, entity.data.Acceleration] ...
                        = dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 1);
                    plotCAVtlc(entity.data.Position, entity.data.Lane, entity.data.ID, obj.TrafficLightStatus);
                    if entity.data.Position > 830
                        if entity.data.ID == 1
                            if  obj.maintainFirstVehicle == 0
                                events = obj.eventGenerate(7, 're-generate', 0, 1);
                                obj.maintainFirstVehicle = 1;
                            else
                                events = [];
                            end
                            %
                        else
                            events = obj.eventForward('output', 1, 0);
                            % events = obj.eventDestroy();
                        end
                    end
                    %                     if status.position == status.size
                    %                         event2 = obj.eventTimer('MZ',0.01);
                    %                     end
                    %                     events = [event1, event2];
                    
                    next = true;
            end
        end
        
        %% Update Traffic Light Status
        function updateTrafficLight(obj)
            obj.TrafficLightStatus = mod(obj.TrafficLightStatus + obj.simulation_step, obj.traffic_light_cycle);
        end
        
    end
end
