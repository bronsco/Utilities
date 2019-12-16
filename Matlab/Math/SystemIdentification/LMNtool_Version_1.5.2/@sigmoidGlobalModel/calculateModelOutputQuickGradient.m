function grad = calculateModelOutputQuickGradient(obj, ...
    input, output, xRegressor, localParameter, validity, psi)
%% CALCULATEMODELOUTPUTQUICKGRADIENT Calculates the gradient of the model
% given an input sequence. This function is called by
% calculateModelOutputQuick.
%
%
%       grad = calculateModelOutputQuickGradient(obj, ...
%               input, output, xRegressor, localParameter, validity, psi)
%
%   calculateModelOutputQuick output:
%       grad        - (1 x p) Gradient of the model output
%
%
%   calculateModelOutputQuick inputs:
%       obj         - (obj)   LMN class-object.
%       input       - (1 x p) Data matrix containing physical inputs
%       output      - (1 x q) (optional) Data matrix containing physical
%                             outputs. These are only needed for dynamic
%                             systems.
%
%
%   LMNtool - Local Model Network Toolbox
%   Tobias Ebert, 25-June-2013
%   Institute of Mechanics & Automatic Control, University of Siegen, Germany
%   Copyright (c) 2013 by Prof. Dr.-Ing. Oliver Nelles

% to debug gradient:
% numerical_gradient(obj, input, output, 1e-4)

if obj.useCenteredLocalModels == false
    % calculate the derivative of the xRegressor
    xRegDerivative = obj.data2xRegressorDerivative(input,output);
end

% get index of active local models
idxLeafs = find(obj.leafModels);
nLeafs = length(obj.leafModels);

% calculate kappa * v_i / vnorm of every local model (v_n x M local Models)
vi = [obj.localModels(1:nLeafs).splittingParameter];
vi = vi(1:end-1,:);
kvnorm = bsxfun(@times, [obj.localModels(1:nLeafs).kappa]/obj.smoothness, vi); % norm(v)=1 !

%disp('derivation(kappa * (1/norm) * (v0 + Z*vj)) [analytical]'); disp(' '); disp(kvnorm); disp(' ')

% get connections between parents and children, from root to leaf
branch = {obj.localModels(1:nLeafs).parent};
for familyIdx = 1:length(branch)
    branch{familyIdx} = [ branch{branch{familyIdx}}, familyIdx]; % [parents, child]
end

% derivation of local validitys (psi) for every physical input
dPdu = zeros(size(obj.zRegressor,2), length(obj.leafModels));
dPdu(:,2:end) = bsxfun(@times, (psi(2:end)-1) .* psi(2:end), kvnorm);

%disp('derivation(P_j_k) [analytical]'); disp(' '); disp(dPdu); disp(' ');

numberOfVI = size(kvnorm,1);
numberOfOutputs = obj.info.numberOfOutputs;

% calculate the gradient of each local model
if numberOfOutputs == 1
    
    %% derivation of the local models
    if obj.useCenteredLocalModels == true
        numberOfLocalModels = sum(obj.leafModels);
        gradYhat = zeros(numberOfLocalModels, size(input,2));
        for g = 1:numberOfLocalModels
            xRegDerivative = obj.data2xRegressorDerivative(input,output,idxLeafs(g));
            % matrix of as many rows as LM and columns as physical inputs
            gradYhat(g,:) = (cat(1,xRegDerivative{:}) * localParameter(2:end,g))';
        end
        
    else
        % matrix of as many rows as LM and columns as physical inputs
        gradYhat = (cat(1,xRegDerivative{:}) * localParameter(2:end,:))';
        %disp('Derivation of yhat_k'); disp(' '); disp(gradYhat); disp(' ')
    end
    % multiplay with the validity of each model
    gradYhat = bsxfun(@times, gradYhat, validity(obj.leafModels)');
    % sum of all local models
    gradYhat = sum(gradYhat,1);
    
    %disp('Sum of validity_k * derivation(yhat_k) [analytical]'); disp(' '); disp(gradYhat); disp(' ');
    
    
    %% derivation of the validity
    
    dQk_dui = zeros(length(idxLeafs), numberOfVI);
    for k = idxLeafs % loop over all active local models
        for kk = 1:numberOfVI
            % build a matrix with the validitys of all knots (M x M x nVi)
            knotPsi = ones(length(branch{k}), 1) * psi(branch{k});
            % replace diagonal with the derivatives
            knotPsi(find(eye(length(branch{k})))) = dPdu(kk,branch{k});
            % calculate the validities derivative of a local model k for input kk
            dQk_dui(k==idxLeafs,kk) = sum(prod(knotPsi,2),1);
        end
    end
    % disp('derivation(Q_k) [analytical]'); disp(' '); disp(dQk_dui); disp(' ');
    
    % unweighted output of every local model
    yhatk = xRegressor * localParameter;
    %disp('yhat_k [analytical]'); disp(' '); disp(yhatk); disp(' ');
    
    gradValidity = bsxfun(@times, dQk_dui, yhatk');
    %disp('derivation(Q_k) * yhat_k [analytical]'); disp(' '); disp(gradValidity); disp(' ');
    
    gradValidity = sum(gradValidity,1);
    
else % numberOfOutputs > 1
    
    % derivation of the local models
    gradYhat = cell(1, sum(obj.leafModels));
    for G = 1:sum(obj.leafModels)
        if obj.useCenteredLocalModels == true
            xRegDerivative = obj.data2xRegressorDerivative(input,output,idxLeafs(g));
        end
        % as many cells as LM
        gradYhat{g} = cell2mat(cellfun(@(dXdu) dXdu*localParameter{g}(2:end,:), xRegDerivative, 'UniformOutput',false));
        
    end
    % multiplay with the validity of each model
    gradYhat = cellfun(@(grad, val) bsxfun(@times, grad, val), gradYhat, ...
        mat2cell(validity, size(validity,1), ones(1,size(validity,2))), ...
        'UniformOutput',false);
    % sum of all local models
    gradYhat = sum(cat(3,gradYhat{:}),3);
end

grad = gradYhat + gradValidity;
%disp('derivation(yhat) [analytical]'); disp(' '); disp(grad); disp(' ');

end

function numerical_gradient(obj, input, output, alpha)
% numerical gradient for debugging

%% full gradient
% get the partition parameters from the local models
splittingPara = [obj.localModels(2:end).splittingParameter];
kappa = [obj.localModels(2:end).kappa];
smoothness = obj.smoothness;
parent = [0 obj.localModels(2:end).parent];

% get the local model parameters of the polynomials
localParameter = [obj.localModels(obj.leafModels).parameter];

xRegressor2 = obj.data2xRegressor(input + alpha, []);
xRegressor1 = obj.data2xRegressor(input - alpha, []);
xRegressorc = obj.data2xRegressor(input, []);

zRegressor2 = obj.data2zRegressor(input + alpha, []);
zRegressor1 = obj.data2zRegressor(input - alpha, []);
zRegressorc = obj.data2zRegressor(input, []);

[psi2, validity2] = calc_psi(zRegressor2);
[psi1, validity1] = calc_psi(zRegressor1);
[psic, validityc] = calc_psi(zRegressorc);

yhat2 = calc_yhat(xRegressor2, validity2);
yhat1 = calc_yhat(xRegressor1, validity1);
yhatc = calc_yhat(xRegressorc, validityc);

yhatk2 = calc_yhatk(xRegressor2, validity2);
yhatk1 = calc_yhatk(xRegressor1, validity1);
yhatkc = calc_yhatk(xRegressorc, validityc);

debug_grad = (yhat2-yhat1) / (2*alpha);
disp('derivation(yhat) [numerical]'); disp(' '); disp(debug_grad); disp(' ');
% (obj.calculateModelOutput(input+alpha) - obj.calculateModelOutput(input-alpha)) / (2*alpha)

%% validity * derivation(yhat)
nLM = sum(obj.leafModels); % anzahl der LM
idxLM = find(obj.leafModels); % index der LM
for k = 1:nLM
    dyhatk(k) = (yhatk2(k)-yhatk1(k)) / (2*alpha);
end
% disp('Derivation of yhat_k'); disp(' '); disp(dyhatk); disp(' ');

debug_gradYhat = validityc(idxLM) .* dyhatk;
%disp('validity_k * Derivation(yhat_k)'); disp(' '); disp(debug_gradYhat); disp(' ');

debug_gradYhat = sum(debug_gradYhat);
%disp('Sum of validity_k * derivation(yhat_k) [numerical]'); disp(' '); disp(debug_gradYhat); disp(' ');

%% derivation(validity_k) * yhat_k

dQ_k = (validity2(idxLM) - validity1(idxLM)) ./ (2*alpha);
% disp('derivation(Q_k) [numerical]'); disp(' '); disp(dQ_k'); disp(' ');

disp('yhat_k [numerical]'); disp(' '); disp(yhatkc); disp(' ');

dQ_k_yhatk = dQ_k .* yhatkc;
disp('derivation(Q_k) * yhatk [numerical]'); disp(' '); disp(dQ_k_yhatk'); disp(' ');

dP_j = (psi2-psi1)  ./ (2*alpha);
%disp('derivation(P_j_k) [numerical]'); disp(' '); disp(dP_j); disp(' ');

for k = idxLM
teildpsi2 = calc_partial_psi(obj, zRegressor2, k);
teildpsi1 = calc_partial_psi(obj, zRegressor1, k);
inner_dP(k) = (teildpsi2-teildpsi1)/(2*alpha);
end

%disp('derivation(kappa * (1/norm) * (v0 + Z*vj)) [numerical]'); disp(' '); disp(inner_dP); disp(' ')

dP = (psic-1) .* psic .* inner_dP;
%disp('derivation(P_j_k) [numerical]'); disp(' '); disp(dP); disp(' ');


%% subfunctions
    function [psi, validity] = calc_psi(zRegressor)
        if isempty(splittingPara) && numel(parent) == 1 % no parents; only one local model is given
            psi = ones(size(zRegressor,1),1);
        else
            % calculate validity per sigmoidal
            psi = [1 1./(1+exp((kappa./smoothness) .* (zRegressor*splittingPara(1:end-1,:) + splittingPara(end,:))))];
            validity = psi;
            for childIdx = 4:2:length(validity)
                validity(childIdx:childIdx+1) = validity(childIdx:childIdx+1) .* validity(parent(childIdx));
            end
        end
    end

    function yhat = calc_yhat(xRegressor, validity)
        yhat = sum(validity(obj.leafModels).*(xRegressor * localParameter),2);
    end

    function yhatk = calc_yhatk(xRegressor, validity)
        yhatk = (xRegressor * localParameter);
        % attention: yhat_k is without validities!
    end





end

function partial_dpsi = calc_partial_psi(obj, zRegressor, idxLM)

partial_dpsi = ...
    obj.localModels(idxLM).kappa ...
    ./obj.smoothness .* ...
    (1./norm(obj.localModels(idxLM).splittingParameter)) .* ...
    (obj.localModels(idxLM).splittingParameter(end) + ...
    zRegressor .*  obj.localModels(idxLM).splittingParameter(1:end-1));

end




