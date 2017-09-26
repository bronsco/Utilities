function options = generategapolyfitnoptions(options, maxTerms)
% generategapolyfitnoptions: generates or completes an options structure
% for the function gapolyfitn. Required when options structure is absent or
% incomplete
%
% Input
%
%   options - A structure of options for the genetic algorithm fit. Missing
%             fields, or the entire structure if options == [], will be
%             supplied with the following default options:
%
%     options.GGAP = 0.8:     Generation gap, how many new individuals 
%                             are created at each generation through
%                             mating
%        
%     options.INSR = 0.9:     Insertion rate, how many of the offspring 
%                             are inserted
%         
%     options.MUTR = 0.2:     Mutation rate, determines the chance that
%                             an individual in the population will
%                             undergo a mutation. Reduces with each
%                             generation
%                                 
%     options.MIGR = 0.2:     Migration rate between subpopulations,
%                             what factor of the population moves from
%                             one subpopulation to another during
%                             migration intervals when using a
%                             multi-poputation algorithm.
%         
%     options.MIGGEN = 20:    Number of generations between migration 
%                             (isolation time)
% 
%     options.TERMVAL = 1e-8: Termination value, if a value within this
%                             distance from the global minimum (0) is
%                             reached the procedure is terminated
% 
%     options.SEL_F = 'sus':  Name of selection function to be used,
%                             default is 'sus' which is the stochastic
%                             universal selection function from the GA
%                             toolbox provided by the university of
%                             sheffield
% 
%     options.DOSAVE = 0:     Determines whether the state of the
%                             genetic algorithm is saved at each 
%                             iteration. if zero, no save is performed,
%                             if 1 the current state is saved in the
%                             file named in options.SAVEFILE
%         
%     options.SAVEFILE = 'gapolyfitoutput.mat': Save file name, will be
%                                               saved in the current 
%                                               directory, unless the
%                                               user specifies a dir
%
%     options.LOADFILE = 'gapolyfitoutput.mat': Load file name, if provided, 
%                                               state will be loaded from
%                                               this file to resume a prior 
%                                               run
%                                               
% 
%     options.SUBPOP:         Number of subpopulations, chosen on the
%                             basis of the max number of terms in the
%                             polynomial
%         
%     options.NIND:           Number of individuals per subpopulations,
%                             also chosen based on the max number of
%                             terms in the polynomial
%         
%     options.MAXGEN = 1000:  Max number of generations
%         
%     options.VERBOSE = 0:    If 1, some info on the algorithm progress and
%                             figures are printed, if 0 this output is not
%                             provided
%
%     options.GRAPHS = 0:     If 1, some graphs of progress are printed, if
%                             zero, they are not displayed. If omitted,
%                             defaults to same value as options.VERBOSE
%                            
%     options.SCOREMETHOD = 11: Integer which determines the method used to
%                               score the polynomial fit. The options are
%                               as follows:
%                               1 - mean squared error (mse)  
%                               2 - normalised mean squared error (nmse)
%                               3 - root mean squared error (rmse)
%                               4 - normalised root mean squared error (nrmse)
%                               5 - mean absolute error (mae)
%                               6 - mean  absolute relative error  (mare)
%                               7 - coefficient of correlation (r)
%                               8 - coefficient of determination (r2)
%                               9 - coefficient of efficiency (e)
%                               10 - maximum absolute error 
%                               11 - maximum absolute relative error (mxare) 
%
%      options.MCORE = false: Determines whether the multicore package is
%                             used to distribute the work amoung multiple
%                             computer cores
%
%      options.MCOREDIR = cd: The directory multicore will use to store
%                             temporary files if the options.MCORE = true
%                             option is chosen, default is the current
%                             directory
%
%    polyStruct - A structure containing information about the polynomial
%                 to be fitted. There should be five members:
%
%                 tVars: column matrix of the independent variables of the
%                 data to be fitted
%
%                 tData: column vector the dependent variables
%
%                 vars: the number of variables (i.e. size(tVars,2))
%
%                 maxTerms: the maximum number of term groups to be used
%
%                 maxPower: the total maximum power of any term (i.e. the
%                 maximum that the sum of all of the powers in a term can
%                 be)
%
%
% Output:
%
%   options - completed options structure with absent values replaced with
%             defaults
%
% Author:   Richard Crozier
% Release Date: 06 OCT 2009
%

    % Note that options are in capitals to avoid case errors
    
    if isempty(options)
        % Generation gap, how many new individuals are created
        options.GGAP = 0.8;
        
        % Insertion rate, how many of the offspring are inserted
        options.INSR = 0.9;
        
        % Mutation rate; only a factor, for poly optimisation,this will be
        % dependent on generation.
        options.MUTR = 0.2;
        
        % Migration rate between subpopulations
        options.MIGR = 0.2;
        
        % Number of generations between migration (isolation time)
        options.MIGGEN = 20;
        
        % Value for termination if minimum reached
        options.TERMVAL = 1e-8;
        
        % Name of selection function
        options.SEL_F = 'sus';
        
        % Determines whether the state of the genetic algorithm is saved at
        % each iteration. if zero, no save is performed, if 1 the current
        % state is saved in the file in options.SAVEFILE
        options.DOSAVE = 0;

        options.SAVEFILE = 'gapolyfitoutput.mat';
        
        options.LOADFILE = '';

        % Number of subpopulations
        options.SUBPOP = 2 * floor(sqrt(maxTerms));

        % Number of individuals per subpopulations
        options.NIND = 20 + 5 * floor(maxTerms/50);
        
        if options.SUBPOP * options.NIND > 500
            options.SUBPOP = 10;
            options.NIND = 50;
        end
        
        % Max number of generations
        options.MAXGEN = 1000; 
        
        options.VERBOSE = 0;   % If 1, some info on the algorithm progress 
                               % and figures are printed, if 0 this output
                               % is not provided
                               
        options.GRAPHS = 0;    % If 1 some graphs of progress will be displayed
        
        % This is the method of scoring the fit, default option is mean
        % absolute relative error, number 11                      
        options.SCOREMETHOD = 11;
        
        options.MCORE = false;
        
        options.MCOREDIR = cd;

    else
        
        if ~isfield(options, 'GGAP')
            options.GGAP = 0.8;
        end
        
        if ~isfield(options, 'INSR')
            options.INSR = 0.9;
        end
        
        if ~isfield(options, 'MUTR')
            options.MUTR = 0.1;
        end
        
        if ~isfield(options, 'MIGR')
            options.MIGR = 0.2;
        end
        
        if ~isfield(options, 'MIGGEN')
            options.MIGGEN = 20;
        end
        
        if ~isfield(options, 'TERMVAL')
            options.TERMVAL = 1e-8;
        end
        
        if ~isfield(options, 'SEL_F')
            options.SEL_F = 'sus';
        end
        
        if ~isfield(options, 'DOSAVE')
            options.DOSAVE = 0;
        end
        
        if ~isfield(options, 'SAVEFILE')
            options.SAVEFILE = 'gapolyfitoutput.mat';
        end
        
        if ~isfield(options, 'LOADFILE')
            options.LOADFILE = '';
        end
        
        if ~isfield(options, 'SUBPOP') && ~isfield(options, 'NIND')
            options.SUBPOP = 2 * floor(sqrt(maxTerms)); 
            options.NIND = 20 + 5 * floor(maxTerms/50);        
            if options.SUBPOP * options.NIND > 500
                options.SUBPOP = 10;
                options.NIND = 50;
            end
        end
        
        if ~isfield(options, 'SUBPOP') && isfield(options, 'NIND')
            options.SUBPOP = 1;
        end
        
        if isfield(options, 'SUBPOP') && ~isfield(options, 'NIND')
            options.NIND = 20 + 5 * floor(maxTerms/50);
            if options.SUBPOP * options.NIND > 500
                options.NIND = floor(500 / options.SUBPOP);
            end
        end
        
        if ~isfield(options, 'MAXGEN')
            options.MAXGEN = 1000;
        end
        
        if ~isfield(options, 'VERBOSE')
            
            options.VERBOSE = 0;
            
            if ~isfield(options, 'GRAPHS')
                options.GRAPHS = 0;
            end
            
        else
            if ~isfield(options, 'GRAPHS') 
                if options.VERBOSE == 0
                    options.GRAPHS = 0;
                else
                    options.GRAPHS = 1;
                end
            end
        end

        if ~isfield(options, 'SCOREMETHOD')
            options.SCOREMETHOD = 11;
        end
        
        if ~isfield(options, 'MCORE')
            options.MCORE = false;
        else
            if options.MCORE == true
                if exist('startmulticoremaster', 'file') ~= 2
                    warning('generategapolyfitnoptions:notFoundInPath', 'The multicore option was chosen but startmulticoremaster was not found\non the matlab path, continuing without using multicore (i.e. options.MCORE is now set to false')
                    options.MCORE = false;
                else
                    if ~isfield(options, 'MCOREDIR')
                        options.MCOREDIR = cd;
                    end
                end
            end
        end
        
    end

end