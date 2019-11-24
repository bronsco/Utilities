function [globalLossFunctionValue, localModels, leafModels, phi, outputModel, successfulOpt, phiSimulated] = LMSplitOpt(obj, localModelsIni,weightedOutputWorstLM)
%% LMSPLITOPT Axes-oblique splitting of worst LM into two partitions using nonlinear optimization.
%
%       [obj] = LMSplitOpt(obj, wIni, worstLM)
%
%
%   LMSPLITOPT inputs:
%
%       obj     - (object) HILOMOT object containing all relevant properties and methods.
%       wIni    - (vector) Vector of the best initial split.
%       worstLM - (1 x 1) Index of LM with the largest local loss function value.
%
%
%   LMSPLITOPT ouputs:
%
%       obj     - (object) HILOMOT object after oblique splitting.
%
%
%   See also estimateFirstLM, LMSplit.
%
%
%   HiLoMoT - Nonlinear System Identification Toolbox
%   Benjamin Hartmann, 10-January-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

%% catch errors
if ~(strcmp(obj.estimationProcedure,'LS') || strcmp(obj.estimationProcedure,'RIDGE') )
    warning('hilomot:LMSplitOpt','Split optimization is only fully supported with LS as estimation procedure!')
end

%% Initialization
% Set flags
successfulOpt1st = true;
successfulOpt2nd = true;


% Options for nonlinear optimization
myOptions = optimset;
myOptions = optimset(myOptions,'Display','off');
% myOptions = optimset(...
%     'Display',            'off',...    % 'iter', 'final', 'off'
%     'Diagnostics',        'off',...
%     'MaxFunEvals',        1e3,...
%     'MaxIter',            1e3,...
%     'HessUpdate',         'bfgs',...   % 'bgfs', 'dfp', ('steepdesc')
%     'TolFun',             1e-10,...
%     'TolX',               1e-10,...
%     'FinDiffType',        'forward',...
%     'DiffMinChange',      1e-10,...
%     'LargeScale',         'off');


% Algorithm used for nonlinear constrainted optimizatio
myOptions = optimset(myOptions,'algorithm','sqp');
% <interior-point> is the default setting in the toolbox;
% other possible approaches are <active-set> or <sqp>, see doc fmincon

if obj.GradObj
    % Use the gradient to speed up optimizedtion
    myOptions.GradObj = 'on';
    myOptions.GradConstr = 'on';
    % myOptions.DerivativeCheck = 'on';
end

% Switch of warnings
% warning off optim:fminunc:SwitchingMethod
warning off MATLAB:rankDeficientMatrix

% w0 is kept constant; w1, ..., wnz are going to be optimized
w = localModelsIni(1).splittingParameter;
wRedIni = w(1:end-1);
w0 = w(end);

% get the worst local model
worstLM = localModelsIni(1).parent;

% initialize kappa
if isempty(obj.demandedMembershipValue)
    % no demanded membership value given, calculate transition by the center coordinates
    kappaIni = [];
    % Analytical gradient not possible, use numerical approach
    myOptions.GradObj = 'off';
    myOptions.GradConstr = 'off';
elseif ~isempty(obj.demandedMembershipValue)
    % if the demanded membership value is given, calculate an initial kappa for the optimization
    [~, kappaIni, ~, ~] = obj.calculatePhi(localModelsIni, [],false);
end

%% Perform Optimization

% Nonlinear split direction optimization using numerical approximation of gradient.
% (If optimization with numerical gradient is aborted, parameters are set to initial values.)
try
    % default constraint optimization guarantees enough points for the local estimation
    [wRedOpt, globalLossFunctionValue1st] = fmincon(@(wRed) obj.obliqueGlobalLossFunction(wRed, w0, weightedOutputWorstLM, kappaIni, worstLM),...
        wRedIni,[],[],[],[],[],[],@(wRed) obj.nonlinearConstrains(wRed, w0, kappaIni, worstLM),myOptions);
    
    % fixing the split to the center of the worst local model
    % wRedOpt = fmincon(@(wRed) obj.obliqueGlobalLossFunction(wRed, w0, weightedOutputWorstLM, kappaIni, worstLM),...
    %     wRedIni,[],[],obj.localModels(worstLM).center,-w0,[],[],(@(wRed) nonlinearConstrains(wRed, w0, kappaIni, worstLM) ),myOptions);
    
catch
    successfulOpt1st = false; % First optimization attempt is aborted.
    warning('hilomot:LMSplitOpt','Optimization aborted. Parameters are set to initial values!')
    wRedOpt = wRedIni;
    globalLossFunctionValue1st = obliqueGlobalLossFunction(obj, wRedOpt, w0, weightedOutputWorstLM,kappaIni,worstLM);
end

% plot the lossfunction of the optimization for debuggin
% plotOptimizationLossfunction(wRedIni, wRedOpt, w0, weightedOutputWorstLM, kappaIni, obj, worstLM)

% Re-adjust the kappa value after the root is divided, because in that
% special case no earlier split direction is tested as initialization for
% the optimization. This might effect the steepness of the transition area
% a lot, because the kappa value is adjusted with respect to the initial
% split direction (see above).
if ~isempty(obj.demandedMembershipValue) && obj.reoptimizeNewKappa
    
    % Save wRedOpt from former optimization
    wRedOptFirst = wRedOpt;
    
    % Calculate loss function and model updates with optimal sigmoid parameters
    % Furthermore the kappa value of the sigmoids is adjusted. This is done
    % every time the obliqueGlobalLossFunction is called with an empty
    % parameter for the kappa value.
    [~, kappaIni, ~, ~] = obj.calculatePhi(localModelsIni);
    
    try
        % default constraint optimization guarantees enough points for the local estimation
        [wRedOpt, globalLossFunctionValue2nd] = fmincon(@(wRed) obj.obliqueGlobalLossFunction(wRed, w0, weightedOutputWorstLM, kappaIni, worstLM),...
            wRedOptFirst,[],[],[],[],[],[],@(wRed) obj.nonlinearConstrains(wRed, w0, kappaIni, worstLM),myOptions);
        
        % fixing the split to the center of the worst local model
        % wRedOpt = fmincon(@(wRed) obj.obliqueGlobalLossFunction(wRed, w0, weightedOutputWorstLM, kappaIni data, worstLM),...
        %   wRedOptFirst,[],[],obj.localModels(worstLM).center,-w0,[],[],(@(wRed) nonlinearConstrains(wRed, w0, kappaIni, worstLM) ),myOptions);
        
        % Check if 2nd optimization found a worse split, then reset to old
        % values for th esplit
        if globalLossFunctionValue2nd > globalLossFunctionValue1st
            wRedOpt = wRedOptFirst;
        end
        
    catch
        successfulOpt2nd = false; % Second optimization attempt is aborted.
        warning('hilomot:LMSplitOpt','Reoptimization aborted. Parameters are set to initial values!')
        wRedOpt = wRedOptFirst;
    end
    
end

% Check if one of the Optimization attempts is valid
if successfulOpt1st || successfulOpt2nd
    % Estimation of the local parameters, the calculation of the LM center, the
    % validities and the new output after the split-direction is evaluated.
    [globalLossFunctionValue, ~, localModels, leafModels, phi, outputModel, forbiddenSplit, phiSimulated] = obliqueGlobalLossFunction(obj, wRedOpt, w0, weightedOutputWorstLM,kappaIni,worstLM);
    % plotOptimizationLossfunction(wRedIni, wRedOpt, w0, weightedOutputWorstLM, kappaIni, obj, worstLM)
    %%% The variable forbiddenSplit is
    %%% true:  if an allowed split was found by the optimization
    %%% false: if no allowed split was found by the optimization
    successfulOpt = ~forbiddenSplit;
else
    % Store that the optimization was not successful
    successfulOpt = false;
    % No calculation needed: Given orthognal initial spltit is used.
    globalLossFunctionValue = [];
    localModels = [];
    leafModels = [];
    phi = [];
    outputModel = [];
    phiSimulated = [];
end
end
%% plot of the lossfunction for debuggin and graphs
function plotOptimizationLossfunction(wRed, wRedOpt, w0, weightedOutputWorstLM, kappa, obj, worstLM)
%keyboard
JwRed = obj.obliqueGlobalLossFunction(wRed, w0, weightedOutputWorstLM, kappa, worstLM);
JwRedOpt = obj.obliqueGlobalLossFunction(wRedOpt, w0, weightedOutputWorstLM, kappa, worstLM);

if length(wRedOpt)==1
    n = 500;
    pm = 2.6;
    wPlot = linspace(min([wRedOpt(1), wRed(1)])-pm, max([wRedOpt(1), wRed(1)])+pm, n);
    
    %wPlot = 0.7145;%665;%64;%0.4525;%5; %0.6388;%wRedOpt;
    
elseif length(wRedOpt)==2
    n = 50;
    pm = 0.6;
    [w1G,w2G] = meshgrid(...
        linspace(min([wRedOpt(1), wRed(1)])-pm, max([wRedOpt(1), wRed(1)])+pm, n), ...
        linspace(min([wRedOpt(2), wRed(2)])-pm, max([wRedOpt(2), wRed(2)])+pm, n));
    wPlot = [w1G(:)'; w2G(:)'];
    
    %wPlot = [0.2; 0.2];
end

for k = 1:size(wPlot,2)
    [J(k), grad(k,:)] = obj.obliqueGlobalLossFunction(wPlot(:,k), w0, weightedOutputWorstLM, kappa, worstLM);
end

%disp(['Number of Function Calls: ' num2str(size(wI,2))])

% calculate and plot numerical gradient
% tic
% gradk = calcNumGradient(wPlot,J, w0,worstLM,weightedOutputWorstLM,kappa,data,obj);
% gradCentral = calcNumGradientCentral(wPlot,J, w0,worstLM,weightedOutputWorstLM,kappa,data,obj);
% toc

if length(wRedOpt)==1
    
    figure
    % Plot lossfunction
    subplot(2,1,1)
    plot(wRed, JwRed, 'r+')
    hold all
    plot(wRedOpt, JwRedOpt, 'o')
    plot(wPlot, J,'-');
    
    % plot gradient
    subplot(2,1,2)
    hgrad = plot(wPlot, grad, '-');
    hold all
    hgrad(2) = plot(wPlot(1:end-1)+diff(wPlot), diff(J)./ diff(wPlot), '-');
    legend(hgrad,'analytisch','diff')
    
    grid on
    
elseif length(wRedOpt)==2
    % Plot lossfunction
    figure
    plot3(wRedOpt(1), wRedOpt(2),JwRedOpt, 'o')
    hold all
    plot3(wRed(1), wRed(2),JwRed, '+r')
    %hsurf = contour3(w1G, w2G, reshape(J,n,n),100);
    hsurf = surf(w1G, w2G, reshape(J,n,n));
    set(hsurf,'FaceAlpha',0.5)
    %plot3(wI(1,:), wI(2,:),JI, '-or')
    
    % plot of contout and the gradient
    figure
    contour(w1G, w2G, reshape(J,n,n))
    hold all
    plot(wRedOpt(1), wRedOpt(2),'o')
    hold all
    plot(wRed(1), wRed(2),'+r')
    quiver(w1G, w2G, reshape(grad(:,1),n,n), reshape(grad(:,2),n,n),1);
    title('Analytisch')
    
end

end







