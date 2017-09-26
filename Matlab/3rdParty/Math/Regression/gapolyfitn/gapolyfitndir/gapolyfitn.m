function [polymodel, Best, IndAll] = gapolyfitn(indepvar, depvar, varargin)
% gapolyfitn: optimises the functional form of a multi-dimensional
% polynomial fit to experimental data
%
% This function implements a method of using genetic algorithms to optimise
% the form of a polynomial, i.e. reducing the number of terms required in
% comparison to a least-squares fit using all possible terms, as described
% in the following paper:
%
% Clegg, J. et al, "The use of a genetic algorithm to optimize the
% functional form of a multi-dimensional polynomial fit to experimental
% data", 2005 IEEE Congress on Evolutionary Computation, 928-934,
% Edinburgh, September, 2005
%
% A general polynomial of n variables can be represented as follows:
%
% a1 * x1^2 * x2^4 * x3^1 * xn^p + a2 * x_1^6 * x2^3 * x3^1 * xn^p + ...
%
% A linear least-square fit can find the values of the coefficients,
% represented as 'a' above, such that the error between the function and a
% set of data is minimized. If the functional form of the data is not known
% in advance this can require that all possible combinations of terms and
% powers up to a given size are used. As the number of terms in a
% polynomial is given by (n+(m-1))! / (n!)(m-1)! where n is the maximum
% power used and m is the number of variables, the number of all possible
% terms can become very large for multivariable models. For example, a
% model with 12 variables of up to order 8 would require 75582 terms.
% Furthermore this can require the inversion of an extremely large matrix
% in order to evaluate the regression model.
%
% This function generates a population of polynomial forms which are each a
% subset of the set of all possible terms and evaluates them for their fit
% to the model data as given by the R-squared value returned by the
% function polyfitn. The population is then evolved using a genetic
% algorithm based on their relative scores. Evolution is achieved by mating
% successful individuals and the introduction of random mutations. 
%
% The function makes use of the free GA toolbox from the University of
% Sheffield Evolutionary Computing Team in the uk available here:
%
% http://www.shef.ac.uk/acse/research/ecrg/gat.html
%
% but the crucial subfunctions objpolyfit, crtpolyp, recpoly and mutpoly
% could no doubt easily be used with the MATLAB Genetic Algorithm and
% Direct search toolbox.
%
% This function can use the multicore package provided on the file exchange
% but it is not required, simply always use the options.MCORE = false
% option (the default in any case).
%
% Required/Reccomended functions can be currently found here:
%
% GA toolbox (required):
% http://www.shef.ac.uk/acse/research/ecrg/gat.html
% 
% polyfitn (required):
% http://www.mathworks.co.uk/matlabcentral/fileexchange/10065
%
% gfit2 (required):
% http://www.mathworks.co.uk/matlabcentral/fileexchange/22020
%
% muticore (optional):
% http://www.mathworks.co.uk/matlabcentral/fileexchange/13775
%
% Syntax
%
% [polymodel, Best, IndAll] = gapolyfitn(indepvar, depvar, maxTerms, maxPower, options, Chrom)
% 
% [polymodel] = gapolyfitn(indepvar, depvar, IndAll)
%
% Input:  
%
%   indepvar - (n x p) array of independent variables as columns
%              n is the number of data points
%              p is the dimension of the independent variable space
%
%              If n == 1, then it is assumed there is a single independent
%              variable.
%
%   depvar   - (n x 1 or 1 x n) vector, the dependent variable
%              length(depvar) must be n.
%
%   maxTerms - scalar value of the maximum number of allowed terms in the
%              polynomial where a 'term' refers to a group of variables
%              such as x^2*x^4*x^1*x^p
%
%   maxPower - scalar, the maximum value the sum of the powers in a term
%              group can have, e.g. if maxPower == 8, for a 3 variable
%              function, this is illustrated in the table below:
%
%                 Term       Total Power    Allowed?
%              x^2*x^4*x^1    2+4+1 = 7       Yes
%              x^2*x^4*x^3    2+4+3 = 9        No
%              x^0*x^0*x^8    0+0+8 = 8       Yes
%              x^1*x^0*x^8    1+0+8 = 9        No
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
%    Chrom     - Matrix containing initial population of individuals with
%                which to begin the GA search, must be of size
%                (options.NIND x (maxTerms*(size(indepvar,2)+1))). 
%                Individuals are encoded as a series of integers with the
%                following format:
%
%                [A p11 p12 p1n A p21 p22 p2n A p31 p32 pkn ... ]
%
%                Where A is a placeholder value with value 1 or 0. If 1 the
%                term is active and will be used, if 0 the term is inactive
%                and will not be used (it will be deleted before performing
%                a regression). The p values are the powers of each
%                variable in that term.
%
%                e.g.
%
%                 A        A        A        A
%                [1 2 4 4  1 3 1 5  0 6 2 2  1 0 4 0]
%
%                encodes:
%
%                a1*x1^2*x2^4*x3^4 + a2*x1^3*x2*x3^5 + a3*x2^4
%                
%                As the third term is inactive due to a zero in the
%                placeholder position (shown above) and hence is ignored.
%                Terms should not be repeated to avoid least square
%                algoithm being overspecified
%
% Output:
%
%   polymodel - A structure containing the regression model as produced by
%               the function polyfitn with the members described below
%               polymodel.ModelTerms = list of terms in the model
%               polymodel.Coefficients = regression coefficients
%               polymodel.ParameterVar = variances of model coefficients
%               polymodel.ParameterStd = standard deviation of model coefficients
%               polymodel.R2 = R^2 for the regression model
%               polymodel.RMSE = Root mean squared error
%               polymodel.VarNames = Cell array of variable names as parsed
%               from a char based model specification.
%
%   Best      - (n x 3) matrix. The first column contains the best score in
%               each generation. The second column is the mean value of the
%               population scores at each generation. The third colum is
%               the number of function evaluations performed between each
%               generation.
%
%   IndAll    - Matrix containing the best individual's chromosome at each
%               generation. One row corresponds to one individual in the
%               same format at that of Chrom (see above).
%
% Author:   Richard Crozier
% Release Date: 06 OCT 2009
%

    if nargin == 3

        % return the best model found so far from IndAll
        IndAll = varargin{1};
        
        % Fit the optimised polynomial form to determine the coefficients
        polymodel = polyVec2polyfit(indepvar, depvar, IndAll(end,:));
        
        Best = [];
        IndAll = [];

    else
        % perform the investigation
        maxTerms = varargin{1};
        maxPower = varargin{2};
        
        if numel(varargin) < 3
            options = [];
        else
            options = varargin{3};
        end
        
        if numel(varargin) > 3
            Chrom = varargin{4};
        end
        
        % Construct problem description structure for passing into the
        % objective function
        polyStruct.tVars = indepvar;
        polyStruct.tData = depvar;
        polyStruct.maxTerms = maxTerms;
        polyStruct.maxPower = maxPower;
        polyStruct.vars = size(indepvar,2);

        if isfield(options, 'fitTestData') && isfield(options, 'fitTestVars')
            polyStruct.fitTestData = options.fitTestData;
            polyStruct.fitTestVars = options.fitTestVars;
            options = rmfield(options, 'fitTestData');
            options = rmfield(options, 'fitTestVars');
        elseif ~isfield(options, 'fitTestData') && ~isfield(options, 'fitTestVars')
            % everything's ok, the fit data will be used to score the polys
        else
            warning('CROZIER:gapolyfitn:missingFitTestData', 'Only either fitTestData or fitTestVars provided, both required to test with unique data')
            % remove redundant data from memory
            if isfield(options, 'fitTestData')
                options = rmfield(options, 'fitTestData');
            elseif isfield(options, 'fitTestVars')
                options = rmfield(options, 'fitTestVars');
            end
        end

        % Parse or create the input options structure assigning default values
        % where necessary
        if nargin < 5
            options = generategapolyfitnoptions([], maxTerms);
        else
            if ~isfield(options, 'LOADFILE')
                options = generategapolyfitnoptions(options, maxTerms);
            else
                if ~strcmp(options.LOADFILE, '')
                    if options.VERBOSE == 1
                        disp('Loading previous state from disc')
                    end

                    load(options.LOADFILE);

                    options.LOADFILE = 'loaded';

                    gen = gen - 1;

                    if exist('Chrom','var')
                        if options.VERBOSE == 1
                            disp('Chromosome successfully loaded')
                        end
                    else
                        error('Chromosome failed to load, exiting function')
                    end

                else
                    options = generategapolyfitnoptions(options, maxTerms);
                end

            end

        end

        if options.NIND < 2
            error('There must be at least 2 individuals per population')
        end

        % Add the scoring method to polyStruct
        polyStruct.scoremethod = options.SCOREMETHOD;

        if strcmp(options.LOADFILE, '')

            % Initialise Matrix for storing best and average results and number of
            % funtion evaluations
            Best = NaN * ones(options.MAXGEN,3);
            Best(:,3) = zeros(size(Best,1),1);

            % Matrix for storing best individuals at each generation
            IndAll = [];

            if nargin < 6
                % Create population if initial population is not supplied
                if options.VERBOSE == 1
                    disp('Generating initial population')
                end
                if options.MCORE == false
                    Chrom = crtpolyp(options.SUBPOP * options.NIND, polyStruct);
                else
                    % Directory for storing temporary files
                    settings.multicoreDir      = options.MCOREDIR;
                    % Determines whether the master performs work or only coordinates
                    settings.masterIsWorker    = true;
                    % This is the number of function evaluations given to each worker
                    % in a batch
                    settings.nrOfEvalsAtOnce   = 5;
                    % The maximum time a single evaluation (in this case, one
                    % chromosome generation) should take, determines the timeout for a worker
                    settings.maxEvalTimeSingle = 1000;
                    % Determines whether a wait bar is displayed, 0 means no wait bar
                    settings.useWaitbar = 0;
                    % Post processing function info, we do not do any post-processing
                    settings.postProcessHandle   = '';
                    settings.postProcessUserData = {};

                    for k = 1:(options.SUBPOP * options.NIND)
                        parameterCell{1,k} = {1, polyStruct};
                    end

                    % Evaluate the polynomials by performing a least squares fit on each
                    % one to find the best possible coefficients
                    Chrom = cell2mat(startmulticoremaster2(str2func('crtpolyp'), parameterCell, settings)');
                end

                if options.VERBOSE == 1
                    disp('Initial population created, commencing evaluation of first generation')
                end

            end

            % Initialise generation count
            gen = 0;

        end

        % Get value of minimum, defined in objective function
        GlobalMin = objpolyfit([],3,polyStruct);

        % Get title of objective function, defined in objective function
        FigTitle = [objpolyfit([],2,polyStruct) '   (' int2str(options.SUBPOP) ':' int2str(options.MAXGEN) ') '];

        % Set termination flag to zero, when the termination criteria is
        % reached this will be set to one and the optimisation loop exited
        termopt = 0;

        % turn off the singular matrix warning temporarily
        warning off MATLAB:nearlySingularMatrix

        % Calculate objective function for the initial population
        if options.MCORE == false
            ObjV = objpolyfit(Chrom, [], polyStruct);
        else
            polyStruct.mcoredir = options.MCOREDIR;
            ObjV = objpolyfit_MCore(Chrom, [], polyStruct);
        end

        [Best(gen+1,1),ix] = min(ObjV);
        % count number of objective function evaluations
        Best(gen+1,3) = Best(gen+1,3) + options.NIND;

        if options.VERBOSE == 1
            disp('Initial population evaluated')
            disp(sprintf(['Best score:  ', num2str(Best(gen+1,1), 8), '  gen: ', int2str(gen+1)]))
        end

        % Iterate subpopulation till termination or options.MAXGEN
        while ((gen < options.MAXGEN) && (termopt == 0)),

            % Save the best objective value
            [Best(gen+1,1),ix] = min(ObjV);
            % Save the average objective value
            Best(gen+1,2) = mean(ObjV);
            % Save the best individual's variable values in this generation
            IndAll = [IndAll; Chrom(ix,:)];

            % Display the best individual's score in this generation if the
            % verbose option is chosen
            if options.VERBOSE == 1
                disp(sprintf(['Best score:  ', num2str(Best(gen+1,1), 8), '  gen: ', int2str(gen+1)]))
            end

            % Fitness assignment to whole population
            FitnV = ranking(ObjV,[2 0], options.SUBPOP);

            % Select individuals from population
            SelCh = select(options.SEL_F, Chrom, FitnV, options.GGAP, options.SUBPOP);

            % Recombine selected individuals
            SelCh = recombinpoly(SelCh, polyStruct, options.SUBPOP);

            % Mutate offspring
            SelCh=mutatepoly(SelCh, polyStruct, [options.MUTR gen], options.SUBPOP);

            % Calculate objective function for the offspring
            if options.MCORE == false
                ObjVOff = objpolyfit(SelCh, [], polyStruct);
            else
                ObjVOff = objpolyfit_MCore(SelCh, [], polyStruct);
            end

            % Add the number of function evaluations to the count
            Best(gen+1,3) = Best(gen+1,3) + size(SelCh,1);

            % Insert best offspring in population replacing worst parents
            [Chrom, ObjV] = reins(Chrom, SelCh, options.SUBPOP, [1 options.INSR], ObjV, ObjVOff);

            % Increment the number of generations
            gen = gen + 1;

            % Plot some results, rename title of figure for graphic output
            if options.GRAPHS == 1 && ((rem(gen,20) == 1) || (rem(gen,options.MAXGEN) == 0) || (termopt == 1))
                set(gcf,'Name', [FigTitle ' in ' int2str(gen)], 'Renderer', 'painters');
                % Selects the last 20 generations' best individuals scores and mean scores
                gapolyfitnresplot(ObjV,Best(max(1,gen-19):gen,[1 2]),gen);
            end

            % Check, if best objective value near GlobalMin is less than the
            % termination criterion. Compute difference between GlobalMin and
            % best objective value
            ActualMin = abs(min(ObjV) - GlobalMin);

            % if ActualMin smaller than TERMVAL --> terminate the procedure
            if ((ActualMin < (options.TERMVAL * abs(GlobalMin))) || (ActualMin < options.TERMVAL))
                termopt = 1;
            end

            % Migrate individuals between subpopulations
            if ((termopt ~= 1) && (rem(gen,options.MIGGEN) == 0))
                [Chrom, ObjV] = migrate(Chrom, options.SUBPOP, [options.MIGR, 1, 0], ObjV);
            end

            % Save the state of the GA if required
            if options.DOSAVE == 1
                save(options.SAVEFILE, 'Chrom', 'Best', 'IndAll', 'gen', 'options');
            end

        end

        % add number of objective function evaluations
        Results = cumsum(Best(1:gen,3));

        % number of function evaluation, best and mean results
        Results = [Results Best(1:gen,1) Best(1:gen,2)];

        % Fit the optimised polynomial form to determine the coefficients
        polymodel = polyVec2polyfit(indepvar, depvar, IndAll(end,:));

        % Strip NaNs from Best Matrix
        Best = Best(1:gen,:);

        % If the verbose option is selected display some data on the ga and
        % result
        if options.VERBOSE == 1

            % First plot the entire objective value progress over the course of
            % the optimisation
            if options.GRAPHS == 1
                gapolyfitnresplot(ObjV,Best,gen);
            end

            disp(sprintf(['\nTotal No. of Function Evaluations:  ', num2str(Results(gen,1)),'\n']))

            disp(sprintf(['Best score:  ', Best(gen,1),'\n\nMost Successful Individual:\n']))

            % reshape the polynomial to conform to polyfitn specifications
            polyVec = reshape(IndAll(end,:),polyStruct.vars+1,[])';

            % Find and remove all empty terms
            polyVec(polyVec(:,1)==0,:) = [];

            % remove coefficient/placeholder values, leaving only power terms
            polyVec(:,1) = [];

            % Display the terms in a list
            termtext = '';
            for k = 1:size(polyVec,1)
                for j = 1:size(polyVec,2)
                    if j < size(polyVec,2)
                        termtext = [termtext, 'x^', int2str(polyVec(k,j)), ' * '];
                    else
                        termtext = [termtext, 'x^', int2str(polyVec(k,j))];
                    end
                end
                disp(['Term ', num2str(k), ':   ', termtext])
                termtext = '';
            end

            disp(sprintf('\n'))

            disp(polymodel)

        end

        warning on MATLAB:nearlySingularMatrix

    end

end