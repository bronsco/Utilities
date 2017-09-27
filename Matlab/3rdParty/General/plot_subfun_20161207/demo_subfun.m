%% PLOT_SUBFUN
% plot_subfun creates a plot of the subroutines in an m-file, and how they
% depend on each other. There are options to selectively show/hide some
% subroutines, export the results to a structure, and include calls to
% external functions.
%%



%% *BASIC EXAMPLE*
% The example below is the subroutines in the file plot_subfun.m.
% The m-file to be examined will be located with the "which" command.
% a message is displayed if the file cannot be found, or the file has no
% subroutines.
%
% The functions in the file are coloured according to:
% blue : default, red : files, green : nested/scoped within another function.
%
% Arrows are function calls : for example sub_setup calls sub_deps. This is
% known as a dependency OF sub_ setup ON sub_deps. We will describe these as
% parent-child relationships, where sub_setup is the "parent", and sub_deps
% the "child".
%
% For the purpose of this demo, we will be using the '-unhide' option,
% which displays hidden functions in grey, rather than remove them from the
% plot
%%
plot_subfun('plot_subfun','-unhide');

%% All Options
% * *-ends*       hide functions with one parent and no kids
% * *-extlist*    show calls to external functions in a separate list
% * *-extshow*    show calls to external functions on the figure
% * *-extsub*     recursively shows all subroutines of external functions too
% * *-filename*   shows filename as part of function name
% * *-hide*       hide named functions and their children
% * *-kids*       as -hide, but only hides the children
% * *-list*       display list of all functions and their calls to command line
% * *-nest*       hide nested functions
% * *-nodesc*     hides additional description such as (not found)
% * *-nomain*     hides the main function of each file
% * *-noplot*     do not plot the figure
% * *-trim*       trims the output to just the visible functions
% * *-unhide*     hidden functions are shown in grey instead
% * *-unused*     also show functions that are not called
% * *-unusedonly* only show functions that are not called
%
% This demo shows how these options work, using the file plot_subfun.m
% itself as the file to examine
%%

%% *HIDING*
% there are four options for selectively hiding some functions so they are
% not shown : -hide, -kids, -nest, -ends and -nomain.

%% -hide
% The -hide option accepts a number of function names, and hides them from
% the plot. It will also hide any children that only depend on other hidden
% functions.
%%
plot_subfun('plot_subfun','-unhide','-hide','sub_setup');

%% -kids
% The -kids option acts in much the same manner, except it does not hide
% the named function itself, just the children beneath it
%%
plot_subfun('plot_subfun','-unhide','-kids','sub_setup');

%% -nest
% The -nest option hides all functions that are nested inside another (i.e.
% the ones that are normally shown in green 
%%
plot_subfun('plot_subfun','-unhide','-nest');

%% -ends
% The -ends option hides all function that are called by just one parent,
% and do not call any children
%%
plot_subfun('plot_subfun','-unhide','-ends');

%% -nomain
% this option removes the main function of each file, passing all
% dependencies to the file itself. in the example below, the function
% plot_subfun>plot_subfun is removed
plot_subfun('plot_subfun','-nomain');

%% combinations
% the -hide and -kids affect all function names received subsequently. All
% function names received before either of these flags are presumed to be
% "hide". Note how the function sub_trim is NOT hidden, because it has at
% least one parent that is not hidden.
%%
plot_subfun('plot_subfun','-unhide','sub_setup','-kids','sub_hide','-hide','sub_show_plot');

%% combinations
% the four hide options are applied in the order -hide,-kide,-ends,-nest.
% Any function that is hidden by a previous option is treated as if it does
% not exist for the purpose of later options. For example, in the below the
% kids of sub_setup are hidden, so sub_setup is also hidden by the -ends
% option
%%
plot_subfun('plot_subfun','-unhide','-kids','sub_setup','-ends')

%% *EXTERNAL FUNCTIONS*
% by default, calls to external functions are not shown, but a list of
% external functions is returned.  This list excludes any functions that 
% are on the matlab root.
data = plot_subfun('plot_subfun','-noplot');
data.external

%% -extlist
% this option will generate a separate text list on the plot with the 
% names of the external functions called. It squeezes the x axis to make
% space for the list, so some text may spill outside boxes.
plot_subfun('plot_subfun','-extlist');

%% -extshow
% this option will show the names of external functions called on the plot.
% These are shown using black rectangles.
% In the example below, there is only one external call (plot_graph).
plot_subfun('plot_subfun','-extshow');

%% -extsub
% this option recursively examines all other functions called, and displays
% their subroutines as well.
plot_subfun('plot_subfun','-extsub');

%%
% The number of functions shown can quickly become unmanageable. Consider
% using plot_depfun first to just find file dependencies, then use -hide or
% -kids to hide subroutines of files you are not interested in.
%%

%%
% Some files do not parse well in m-lint. plot_subfun deals with three
% specific cases as follows: 
%%

%%
% * If the file "foo" is not found, it is still displayed, but as "foo 
% (not found)". 
% * If the file "foo" is a class definition, no subroutines are shown, and
% the file displays as "foo (classdef)".
% * if the file is a script, the file displays as "foo (script)".
% * these additional descriptions of file class can be supressed with the
% -noclass option.
%%

%%
% The exception for class definitions is because m-lint does not correctly
% parse the dependence of object methods upon each other.
%
% The "not found" exception may occur when using a variable that has been
% generated using eval or load. In this case m-lint has not recognised it
% as a variable, so treats it as a function.
%%

%% -filename
% This option adds the filename to the start of each function, e.g.
% sub_setup becomes plot_subfun>sub_setup.
%%

%% hiding external subroutines
% the names of functions to hide can be given as a filename (plot_subfun.m)
% a function name (sub_setup) or the full form with filename (e.g. plot_subfun>sub_setup).
% if you use the shorter form of just a function name, be aware all
% functions of that name will be hidden, across all files!

%% *UNUSED CODE*
% unused code is function that is not called by the main function, or any
% of its children. In normal operation, these function will not be used. By
% default, unused function will be hidden, but they can be revealed with
% the '-unused' or '-unusedonly' options. The file plot_subfun.m includes
% a number of unused functions to demonstrate this:
%
% The -unusedonly option shows just the unused code.
%%
plot_subfun('plot_subfun','-unhide','-unused');


%% a warning about "unused" code
% plot_subfun uses the undocumented mlintmex function to examine the
% function calls and dependencies within the function. This cannot parse
% function calls that are generated at runtime, such as calls to eval  or
% function handles. For example, the command eval('sub_plot_3') will not be
% parsed as a dependency on function sub_plot_3.
%
% So before you go deleting any apparently unused code, make sure it's not
% actually called in one of these ways. If in doubt, just comment out the
% subroutine you wish to remove and check that the function still works.
%%

%% *OUTPUT*
% by default, plot_subfun does not return any output. If an output is
% requested, a structure will be returned with the same information as
% shown in the figure. 
%%
data = plot_subfun('plot_subfun','-noplot')

%% -trim
% The -trim option reduces the returned data to just the functions shown in
% the figure, otherwise all functions are returned.
%%
data = plot_subfun('plot_subfun','-noplot','-hide','sub_setup'); disp(numel(data.fun.name));
data = plot_subfun('plot_subfun','-noplot','-hide','sub_setup','-trim'); disp(numel(data.fun.name));

%% *DISPLAY*

%% -noplot
% -noplot causes no figure to be created

%% -list
% -list   displays a list of all functions and their calls on the command
% line

%% -filename
% -filename shows the parent filename in each function node on the figure
plot_subfun('plot_subfun','-filename');

%% *ADVANCED*

%% kids and loops
% The functions given to "-kids" will not be hidden by the -kids option.
% They may get hidden by other options later.
% For example, below, twodad2 is a child of twodad5, which is hidden. But
% since twodad2 was one of the names originally passed to the -kids option,
% it will not be hidden.
%
% Similarly, the -hide and -kids options will never hide their own parent
% (either main function or filename), even if the hidden function calls the
% parent.
%%
plot_subfun('plot_subfun','-unhide','-unusedonly','-kids','twodad1','twodad2');

%% subroutines with the same name
% It is possible for several subroutines to have the same name, 
% so long as they are scoped correctly so there is never any confusion
% about which version to call. Each of these is given a unique name with
% the line number of their function definition, so you know which is which.
% For example, note how sub_a and sub_b both occur twice in the figure
% below.
%%
plot_subfun('plot_subfun','-unusedonly');

%% function name matching
% If multiple versions of a function name exist, you must specify which 
% with the line number, e.g. instead of sub_b, use 'sub_b (line859)'
%%
plot_subfun('plot_subfun','-unhide','-unusedonly','-hide','sub_b (line859)');


%% dependency passthrough
% when a function is hidden by the "nest" option,  all of its 
% parent dependencies are passed to its children, and all of its child 
% dependencies are passed to its parents. For example, below, sub_aa 
% has been removed, but sub_a has inherited the dependency on sub_b.
%%
plot_subfun('plot_subfun','-unusedonly','-unhide','-nest')

%% unhide
% The unhide option is used mainly for documentation. Instead of hiding
% functions, it shows them in gray.
% Functions removed by -kids, -hide, -nest, -ends will be shown in
% grey. Function removed by -unusedonly will not be affected by the -unhide
% option.
%%

%% *UNDER THE HOOD*

%% Limitations
% * plot_subfun relies on "which" to determine which m-file to examine.
% If the filename returned by "which" changes (e.g. because you changed the
% path), the file being examined by plot_subfun will also change
% * plot_subfun calls mlintmex to analyse the function dependencies.
% * The figure is created in plot_graph, which relies on the separate
% executable mwdot. Depending on user privileges, mwdot may need separate
% whitelisting before it can run. The call to mwdot has been tested under
% windows7 and mac osx 10, but not unix/linux.
% * plot_subfun and mlintmex do not check that the file actually contains any
% code. some m-files don't actually contain any code, but are simply
% wrappers for built-in files or mex files. For these, plot_subfun will
% return that there are no subroutines. For example:
%%
plot_subfun('plot');

%% changelog
% * 2015-04-15 plot_subfun catches cases of file is missing, a script or a
% class definition. Previously some of these might throw errors.
% * 2015-04-10 plot_graph now scales font to use full available size on
% screen.
% * 2015-04-10 plot_subfun can now additionally report subroutines of
% external functions called
%%

%% feedback
% I am not able to test this function on all combinations of operating 
% system, matlab version,  screen size, etc. If you do encounter any 
% problems, please feel free to provide feedback via the plot_subroutines 
% page on the matlab file exchange.