function [settings, population, problem, stats, h, f] = update_settings(settings, population, problem, stats, h, f)
%UPDATE_SETTINGS 

%% Tests the basic halting criteria
settings.halt = ((toc(stats.start_time)>settings.time_lim)||(stats.gen>=settings.n_ger)||(population.t > settings.tenure));

%% Tests the takeover
if settings.takeover_reinitialize 
    % if the there is a valid value for the parents
    if (~isnan(population.fx))
        % we sort the population
        sorted = sort(population.fx(1:settings.n_ind));
        % and compare the best with the median value
        if problem.minimization
            if sorted(1)==sorted(round(settings.n_ind/2))
                settings.takeover = true;
            else
                settings.takeover = false;
            end
        else
            if sorted(settings.n_ind)==sorted(round(settings.n_ind/2))
                settings.takeover = true;
            else
                settings.takeover = false;
            end
        end
    end
    if settings.takeover 
        settings.reinitialize = true;
    end
end

%% Comunication with the real-time interface
if (settings.realtime_control)
    % All the functions "set" must be inside a "if" in order not the 
    % disrupt the interaction with the user unless it is a need    
    
    
    % Mutation
    str = get(h.text3,'String');
    % If we have to update, we get new value into the settings of 
    % initial values, into the population parameters and update the string
    if (strcmp(str(1:8),'Updating'))
        population.mp(1:settings.n_ind) = get(h.mp,'Value');
        str = ['Mutation Probability = ', num2str(get(h.mp,'Value')*100), '%'];
        set(h.text3,'String',str);
        settings.mp = get(h.mp,'Value');
    else
        % If there is no update to do we check 
        % If the mean value has moved from the initial value in settings
        average_mp = mean(population.mp(1:settings.n_ind));
        if abs(settings.mp - average_mp) > 0.001
            % We display the new value
            str = ['Mutation Probability = ', num2str(average_mp*100), '%'];
            set(h.text3,'String',str);
            % If the user is not using the control bar
            % Then the control bar is close to the old settings value and
            if abs(get(h.mp,'Value') - settings.mp) < 0.001
                % And we can update the mutation value in the bar
                set(h.mp,'Value',average_mp);
                % And also in the settings as future reference for where
                % the bar position should be
                settings.mp = average_mp;
            end
        end
    end
    
    
    % Crossover
    str = get(h.text4,'String');
    % If we have to update, we get new value into the settings of 
    % initial values, into the population parameters and update the string
    if (strcmp(str(1:8),'Updating'))
        population.cp(1:settings.n_ind) = get(h.cp,'Value');
        str = ['Crossover Probability = ', num2str(get(h.cp,'Value')*100), '%'];
        set(h.text4,'String',str);
        settings.cp = get(h.cp,'Value');
    else
        % If there is no update to do we check 
        % If the mean value has moved from the initial value in settings
        average_cp = mean(population.cp(1:settings.n_ind));
        if abs(settings.cp - average_cp) > 0.001
            % We display the new value
            str = ['Crossover Probability = ', num2str(average_cp*100), '%'];
            set(h.text4,'String',str);
            % If the user is not using the control bar
            % Then the control bar is close to the old settings value and
            if abs(get(h.cp,'Value') - settings.cp) < 0.001
                % And we can update the mutation value in the bar
                set(h.cp,'Value',average_cp);
                % And also in the settings as future reference for where
                % the bar position should be
                settings.cp = average_cp;
            end
        end
    end
    
    % Elitism
    str = get(h.text5,'String');
    % If we have to update, we get new value into the settings of 
    % initial values, into the population parameters and update the string
    if (strcmp(str(1:8),'Updating'))
        settings.elitism = get(h.elitism,'Value');
        str = ['Elitism = ', num2str(settings.elitism*100), '%'];
        set(h.text5,'String',str);
    end
    
    % Scaling
    options = get(h.scaling,'String');
    settings.scaling = options{get(h.scaling, 'Value')};
    f.scaling = str2func(['scaling_',settings.scaling]);
    
    % Selection
    options = get(h.selection,'String');
    settings.selection = options{get(h.selection, 'Value')};
    f.selection = str2func(['selection_',settings.selection]);
    
    % Adaptation
    options = get(h.adaptation,'String');
    settings.adaptation = options{get(h.adaptation, 'Value')};
    f.adaptation = str2func(['adaptation_',settings.adaptation]);
    
    % Auto - Reinitialization at Takeover
    settings.takeover_reinitialize = get(h.takeover_reinitialize,'Value');
    
    % Stops
    if (strcmp(get(h.stop,'Enable'),'off'))
        settings.halt = true;
    end
    % Reinitializes
    if (strcmp(get(h.reinitialize,'Enable'),'off'))
        settings.reinitialize = true;
        set(h.reinitialize,'Enable','on');
    end
end



end

