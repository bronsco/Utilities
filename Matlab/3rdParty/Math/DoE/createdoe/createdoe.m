function doe_set = createdoe(popsize,bounds,intcon,type,plotflag)
%% createdoe.m 1.3
%
% this function is used to generate either a Latin hypercube or sobol 
% quasi-random set based on user supplied constraints and desired size
% for the purpose of sensitivity analyzes or GA population initialization
% NOTE: The Statistics Toolbox is required
%
%
% popsize: the number of points per dimension to generate. 
%
% bounds: variable of size [2,ndim] with the first row representing
% the lower bounds and the second row the upper bounds. The dimension of
% this variable is also used to determine the dimensionality of the
% space.
%
% intcon: vector containing the indices that have integer constraints
% for example bounds = [0 1 0 1]; indicates that only the 2nd and 4th
% design variable have integer constraints applied. If none are
% specified then no constraints are applied.
%
% type: a string indicating which type of distribution. Valid arguments
% are either 'sobol' or 'lhc'
%
% plotflag: 1 or zero (true / false) to indicate if a matrix plot is
% desired (1 == yes, 0 == no)
%
% doe_set: is the [ndim,popsize] result. Use scatter functions to visualize 
% as dimensionality permits
%
% By Ryan Chladny, Copyright 2014 The MathWorks Inc.
% Acknowledgements: Peter Maloney for general feedback and doc
%                   enhancements
%                   Erin McGarrity for custom matrix plot
%
% Change log: 1.0 basic functionality demonstrated
%             1.1 enhanced documentation and example included
%             1.2 custom plot matrix used to avoid Econcometrics Toolbox
%             dependency and correct bin assignment in hist call.
%             Re-ordring of inputs with vargin support
%             1.3 Added arg validation
%
%% Example usage:
% In this example, 4 design variables are defined implicitly via a matrix
% that expresses the upper and lower bounds (first and second row respectively)
%
% Any variables requiring integer constraints are set through a
% vector of flags with the indices corresponding to their respective
% variables. True indicates the variable is integer constrained.
% In the case below, only the third variable has integer constraints
% applied
%
% A call to this function, in this example will create a 200 x N variable
% sobol set within the bounds and constraints applied.
%
% myDOEbnds = [-1.75, 32.4, -1, -234.2; 3.95, 112.56, 9, 156.37];
% myDOEintcon = [0 0 1 0];
% myDOEset = createdoe(200,myDOEbnds,myDOEintcon,'sobol',true); 
% 

%% Begin code
   minInputs = 2;
   maxInputs = 5;
   narginchk(minInputs,maxInputs)
   if nargin == 2
       intcon = zeros(1,length(bounds));
       type = 'sobol';
       plotflag = true;
   elseif nargin ==3
       type = 'sobol';
       plotflag = true;
   elseif nargin == 4
       plotflag = true;
   end % if
   
   % Make sure all the arguments are the correct type/size
   validateattributes(popsize, {'numeric'}, {'positive', 'scalar', 'integer'}, 1);
   validateattributes(bounds, {'numeric'}, {'size', [2, NaN]}, 2);   
   [~, doe_dim] = size(bounds);
   validateattributes(intcon, {'numeric', 'logical'}, {'nonnegative','vector', 'numel', doe_dim}, 3);
   validateattributes(type, {'char'}, {'nonempty'});
   validateattributes(plotflag, {'numeric', 'logical'}, {'nonempty'});
   
   switch type
       case 'sobol'
           % create the sobol object
           sobol_obj = sobolset(doe_dim);
           % create a set based on the specified size
           normed_set = net(sobol_obj,popsize);
           
       case 'lhc'
           % returns an n-by-p matrix, X, containing a latin hypercube sample
           % of popsize on each of p variables over a range from 1/popsize
           % to 1-1/popsize
           normed_set = lhsdesign(popsize,mean(doe_dim),'criterion','maximin');
           
       otherwise
           error('DOE type specified not found. Valid types are: ''sobol'' or ''lhc''')
           doe_set = [];
           return
   end
   
   doe_set = zeros(popsize,doe_dim);
   % rescale the set according to the ranges specified
   for i = 1:doe_dim
       %doe_set(:,i) = normed_set(:,i).*(bounds(2,i)-bounds(1,i)) + bounds(1,i);
       upper = bounds(2,i);
       lower = bounds(1,i);
       if intcon(i) == 1
           upper = upper + 1;
       end
       doe_set(:,i) = normed_set(:,i).*(upper-lower) + lower;
   end
   % apply integer constaints as required
   %doe_set(:, boolean(intcon)) = round(doe_set(:,boolean(intcon)));
   doe_set(:, boolean(intcon)) = floor(doe_set(:,boolean(intcon)));
   
   if (plotflag == 1) || strcmp(plotflag,'true')
      onzeCoorsPlot(doe_set, bounds, intcon);
   end   
%    % plot the correlation matrix (requires the Econometrics Toolbox)
%    % note that hist binning is not correct if intconstraints are applied
%    if exist('corrplot.m','file')==2
%        corrplot(doe_set,'type','Kendall','testR','on')
%    end
end

function onzeCoorsPlot(doe_set, bounds, intcon)

  figure
  [H,AX,BigAx,P,PAx] = plotmatrix(doe_set);
  
  % How many vars?
  nvars = length(intcon);
  
  % Scale factor for widening plots
  dw = 0.1*diff(bounds);
  
  % Compute correlation coeffs
  c = corrcoef(doe_set);
  
  % Fix Integer Histograms
  for k = 1:nvars
     
    if intcon(k) == 1 
      hold(AX(k,k), 'on')
      hist(PAx(k), doe_set(:,k), bounds(1,k):bounds(2,k));

      set(PAx(k), 'XTickLabel', [], 'YTickLabel', []);
      
    end
      % Histogram boundary color
      hh = get(PAx(k), 'Children');
      set(hh, 'EdgeColor', [ 0 1 1]);
     
      % Set the width
      xlim(PAx(k), [bounds(1,k)-dw(k) bounds(2,k)+dw(k)])
  end
  
  % Rescale each axis
  for k = 1:nvars
    for m = 1:nvars
      axis(AX(m, k), [bounds(1,k)-dw(k) bounds(2,k)+dw(k) ...
                          bounds(1,m)-dw(m) bounds(2,m)+dw(m)]);
 
      %text(AX(m,k), bounds(1,k)+dw, bounds(2,m)-dw, ['C: ' num2str(c(m,k))]);  
      ctextpos = get(AX(m,k),'Position');
      annotation('textbox', ctextpos, 'String', num2str(c(m,k), '%3.2f'),...
                       'FontWeight', 'Bold', 'Color', 'r')
    end
  end
end


