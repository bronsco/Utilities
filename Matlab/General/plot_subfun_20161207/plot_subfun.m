function varargout = plot_subfun(foo,varargin)
%plot_subfun(foo)
%plots a dependency tree of the subroutines within a function file
%
%EXAMPLES
%plot_subfun(foo,'-hide','a','b','c')
%hides subroutines 'a','b','c'
%also hides their "kids" (any functions that are only called by a,b,c)
%
%plot_subfun(foo,'-kids','a','b',c')
%as above, but only hides the kids, not the functions themselves
%
%the flags '-hide' and '-kids' affect the names that follow
%the default is '-hide', so:
%plot_subfun('a','b','c','-kids','d','e','f','-hide','g','h')
%will apply 'hide' to a,b,c,g,h and 'kids' to d,e,f
%
%it is possible to specify the names of functions that are not present
%these will simply be ignored
%
%ALL HIDE OPTIONS
%-unused        show unused functions too
%-unusedonly    show only unused functions
%-hide          hide these functions and their kids
%-kids          hide the kids of these functions
%-nest          hide nested functions   (those within another function)
%-ends          hide end functions      (have one parent and no kids)
%
%these options are applied in the order shown above. functions that
%have been hidden by a previous option are treated as not existing for the
%purpose of subsequent options.
%
%OTHER OPTIONS
%-filename      adds file> to start of each function name
%-trim          trim hidden functions from output
%-list          show list of subroutines in command window
%-extlist       show list of external functions called
%-extshow       external function calls included on figure
%-extsub        ditto, but also shows subroutines of external functions
%-ext           ditto
%-noplot        do not plot the figure
%-nodesc        no description to filenames (e.g. foo (script))
%
%The author wishes to acknowledge the following file exchange submissions:
%farg, ftoc, fdep, mGraphViz, mkdotfile

data = sub_setup(foo,varargin{:});  %parse input and find dependencies
data = sub_add_filebox(data,foo);       %adds the file itself as a node
data = sub_hide(data);              %hide functions
data = sub_extsub(data);            %if extsub, recursively add subroutines of external functions too
data = sub_remove_desc(data);       %remove descriptions e.g. (script)
data.fig = sub_show_plot(data);     %plot the figure
sub_show_list(data);                %show a list of functions
if nargout;                         %return output only if requested
    data = sub_trim(data);          %trim out hidden functions
    varargout{1} = data;
end
end

%% SETUP
function data = sub_setup(foo,varargin)
sub_check_options(varargin{:})
data = sub_parse_options(varargin{:});  %parse options
data.varargin = varargin;
data = sub_parse_file(data,foo);        %parse function structure
data = sub_extl_calls(data);            %remove external calls
data = sub_deps(data);                  %find dependencies from remaining calls
data = sub_find_used(data);             %find functions that are actually used
data = sub_unique_names(data);
data.fun.used(1) = true;                %add function itself to used

    function sub_check_options(varargin)
        %check input options
        
        %check all options are strings or cellstring arrays
        if ~all(cellfun(@ischar,varargin) | cellfun(@iscellstr,varargin))
            error('all inputs must be strings or cellstring arrays');
        end
        
        %any starting with - must be a known keyword
        str = varargin(~cellfun('isempty',regexp(varargin,'^-.*')));
        targ = {...
            '-unused','-unusedonly','-hide','-kids','-nest','-ends',...
            '-extsub','-trim','-list','-ext','-noplot','-unhide',...
            '-extlist','-extshow','-filename','-nomain','-nodesc'};
        tf = ismember(str,targ);
        if ~all(tf);
            disp(str(~tf));
            warning('the above are not recognised options, they will be ignored');
        end
        
    end

    function data = sub_parse_options(varargin)
        
        %parse options
        data.out.extlist= false;    %show external functions as list
        data.out.extshow= false;    %show external functions on figure
        data.opt.filelink = true;  %show links to main function as links to file
        data.out.showmain = true;  %show the main function of each file
        data.out.filename = false;  %show filename as part of functionname
        data.out.desc     = true;   %add description e.g. (classdef) to names
        data.out.extsub = false;    %look for subroutines within external calls
        data.out.list   = false;    %display list
        data.out.plot   = true;     %display figure
        data.out.trim   = false;    %trim hidden functions from output
        data.hide.nest  = false;    %hide nested functions
        data.hide.ends  = false;    %hide deadend functions
        data.hide.orph  = true;     %hide orphan functions
        data.hide.used  = false;
        data.hide.funs  = {};       %functions to hide with kids
        data.hide.kids  = {};       %functions to hide kids only
        data.out.unhide  = false;    %show functions that have been hidden
        addto = 'funs'; %file names should be added to ignore or nokid
        for i=1:numel(varargin)
            val = varargin{i};
            switch val
                case '-hide';       addto = 'funs';
                case '-kids';       addto = 'kids';
                case '-ext' ;       data.out.extshow= true;
                case '-extshow';    data.out.extshow= true;
                case '-extlist';    data.out.extlist= true;
                case '-extsub';     data.out.extsub = true;
                                    data.out.extshow = true;
                case '-filename';   data.out.filename = true;
                case '-nomain';     data.out.showmain = false;
                case '-list';       data.out.list   = true;
                case '-noplot';     data.out.plot   = false;
                case '-trim';       data.out.trim   = true;
                case '-nest';       data.hide.nest  = true;
                case '-ends';       data.hide.ends  = true;
                case '-unused';     data.hide.orph  = false;
                case '-unhide';     data.out.unhide = true;
                case '-unusedonly'; data.hide.orph = false;
                                    data.hide.used = true;
                case '-nodesc';     data.out.desc  = false;
                    
                otherwise
                    data.hide.(addto) = [data.hide.(addto) val];
            end
        end
        
        %hide automatically includes kids
        data.hide.funs = unique(data.hide.funs);
        data.hide.kids = unique([data.hide.kids data.hide.funs]);
    end

    function data = sub_parse_file(data,foo)
        %process the file
        data.foo = which(foo);
        %20150302 catch built-in function
        if regexp(data.foo,'^built-in')
            data.foo = regexprep(data.foo,'^built-in\s+\(','');
            data.foo = regexprep(data.foo,'\)$','');
            if isempty(regexp(data.foo,'\.m$','once')); data.foo = [data.foo '.m']; end
        end
        
        if ~exist(data.foo,'file')
            warning(...
                'plot_subfun:noFile',...
                'File "%s" does not exist',...
                foo);
            data.fun.name = {};
            data.fun.beg = [];
            data.fun.end = [];
            data.fun.gen = [];
            data.fun.kind = '';
            data.call.name = {};
            data.call.line = [];
            data.fun.numof = 0;
            data.fun.show = [];
            data.fun.deps = [];
            data.fun.used = [];
            data.fun.hide = [];
            return
        end
        p=mlintmex(data.foo,'-m3','-calls');
        b = regexp(p,'(?<kind>(M|S|N))(?<gen>\d) (?<line>\d+) \d+ (?<name>\w+)','names');
        %end of functions
        e = regexp(p,'E. (?<line>\d+) \d+ (?<name>\w+)','names');
        %all calls in functions
        c = regexp(p,'U. (?<line>\d+) \d+ (?<name>\w+)','names');
        
        %2015.01.30 create an empty set of functions as a placeholder
        %this should cope with scripts that contain no subroutines
        data.fun.name = {};
        data.fun.beg = [];
        data.fun.end = [];
        data.fun.gen = [];
        data.fun.kind = '';
        data.call.name = {};
        data.call.line = [];
        
        for i=1:numel(b)
            data.fun.name{i} = b(i).name;
            data.fun.beg(i) = str2double(b(i).line);
            data.fun.end(i) = str2double(e(i).line);
            data.fun.gen(i) = str2double(b(i).gen);
            data.fun.kind(i) = b(i).kind;
        end
        for i=1:numel(c)
            data.call.name{i} = c(i).name;
            data.call.line(i) = str2double(c(i).line);
        end
        
        %catch empty cases
        if numel(b);
            data.fun.numof = numel(data.fun.name);
            data.fun.show = true(1,data.fun.numof);
            data.fun.deps = false(data.fun.numof,data.fun.numof);
            data.fun.used = true(1,data.fun.numof);
            data.fun.hide = false(1,data.fun.numof);
        else
            data.fun.numof = 0;
            data.fun.show = [];
            data.fun.deps = [];
            data.fun.used = [];
            data.fun.hide = [];
        end
        
        if ~numel(c);
            data.call.name = {};
            data.call.line = [];
        end
        
        
    end

    function data = sub_extl_calls(data)
        %data = sub_extl_calls(data);
        
        %% handle external calls
        
        %which calls are to external functions
        data.call.isext = ~ismember(data.call.name,data.fun.name);
        
        %make list of external calls
        names = unique(data.call.name(data.call.isext));
        %remove calls to built-in functions
        a = cellfun(@which,names,'UniformOutput',false);
        a = regexp(strrep(a,'\','/'),strrep(matlabroot,'\','/'),'match','once');
        keep = cellfun(@isempty,a);
        data.external = names(keep);
        
        %If external functions not shown on the figure, ignore these calls
        if ~data.out.extshow
            %remove from list of calls
            data.call.name  = data.call.name( ~data.call.isext);
            data.call.line  = data.call.line( ~data.call.isext);
            data.call.isext = data.call.isext(~data.call.isext);
        end
        
        %if external functions shown on the figure, must add them to the list of
        %functions (with -1 line number, or additional field to flag them as
        %external ?)
        if data.out.extshow
            ne = numel(data.external);
            nf = data.fun.numof;
            data.fun.name = [data.fun.name data.external];
            data.fun.beg  = [data.fun.beg  nan(1,ne)];
            data.fun.end  = [data.fun.end  nan(1,ne)];
            data.fun.gen  = [data.fun.gen  zeros(1,ne)];
            data.fun.kind = [data.fun.kind repmat('E',[1 ne])];
            data.fun.numof = data.fun.numof + ne;
            data.fun.show = [data.fun.show ones(1,ne)];
            data.fun.deps = false(ne+nf,ne+nf);
            data.fun.used = [data.fun.used true(1,ne)];
            data.fun.hide = [data.fun.hide false(1,ne)];
        end
        
    end

    function data = sub_deps(data)
        for i=1:numel(data.fun.name)
            %lines is lines owned by this function only
            lines = data.fun.beg(i):data.fun.end(i);
            %remove any lines from nested functions within this function
            %all lines belonging to higher generation functions
            for I = find(data.fun.gen>data.fun.gen(i));
                lines(lines>=data.fun.beg(I) & lines<=data.fun.end(I)) = [];
            end
            called = unique(data.call.name(ismember(data.call.line,lines)));
            
            data.fun.deps(i,:) = false(size(data.fun.name));
            for j=1:numel(called)
                tf = ismember(data.fun.name,called{j});
                if sum(tf)==1;
                    data.fun.deps(i,tf) = true;
                    continue;
                end
                if sum(tf)>1;
                    %need to find the one of several options being called
                    I = find(tf);
                    
                    %recursively search up through my parents, starting with me
                    done = false;
                    me = i;
                    while ~done;
                        %ignore any that are above gen(me)+1
                        I(data.fun.gen(I)>data.fun.gen(me)+1) = [];
                        %if it is in me and my gen+1, use this
                        isin = ...
                            data.fun.beg(I)>data.fun.beg(me) & ...
                            data.fun.end(I)<data.fun.end(me);
                        ischild = data.fun.gen(I) == data.fun.gen(me)+1 & isin;
                        if any(ischild);
                            data.fun.deps(i,I(ischild)) = true;
                            done = true;
                            continue
                        end
                        
                        %if we are gen=0, are there any other gen=0 that match ?
                        if data.fun.gen(me)==0 && any(data.fun.gen(I) == 0);
                            I(data.fun.gen(I)>0) = [];
                            data.fun.deps(i,I) = true;
                            done = true;
                            continue;
                        end
                        
                        %recursively search up through my parents doing the same thing
                        if data.fun.gen(me)>0; me = sub_dad(data,me); continue; end
                        
                        %if we are here, we are gen 0 and haven't found it, give up
                        keyboard
                        done = true;
                    end
                end
            end
        end
        %TODO deal with non-unique funciton names
        %TODO list plot : plot text to figure, draw lines on that.
        
        function dad = sub_dad(data,me)
            dad = find(...
                data.fun.beg<data.fun.beg(me) & ...
                data.fun.end>data.fun.end(me) & ...
                data.fun.gen==data.fun.gen(me)-1);
            if isempty(dad) || numel(dad)>1;
                keyboard
            end
        end
    end

    function data = sub_find_used(data)
        %flag functions as "used" if main function depends on them
        
        if sum(data.fun.kind=='M')==0;
            return
        end
        
        %for the sake of these checks, ignore calls to self
        deps = data.fun.deps; deps(eye(size(deps))==1) = false;
        
        %for the sake of these checks, hidden functions have no kids/parents
        deps(~data.fun.show,:) = false;
        deps(:,~data.fun.show) = false;
        
        %start with only file and main function shown
        tf = ismember(data.fun.kind,'M');
        try
            if sum(tf)~=1; error('should have only one main function'); end
        catch
            keyboard
        end
        used = tf;
        
        %recursively : all children of shown, add to set of shown
        used_old = 0;
        while ~isequal(used,used_old)
            used_old = used;
            used = used | any(deps(used,:),1);
        end
        
        %update functions shown
        data.fun.used = used;
        
    end

    function data = sub_unique_names(data)
        %invents unique names (preferably of the same length as the original) for
        %each function. This is done so different subroutines with the same name
        %are shown correctly, rather than being lumped together as one function
        
        %20150130 catch empty
        if isempty(data.fun.name); return; end
        
        %TODO20150215 tag names changed below, so they get changed back!
        %do not rely on string-replace, as that may change functionnames that
        %really were sub_a__line231_
        for names = unique(data.fun.name)
            name = names{1};
            I = find(ismember(data.fun.name,name));
            if numel(I)>1
                for i = I
                    data.fun.name{i} = [data.fun.name{i} ' (line' num2str(data.fun.beg(i)) ')'];
                end
            end
        end
    end

end

function data = sub_add_filebox(data,foo)
%20150331 add the file itself as an "F" class function

[~,name,ext] = fileparts(data.foo);
data.fun.name = [{[name ext]},data.fun.name];
data.fun.beg = [nan data.fun.beg];
data.fun.end = [nan data.fun.end];
data.fun.gen = [0 data.fun.gen];
data.fun.kind = ['F' data.fun.kind];
data.fun.numof = data.fun.numof + 1;
data.fun.show = [true data.fun.show];
data.fun.used = [true data.fun.used];
data.fun.hide = [false data.fun.hide];

%20150406 change default name format to file>fun
tf = ~ismember(data.fun.kind,'FE');
[~,f] = fileparts(data.fun.name{1});
data.fun.name(tf) = regexprep(data.fun.name(tf),'(^.)',[f '>' '$1']);

%warn if main function name does not match the file name
I = find(data.fun.kind=='M',1,'first');
if isempty(I);
    %there is no main function, file does not link to any content
    %strip list of "functions" down to be only first (filename)
    %this happens e.g. with class definitions
    
    keep = false(size(data.fun.name));
    keep(1) = true;
    data.fun.deps = false(data.fun.numof,data.fun.numof);
    data = sub_keep_fun(data,keep);
    %if file was not found, change file name to "foo (not found)"
    if isempty(data.foo);
        data.fun.name{1} = sprintf('%s (not found)',foo);
    else
    %if it is a class, change file name to "foo (class)"
    if exist(foo,'class');
        data.fun.name{1} = sprintf('%s.m (classdef)',foo);
    else
        %if there are no functions whatsoever, it's a script
        if data.fun.numof==1 && data.fun.kind=='F';
            data.fun.name{1} = sprintf('%s (script)',data.fun.name{1});
        end
    end
    end
else
    a = regexp(data.fun.name{2},'(?<file>.+?)>(?<fun>.+)','names');
    if ~isequal(a.file,a.fun);
        warning('main function name does not match filename in "%s"\nThis can cause infinite loops in the analysis',...
            data.fun.name{1});
    end
    
    %create dependency from file to main function only
    deps = data.fun.deps;
    deps = [false(size(deps,1),1) deps];
    deps = [false(1,size(deps,2)) ; deps];
    deps(1,2) = true;
    
    %all dependencies to the main function now go to the file itself
    if data.opt.filelink;
        I = deps(:,2); I(1) = false;
        deps(I,1) = true;
        deps(I,2) = false;
    end
    data.fun.deps = deps;
    
    %if not showing main functions
    if ~data.out.showmain
        while any(data.fun.kind=='M');
            I = find(data.fun.kind=='M',1,'first');
            if ~data.fun.kind(I-1)=='F'; keyboard; end
            %remove the dependence from file to me
            data.fun.deps(I-1,I) = false;
            %pass all my kid dependencies to my dad
            data.fun.deps(I-1,:) = data.fun.deps(I-1,:) | data.fun.deps(I,:);
            %pass all my dad dependencies to my kids
            data.fun.deps(:,I-1) = data.fun.deps(:,I-1) | data.fun.deps(:,I);
            keep = true(size(data.fun.name));
            keep(I) = false;
            data = sub_keep_fun(data,keep);
        end
    end
end
end

function data = sub_extsub(data)
%if external subroutines requested, dig into each one
if ~data.out.extsub; return; end

%prevent infinite recursion loops by only examining each file once
if ~isfield(data.fun,'done');
    data.fun.done = true(size(data.fun.name));
    data.fun.done(data.fun.kind=='E') = false;
end

while ~all(data.fun.done);
    
    I = find(~data.fun.done,1,'first');
    if ~data.fun.kind(I)=='E'; data.fun.done(I) = true; continue; end
    %do not use external dependencies that are not shown
    if ~data.fun.show(I);      data.fun.done(I) = true; continue; end
    ext = data.fun.name{I};
    opts = regexprep(data.varargin,'-extsub','-ext');
    new = plot_subfun(ext,'-noplot',opts{:});
    data = sub_combine(data,new,I);
    data.fun.done(I) = true;
end
end

function data = sub_combine(data,new,I)
%data = sub_combine(data,new,I)
%adds results from new to data, as dependents of Ith function in data

%change I from an E to and F
data.fun.kind(I) = 'F';
data.fun.name(I) = new.fun.name(1);

%find new that reference the file, keep for later
isDepToFile = new.fun.deps(1,:)==1;

%remove file from new function (is already in found)
keep = true(size(new.fun.name)); keep(1) = false;
isDepToFile = isDepToFile(keep);
new = sub_keep_fun(new,keep);

%add to functions
for field = {'name','beg','end','gen','kind','show','used','hide','done'};
    a = data.fun.(field{1});
    b = new.fun.(field{1});
    data.fun.(field{1}) = [a b];
end
data.fun.numof = numel(data.fun.beg);

%
%% update dependencies
deps = data.fun.deps;
%pad with zeros
n = numel(new.fun.name);
m = numel(data.fun.name)-n;
deps(m+n,m+n) = false;
%new dependencies into the lower-right corner
ndep = new.fun.deps;
[a,b] = ind2sub(size(ndep),1:numel(ndep));
a = a+m;
b = b+m;
loc = sub2ind(size(deps),a,b);
deps(loc) = ndep;

for J = find(isDepToFile)
    deps(I,J+m) = true;
end

%if any new dependencies are to functions we already have, remove them
J = find(data.fun.kind=='F');
f = regexprep(data.fun.name(J),'\..+','');
keep = true(size(data.fun.name));
for i= find(new.fun.kind=='E');
    [tf,loc] = ismember(new.fun.name{i},f);
    if tf;
        %find my dads (those that call me)
        dads = deps(:,i+m);
        %these dads should now point to the file
        deps(dads,J(loc)) = true;
        %remove external calls to myself
        deps(:,i+m) = false;
        %flag external call for removal
        keep(i+m) = false;
    end
end



%finally, make this the new dependency map
data.fun.deps = deps;

data = sub_keep_fun(data,keep);


%deduplicate external function calls to function that have not been
%examined
n = data.fun.name(data.fun.kind=='E');
keep = true(size(data.fun.name));
deps = data.fun.deps;
if numel(unique(n))<numel(n)
    for f = unique(n)
        tf = ismember(data.fun.name,f{1});
        if sum(tf)==1; continue; end
        I = find(tf); %I is the first, that we want to map to
        J = I(2:end); %J are the ones we want to remove
        I =I(1);
        if numel(J)>1; keyboard; end
        %find dependencies to any of J, hand to I
        dads = any(deps(:,J),2);
        deps(:,I) = deps(:,I) | dads;
        keep(J) = false;
    end
end
data.fun.deps = deps;
data = sub_keep_fun(data,keep);

%modify the list of calls
[~,foo] = fileparts(new.foo);
for i=1:numel(new.call.name)
    new.call.name{i} = [foo '>' new.call.name{i}];
end
data.call.name = [data.call.name new.call.name];
data.call.line = [data.call.line new.call.line];
data.call.isext = [data.call.isext new.call.isext];
end

function data = sub_keep_fun(data,keep)
if ~isfield(data.fun,'done');
    data.fun.done = true(size(data.fun.name));
    data.fun.done(data.fun.kind=='E') = false;
end

for f = {'name','beg','end','gen','kind','show','used','hide','done'};
    val = data.fun.(f{1});
    try
        data.fun.(f{1}) = val(keep);
    catch
        keyboard
    end
end
try
    data.fun.deps = data.fun.deps(keep,:);
    data.fun.deps = data.fun.deps(:,keep);
catch
    keyboard
end
data.fun.numof = numel(data.fun.name);
end

%% HIDE FUNCTIONS

function data = sub_hide(data)
data = sub_hide_used(data);         %decide if used/unused are shown
data = sub_hide_funs(data);         %hide functions
data = sub_hide_kids(data);         %hide kids
data = sub_hide_nest(data);         %hide nested
data = sub_hide_ends(data);         %hide one-parent dead ends
end

function data = sub_hide_used(data)
show = true(size(data.fun.name));
if data.hide.used; show( data.fun.used) = false; end
if data.hide.orph; show(~data.fun.used) = false; end
show(1) = true; %the file itself is always shown
data.fun.show = data.fun.show & show;
end

function data = sub_hide_funs(data)
if isempty(data.hide.funs); return; end

[tf,loc] = ismember(data.hide.funs,data.fun.name);
%20150406 also hide by just function name, not just file>function
[tf2,loc2] = ismember(data.hide.funs,regexprep(data.fun.name,'.+>',''));
loc = [loc(tf) loc2(tf2)];

show = true(size(data.fun.name));
show(loc) = false;
data.fun.show = data.fun.show & show;
data.fun.hide(~show) = true;
end

function data = sub_hide_kids(data)
if isempty(data.hide.kids); return; end

%local version of dependencies, we can muck with. do not feed up to parent.
%for the purpose of these checks, links to self do not count
deps = data.fun.deps;
deps(eye(size(deps))==1) = false;

%20150406 functions are called file>function ; also accept just function
%name
[tf,loc] = ismember(data.hide.kids,regexprep(data.fun.name,'.+>',''));

%names of functions whose kids to hide
names = unique([data.hide.kids data.hide.funs data.fun.name(loc(tf))]);

%functions that originally had no dads, these will not be hidden
orig = sum(deps,1)==0;

%will never hide themselves when doing the kids thing
orig(ismember(data.fun.name,names)) = true;

%will never hide their parent (main function or file) when doing the kids thing
parents = regexp(names,'.+>','match','once');
parents = regexprep(parents,'>$','');
parents = parents(~cellfun('isempty',parents));
for i=1:numel(parents)
    str = parents{i};
    pat = ['^' str '\.'];
    I = ~cellfun('isempty',regexp(data.fun.name,pat,'once'));
    orig(I) = true;
    pat = ['^' str '>' str '$'];
    I = ~cellfun('isempty',regexp(data.fun.name,pat,'once'));
    orig(I) = true;
end

nokids_old = nan;
nokids_new = ismember(data.fun.name,names);
%iterate until nokids does not change
while ~isequal(nokids_old,nokids_new)
    %sever connections to their kids
    deps(nokids_new,:) = false;
    %update set nodads (ignore orig)
    nodads = sum(deps,1)==0;
    nodads(orig) = false;
    %these are now nokids
    nokids_old = nokids_new;
    nokids_new = nodads;
end
data.fun.show(nokids_new) = false;
data.fun.hide(nokids_new) = true;
end

function data = sub_hide_nest(data)
if ~data.hide.nest; return; end %if nested option not received, do nothing
nest = data.fun.gen>0; %functions that are nested
for i=find(nest)
    if ~data.fun.show(i); continue; end %if already hidden, ignore
    %my parents inherit my children
    dads = data.fun.deps(:,i);
    try
        data.fun.deps(dads,:) = data.fun.deps(dads,:) | repmat(data.fun.deps(i,:),[sum(dads) 1]);
    catch
        keyboard
    end
    %ignore me
    data.fun.show(i) = false;
    data.fun.hide(i) = true;
end
end

function data = sub_hide_ends(data)
if ~data.hide.ends; return; end

%for the purpose of this test, calls to self to not count
deps = data.fun.deps;
deps(eye(size(deps))==1) = false;

%for the purpose of this test, hidden functions do not count
deps(~data.fun.show,:) = false;
deps(:,~data.fun.show) = false;

%hide dead ends, with one parent and no kids
nokids = ~any(deps,2)';
onedad = sum(deps,1)==1;
data.fun.show(nokids & onedad) = false;
data.fun.hide(nokids & onedad) = true;
end

%% PLOT, DISPLAY AND OUTPUT
function opt = sub_show_plot(data)
if ~data.out.plot; opt = []; return; end
data = sub_trim(data,true);

if ~any(data.fun.deps(:));
    if ~isempty(regexp(data.fun.name{1},'\(classdef\)','once'));
        disp('This is a class definition, no subroutines shown');
    else
        disp('There are no subroutines to show');
    end
    opt=[];
    return;
    
end

data = sub_add_fake_self(data);

%array of colours
c = [...
    0 0 0 ; ... %black
    0 0 1 ; ... %blue
    0 1 0 ; ... %green
    1 0 0 ; ... %red
    .9 .9 .9];  %gray

%colours of each box
deps = data.fun.deps;
deps(eye(size(deps))==1) = false; %for the purpose of this check (only) ignore calls to self
J = data.fun.gen>0; %is nested
K = data.fun.kind == 'E';
cols = 2*ones(size(data.fun.name));
cols(K) = 1;
cols(J) = 3;

%shape of each box (rounded or square corners)
I = ismember(data.fun.kind,'F') | ismember(data.fun.kind,'E');
shaps(~I) = 'r';
shaps(I)  = 's';
cols(I) = 4;

%convert the dependencies into from/to pairs
[from,to] = ind2sub(size(deps),find(data.fun.deps));

%20150401 PLOT_GRAPH can cope with any string, not just mwdot compatible
%this bit no longer needed
%old = data.fun.name;
%new = sub_names_mwdot(old);
%opt = plot_graph(new,from,to,'-colours',cols,'-shape',shaps);
%correct names from mwdot compatible
%opt = sub_show_fix_names(opt,old,new);
if ~data.out.filename;
    names = regexprep(data.fun.name,'.+>','');
else
    names = data.fun.name;
end
opt = plot_graph(names,from,to,'-colours',cols,c,'-shape',shaps);


[opt,data] = sub_remove_fake_self(opt,data);
opt = sub_show_unhide(opt,data,c(5,:)); %change colour of -unhide function to grey

%if external called, add a list of external function to the right hand side
%of the plot
if data.out.extlist
    %add 20% to the right axes limits
    x = get(gca,'xLim');
    y = get(gca,'yLim');
    dx = [0 0.2*diff(x)];
    set(gca,'xLim',x+dx);
    %write into this space
    txt = data.external; if isempty(txt); txt = {'none'}; end
    txt = [{'EXTERNAL CALLS:','=================='},txt];
    txt = strrep(txt,'_','\_');
    %text(x(2),y(2)-0.1*diff(y),txt,...
    %    'VerticalAlignment','Top');
    text(x(2),y(2),txt,...
        'VerticalAlignment','Top');
end

%correct names of type "sub_a__line203_" to "sub_a (line203)"
%opt = sub_show_fix_names(opt);

end

function opt = sub_show_unhide(opt,data,col)
%boxes forcibly shown with the -unhide option are coloured grey as it their
%text and any lines to/from them

%which function are hidden
if ~data.out.unhide; return; end
targ = find(data.fun.hide);

%find hidden nodes, colour them grey
tf = ismember([opt.node(:).index],targ); %nodes that are hidden
for i=find(tf)
    set(opt.node(i).handle_box,'EdgeColor',col)
    set(opt.node(i).handle_text,'Color',col)
end

%edges to/from hidden boxes also coloured grey
val = vertcat(opt.edge.nodeindex);
tf = ismember(val(:,1),targ) | ismember(val(:,2),targ);
for i=find(tf')
    set(opt.edge(i).handle,'Color',col);
    set(opt.edge(i).handle_arrow,'FaceColor',col,'EdgeColor',col);
end
end

function data = sub_add_fake_self(data)
deps = data.fun.deps;
%those that have no dad or kid links gain a fake self (just so they are
%shown).
nodad = sum(deps)==0;
nokid = sum(deps,2)==0;
I = nodad & nokid';
data.fakeself = find(I);
I = sub2ind(size(deps),data.fakeself,data.fakeself);
data.fun.deps(I) = true;
end

function [opt,data] = sub_remove_fake_self(opt,data)

%find list of function names that have fake selfs:
names = data.fun.name(data.fakeself);
keep = true(size(opt.edge));
for i=1:numel(opt.edge)
    e = opt.edge(i);
    if ~isequal(e.endpoints{1},e.endpoints{2}); continue; end
    if ismember(e.endpoints{1},names);
        keep(i) = false;
    end
end

%remove the fake edges from the figure
for I = find(~keep);
    delete(opt.edge(I).handle);
    delete(opt.edge(I).handle_arrow);
end
%remove the fake edges from the figure
opt.edge = opt.edge(keep);
data = rmfield(data,'fakeself');
end

function sub_show_list(data)
if ~data.out.list; return; end

for i=1:numel(data.fun.name)
    fprintf(' \n');
    switch data.fun.kind(i)
        case 'F';
            fprintf('=== FILE "%s" ===\n',data.fun.name{i});
            continue;
        otherwise
            fprintf('%s (line %d-%d)\n',...
                data.fun.name{i},...
                data.fun.beg(i),...
                data.fun.end(i));
    end
    for j=find(data.fun.deps(i,:))
        fprintf('-%s\n',data.fun.name{j})
    end
end
end

function data = sub_trim(data,varargin)
if ~data.out.trim && nargin<2; return; end
if data.out.unhide
    keep = data.fun.show | data.fun.hide;
else
    keep = data.fun.show;
end

for name = {'name','beg','end','gen','kind','show','used','hide'}
    val = data.fun.(name{1});
    data.fun.(name{1}) = val(keep);
end
try
    data.fun.deps = data.fun.deps(keep,:);
catch
    keyboard
end
data.fun.deps = data.fun.deps(:,keep);

data.fun.numof = sum(keep);

%remove calls to removed functions
keep = ismember(data.call.name,data.fun.name);
data.call.name = data.call.name(keep);
data.call.line = data.call.line(keep);
end

function data = sub_remove_desc(data)
if ~data.out.desc;
    data.fun.name = regexprep(...
        data.fun.name,...
        {'\(not found\)','\(classdef\)','\(script\)'},...
        {'','',''});
end
end

%% SUBROUTINES THAT DO NOTHING
%These are only here to be seen in the codetree of this function
%to show how looped and orphaned functions look.

function sub_a() %#ok<DEFNU>
sub_aa()
    function sub_aa()
        sub_b()
    end
end

function sub_b()
sub_a()
    function sub_a()
        sub_b()
        function sub_b()
        end
    end
end

function sub_notcalled() %#ok<DEFNU>
sub_selfcalled()
sub_nested()
    function sub_nested()
    end
end

function sub_selfcalled()
sub_selfcalled()
end

function sub_pair1()
sub_pair2()
end

function sub_pair2()
sub_pair1()
sub_deadend()
end

function sub_deadend()
end

function twodad1()
twodad3()
end

function twodad2() %#ok<DEFNU>
twodad3()
end

function twodad3()
twodad4()
end

function twodad4()
twodad5;
end

function twodad5()
twodad1()
end

function isolatedloop()
isolatedloop();
end

%% DEVNOTES
%20140901   added handling of multiple instances of the same function name
%20150215   cleaned up display of multiple subrotines that share a name:
%           "sub_a__line231_" becomes "sub_a (line231)"
%DONE       handles subroutines truly called sub_a__line231_
%DONE       add '-kids' option, that removes children instead of self.
%DONE       if you want to show a function with no deps : make deps to self, then remove link on plot
%20150228   rewritten based on user feedback
%           reorganised code for modularity
%           added additional options for show/hide
%20150301   bugfix to handle built-in function
%           bugfix to handle empty functions
%DONE       -unhide option for demos, shows in grey (smaller ?)
%TODO       colorblind mode (custom colours)
%TODO       warn when analysing a built-in function
%DONE       extlist vs extshow options (ext also -> extlist)
%           ext to show as black. list separate
%TODO       builtin option ?
%DONE       give self a file box
%DONE       get -unused and -unusedonly to work with -extsub
%DONE       plot_graph try to fill the screen (scale text ?)
%DONE       if main filename does not match function name, warn
%           gray out all links to main file
%DONE       all files reference self, get rid of this
%DONE       plot_graph can now handle any string as input, no longer need
%           to alter strings here
%DONE       recursive calls to main should point to function itself instead
%DONE       option -recurse to recurse through all dependencies
%TODO       option cellfun to get a list of files and subfun them all
%DONE       -fileloop shows some unused code, why ?
%DONE       -unusedonly some dependecies to main broken
%           must add box at the last minute, after hide and kids options
%DONE       -filedep function removes the main function in each file
%           all links to this should already be broken
%DONE       by default show file>fun for all
%           option to remove this from shown (but not from hide format)
%DONE       remove function by name or file>name
%DONE       finds all external dependencies before hiding : want hide first
%TODO       limit figure size
%DONE       when hiding children of a "hide" function, never hide their
%           parent file / main function !
%DONE       handles not-found files and classes more gracefully
%TODO       -notfound option to supress not-found functions
%TODO       limit number of items ?
%TODO       multiple calls to notfound/classdef all become separate items,
%           should be one.
%TODO       not being deduplicated properly
%TODO       option to have (script)(classdef)(not found) in filenames ?
%20161207   bugfix sub_show_unhide (thanks Amro)
