function gapolyfitnresplot(ObjV,Best,gen)
% gapolyfitnresplot: This function plots some results of the gapolyfitn
% algorithm during or after computation
%
% Syntax:  gapolyfitnresplot(ObjV,Best,gen)
%
% Input:
%
%    ObjV      - Vector containing objective values of the current
%                generation
%    Best      - Matrix containing the best and average Objective values of 
%                each generation, [best value per generation,average value 
%                per generation]
%    gen       - Scalar containing the number of the current generation
%
% Output:
%    no output parameter
%
% Author:   Richard Crozier
% Release Date: 06 OCT 2009
%

   % plot of best value of passed in generations
      subplot(2,2,1), plot(1:size(Best,1), Best(:,1)', '-r');
      set(gca, 'xlim', [0 (size(Best,1) + 1)])
      title(sprintf(['Best Objective Values\n(last ', num2str(size(Best,1)), ' Generations)']));
      xlabel('Generation'), ylabel('Best Objective Values');
      
   % plot of mean value of passed in generations
      subplot(2,2,2), plot(1:size(Best,1), Best(:,2)',  '--b');
      set(gca, 'xlim', [0 (size(Best,1) + 1)])
      title(sprintf(['Mean Objective Values\n(last ', num2str(size(Best,1)), ' Generations)']));
      xlabel('Generation'), ylabel('Mean Objective Values');
    
   % plot of all objective values in current generation
      subplot(2,2,3:4), plot(ObjV,'*b');
      set(gca, 'xlim', [0 (length(ObjV) + 1)])
      title(['All Objective Values Gen: ',num2str(gen)]);
      xlabel('Current Generation'), ylabel('Objective Values');

      drawnow;

end