%% MKDOTFILE
% MKDOTFILE produces a DOT file for use with GraphViz dotty or an equivalent
% layout and plotting engine.
%%
function txt = mkdotfile(Ifile,Ofile)
% MKDOTFILE produces a DOT file for use with GraphViz dotty or an equivalent
% layout and plotting engine.
%
%%  Input:
%  Ifile is the input file name (path)
%  Ofile is the output file name (path)
%
%%  Output:
%  txt is the text contents of file Ofile
%
%%  Limitations:
% Currently mkdotfile can only produce directed graphs
%
%%  Dependancies:
%   fdep (a pedestrian function dependencies finder)
%%
% <http://www.mathworks.com/matlabcentral/fileexchange/17291-fdep-a-pedestrian-function-dependencies-finder>
%
%==========================================================================
% Copyright Jonathan Lister 05/12/2010
% Usage and modification is granted to all so long as this block of text is
% included. (GPL)
%==========================================================================

% use fdep to determine all of the file's dependencies
p = fdep(Ifile,'-q');
n = p.nfun; %number of functions hit including Ifile's
if n > 1
    k = 0;
    for i=1:n;
        % access module data
        caller = p.module{i};           % name of caller
        calls = p.module(p.mix{i});		% calls	TO
        if ~isempty(calls)
            m = numel(calls);
            for j = 1:m
                % write entry in dot file
                k = k + 1;
                aline{k,1} = ['   ' caller ' -> ' calls{j} ';']; %#ok<AGROW>
            end
        end
    end
    
    % append the diagraph opening line, and set node shapes to boxes
    aline = [{'node [shape=box, color=blue]'}; aline];
    aline = [{'rankdir="LR"'};aline];
    aline = [{['digraph ' p.module{1} '_calls {']}; aline];
    
    % append closing curl
    aline = [aline; {'}'}];
    
    % convert to text
    txt = char(aline);
    
    % open a file object to write to
    fid = fopen(Ofile,'wt+');
    
    % write each line to the text file
    [r c] = size(txt);
    for i=1:r
        fprintf(fid,'%s\n',txt(i,:));
    end
    
    % finished writting to file, now close it
    fclose(fid);
    
end