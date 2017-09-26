classdef Controller < matlab.DiscreteEventSystem & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    % Control zone with optimal control applied.
    
    properties (Nontunable)
        capacity = 100; % Control zone capacity
        simulation_step = 0.01; % Simulation step
        S = 30; % Length of merging zone
        L = 400; % Length of control zone
        delta = 10; % Minimum safety following distance
    end
    properties (DiscreteState)
        leftT;
        rightT;
        % network status
        numVehicles;
        numVehiclesDeparted;
        
        % performance metric
        AverageFuelConsumption;
        OptimalFuelConsumption;
        AverageTravelTime;
        
        % info waiting to be exchanged with the coordinator
        newArrival;
        CurrentFinalTime; % enter MZ
        CurrentDestination;
        CurrentExitTime; % exit MZ
        CurrentLane;
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
            % Input queue for entities / current lane -> control implemented
            storageSpec(1) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for pause/continue messages
            storageSpec(2) = obj.queueFIFO('INFO', obj.capacity);
            % Input queue for entities / current lane -> waiting for the info from the
            % coordinator
            storageSpec(3) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for entities / merging zone
            storageSpec(4) = obj.queueFIFO('CAV', obj.capacity);
            % Input queue for entities / next lane
            storageSpec(5) = obj.queueFIFO('CAV', obj.capacity);
            
            I = [3 2];
            O = [5,2];
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
            icon = sprintf('OPTIMAL CONTROLLER');
        end
        
        function [sz, dt, cp] = getDiscreteStateSpecificationImpl(~, ~)
            sz = [1, 1];
            dt = 'double';
            cp = false;
        end
        
        function setupImpl(obj)
            obj.leftT = 3/4 * obj.S; % single lane for each direction
            obj.rightT = 1/4 * obj.S;
            obj.numVehicles = 0;
            obj.numVehiclesDeparted = 0;
            obj.AverageFuelConsumption = 0;
            obj.OptimalFuelConsumption = 0;
            obj.AverageTravelTime = 0;
            obj.CurrentFinalTime = 40;
            obj.CurrentDestination = 0;
            obj.Parallel = 0;
            obj.maintainFirstVehicle = 0;
            %subplot(1, 3, 1)
            plotBGIMAGE();
        end
        
        
        function [entity, events] = INFOEntryImpl(obj, storage, entity, tag)
            % Called when a pause message enters the block
            if storage == 2
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
            %% Entering the Control Zone - waiting for info
            if storage == 3 % input port storage
                [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                    dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 1);
                plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                
                % send info packet to the coordinator
                events = [ obj.eventGenerate(2, 'arrival', 0, 1), obj.eventTimer('delay',0.01)];
            end
            
            %% Receiving the info, start to implement control
            if storage == 1
                % storage where the optimal control applied
                entity.data.ID = obj.newArrival;
                obj.numVehicles = obj.numVehicles + 1;
                
                %% Vehicle Coordination Structure
                if (entity.data.ID == 1) % first vehicle entering the network
                    entity.data.FinalTime = obj.CurrentFinalTime;
                    switch mod(entity.data.Destination - entity.data.Lane, 4)
                        case 1 % RIGHT TURN
                            entity.data.ExitTime = entity.data.FinalTime + obj.rightT / entity.data.FinalSpeed;
                        case 2 % GO STRAIGHT
                            entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                        case 3 % LEFT TURN
                            entity.data.ExitTime = entity.data.FinalTime + obj.leftT / entity.data.FinalSpeed;
                    end
                    obj.CurrentDestination = entity.data.Destination;
                    obj.CurrentLane = entity.data.Lane;
                    obj.CurrentFinalTime = entity.data.FinalTime;
                    obj.CurrentExitTime = entity.data.ExitTime;
                    obj.Parallel = 0;
                else
                    if (entity.data.Destination == obj.CurrentDestination && entity.data.Lane ~= obj.CurrentLane)
                        % different sources, same dest
                        entity.data.ExitTime = obj.CurrentExitTime + obj.delta / entity.data.FinalSpeed;
                        switch mod(entity.data.Destination - entity.data.Lane, 4)
                            case 1 % RIGHT TURN
                                entity.data.FinalTime = entity.data.ExitTime - obj.rightT / entity.data.FinalSpeed;
                            case 2 % GO STRAIGHT
                                entity.data.FinalTime = entity.data.ExitTime - obj.S / entity.data.FinalSpeed;
                            case 3 % LEFT TURN
                                entity.data.FinalTime = entity.data.ExitTime - obj.leftT / entity.data.FinalSpeed;
                        end
                        obj.CurrentDestination = entity.data.Destination;
                        obj.CurrentLane = entity.data.Lane;
                        obj.CurrentFinalTime = entity.data.FinalTime;
                        obj.CurrentExitTime = max(obj.CurrentExitTime, entity.data.ExitTime);
                        entity.data.ExitTime = obj.CurrentExitTime;
                        obj.Parallel = 0;
                    else
                        if (entity.data.Lane == obj.CurrentLane)
                            % same source, different dests
                            entity.data.FinalTime = obj.CurrentFinalTime + obj.delta / entity.data.FinalSpeed;
                            switch mod(entity.data.Destination - entity.data.Lane, 4)
                                case 1 % RIGHT TURN
                                    entity.data.ExitTime = entity.data.FinalTime + obj.rightT / entity.data.FinalSpeed;
                                case 2 % GO STRAIGHT
                                    entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                                case 3 % LEFT TURN
                                    entity.data.ExitTime = entity.data.FinalTime + obj.leftT / entity.data.FinalSpeed;
                            end
                            obj.CurrentDestination = entity.data.Destination;
                            obj.CurrentLane = entity.data.Lane;
                            obj.CurrentFinalTime = entity.data.FinalTime;
                            obj.CurrentExitTime = max(obj.CurrentExitTime, entity.data.ExitTime);
                            entity.data.ExitTime = obj.CurrentExitTime;
                            obj.Parallel = 0;
                        else
                            if hasConflicts(obj.CurrentLane, obj.CurrentDestination, entity.data.Lane, entity.data.Destination)
                                entity.data.FinalTime = obj.CurrentExitTime;
                                switch mod(entity.data.Destination - entity.data.Lane, 4)
                                    case 1 % RIGHT TURN
                                        entity.data.ExitTime = entity.data.FinalTime + obj.rightT / entity.data.FinalSpeed;
                                    case 2 % GO STRAIGHT
                                        entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                                    case 3 % LEFT TURN
                                        entity.data.ExitTime = entity.data.FinalTime + obj.leftT / entity.data.FinalSpeed;
                                end
                                obj.CurrentDestination = entity.data.Destination;
                                obj.CurrentLane = entity.data.Lane;
                                obj.CurrentFinalTime = entity.data.FinalTime;
                                obj.CurrentExitTime = max(obj.CurrentExitTime, entity.data.ExitTime);
                                entity.data.ExitTime = obj.CurrentExitTime;
                                % maintian the FIFO order both on FinalTime
                                % and ExitTIme
                                obj.Parallel = 0;
                            else
                                % no conflicts
                                if (obj.Parallel == 0)
                                    entity.data.FinalTime = obj.CurrentFinalTime;
                                    switch mod(entity.data.Destination - entity.data.Lane, 4)
                                        case 1 % RIGHT TURN
                                            entity.data.ExitTime = entity.data.FinalTime + obj.rightT / entity.data.FinalSpeed;
                                        case 2 % GO STRAIGHT
                                            entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                                        case 3 % LEFT TURN
                                            entity.data.ExitTime = entity.data.FinalTime + obj.leftT / entity.data.FinalSpeed;
                                    end
                                    obj.CurrentDestination = entity.data.Destination;
                                    obj.CurrentLane = entity.data.Lane;
                                    obj.CurrentFinalTime = entity.data.FinalTime;
                                    obj.CurrentExitTime = max(obj.CurrentExitTime, entity.data.ExitTime);
                                    entity.data.ExitTime = obj.CurrentExitTime;
                                    % maintian the FIFO order both on FinalTime
                                    % and ExitTIme
                                    obj.Parallel = 1;
                                else
                                    entity.data.FinalTime = obj.CurrentFinalTime + obj.delta / entity.data.FinalSpeed;
                                    switch mod(entity.data.Destination - entity.data.Lane, 4)
                                        case 1 % RIGHT TURN
                                            entity.data.ExitTime = entity.data.FinalTime + obj.rightT / entity.data.FinalSpeed;
                                        case 2 % GO STRAIGHT
                                            entity.data.ExitTime = entity.data.FinalTime + obj.S / entity.data.FinalSpeed;
                                        case 3 % LEFT TURN
                                            entity.data.ExitTime = entity.data.FinalTime + obj.leftT / entity.data.FinalSpeed;
                                    end
                                    obj.CurrentDestination = entity.data.Destination;
                                    obj.CurrentLane = entity.data.Lane;
                                    obj.CurrentFinalTime = entity.data.FinalTime;
                                    obj.CurrentExitTime = max(obj.CurrentExitTime, entity.data.ExitTime);
                                    entity.data.ExitTime = obj.CurrentExitTime;
                                    obj.Parallel = 0;
                                end
                            end
                        end
                    end
                end
                %%
                
                entity.data.coe = updateAcceleration(entity.data.Speed, entity.data.FinalSpeed,...
                    entity.data.ArrivalTime, entity.data.FinalTime, entity.data.Position);
                % compute the optimal fuel consumption
                entity.data.OptimalFuelConsumption ...
                    = optimizeFuelConsumption(entity.data.coe, entity.data.ArrivalTime, entity.data.FinalTime);
                if entity.data.ID == 1
                    events = obj.eventTimer('CZ',0.01);
                else
                    events = [];
                end
                %                 events = obj.eventTimer('Track',0.5);
            end
            
            %% Entering the Merging Zone
            if storage == 4
                if entity.data.ID == 1
                    events = obj.eventTimer('MZ',0.01);
                else
                    events = [];
                end
                
                % Calculate performance metric in real time:
                % Average Fuel Consumption and Average Travel Time over the control zone for the whole network
                obj.AverageFuelConsumption = obj.AverageFuelConsumption * obj.numVehiclesDeparted + entity.data.FuelConsumption;
                obj.OptimalFuelConsumption = obj.OptimalFuelConsumption * obj.numVehiclesDeparted + entity.data.OptimalFuelConsumption;
                obj.AverageTravelTime = obj.AverageTravelTime * obj.numVehiclesDeparted + entity.data.FinalTime - entity.data.ArrivalTime;
                obj.numVehiclesDeparted = obj.numVehiclesDeparted + 1;
                obj.AverageFuelConsumption = obj.AverageFuelConsumption / obj.numVehiclesDeparted;
                obj.OptimalFuelConsumption = obj.OptimalFuelConsumption / obj.numVehiclesDeparted;
                obj.AverageTravelTime = obj.AverageTravelTime / (obj.numVehiclesDeparted*1000);
                
                % Plot the performance metric in real time
                plotPerformanceMetrics(obj.AverageFuelConsumption, obj.OptimalFuelConsumption, obj.AverageTravelTime);
                %                 ShowPerformace(obj.AverageTravelTime, obj.AverageFuelConsumption, obj.OPtimalFuelConsumption);
            end
            
            %% Entering the next intersection
            if storage == 5 % leave the merging zone and enter the next lane
                switch mod(entity.data.Destination - entity.data.Lane, 4)
                    case 1
                        if mod(entity.data.Lane + 3, 4) == 0
                            entity.data.Lane = 4;
                        else
                            entity.data.Lane = mod(entity.data.Lane + 3, 4); % new current lane
                        end
                        entity.data.Position = obj.L + obj.S; % reset the position
                    case 3
                        if mod(entity.data.Lane + 1, 4) == 0
                            entity.data.Lane = 4;
                        else
                            entity.data.Lane = mod(entity.data.Lane + 1, 4);
                        end
                        entity.data.Position = obj.L + obj.S;
                end
                if entity.data.ID == 1
                    events = obj.eventTimer('nextCZ',0.01);
                else
                    events = [];
                end
            end
            
        end
        
        function [entity, events] = CAVTimerImpl(obj, storage, entity, tag)
            events = [];
            
            switch tag
                case 'CZ' % control zone - control
                    events = [ obj.eventIterate(1, 'optimal', 1), obj.eventTimer('CZ',0.01) ];
                    
                case 'delay' % control zone - delay
                    if obj.newArrival == entity.data.ID
                        events = [ obj.eventIterate(3, 'optimal', 1), obj.eventForward('storage',1, 0) ];
                    else
                        events = [ obj.eventIterate(3, 'optimal', 1), obj.eventTimer('delay',0.01)];
                    end
                    
                case 'MZ' % merging zone
                    events =  [obj.eventIterate(4, 'mergingzone', 1),  obj.eventTimer('MZ',0.01)] ;
                    
                case 'nextCZ'
                    events =  [obj.eventIterate(5, 'cruise', 1),  obj.eventTimer('nextCZ',0.01)] ;
            end
            
            
        end
        
        function [entity, events, next] = CAVIterateImpl(obj, storage, entity, tag, status)
            events = [];
            switch tag
                case 'optimal'
                    if storage == 3
                        % compute the dynamics based on the latest control
                        % cruise
                        [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                            dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 1);
                    else
                        % compute the dynamics based on the latest control
                        % control
                        [entity.data.Position, entity.data.Speed, entity.data.Acceleration] = ...
                            dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 0);
                    end
                    plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                    
                    %% compute the real fuel consumption
                    entity.data.FuelConsumption = computeFuelConsumption(entity.data.FuelConsumption, ...
                        entity.data.Speed, entity.data.Acceleration, obj.simulation_step);
                    % entering the merging zone
                    if entity.data.Position >= 400
                        events = obj.eventForward('storage', 4, 0);
                    else
                        events = [];
                    end
                    next = true;
                    
                case 'cruise'
                    [entity.data.Position, entity.data.Speed, entity.data.Acceleration] ...
                        = dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 1);
                    plotCAV(entity.data.Position, entity.data.Lane, entity.data.ID);
                    
                    if entity.data.Position > 850
                        if entity.data.ID == 1
                            if  obj.maintainFirstVehicle == 0
                                events = obj.eventGenerate(5, 're-generate', 0, 1);
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
                    next = true;
                    
                case 'mergingzone'
                    [entity.data.Position, entity.data.Speed, entity.data.Acceleration] ...
                        = dynamics(entity.data.coe, entity.data.Position, entity.data.Speed, 1);
                    plotCAVInMZ(entity.data.Position, entity.data.Lane, entity.data.Destination, entity.data.ID, ...
                        obj.leftT, obj.rightT);
                    switch mod(entity.data.Destination - entity.data.Lane, 4)
                        case 1 % right turn
                            if entity.data.Position >= 400 + 1 / 2 * obj.rightT * pi
                                events = obj.eventForward('storage', 5, 0);
                            end
                        case 2 % go straight
                            if entity.data.Position >= 400 + obj.S
                                events = obj.eventForward('storage', 5, 0);
                            end
                        case 3
                            if entity.data.Position >= 400 + 1 / 2 * obj.leftT * pi% left turn
                                events = obj.eventForward('storage', 5, 0);
                            end
                    end
                    next = true;
                    
                    
            end
        end
    end
end
