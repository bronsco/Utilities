function varargout = profile(varargin)
    % wrapper function from the builtin profile() function, with extra -timing input arg

    % Unfortunately, the following fails since profile() is an m-file, not built-in:
    %varargout = builtin('profile','-timing',varargin{:});

    % Also unfortunately, @char/profile.m precedes the Matlab path (http://mathworks.com/help/matlab/matlab_prog/function-precedence-order.html)
    % So copy the original profile.m function here, rename it and then use it:
    %
    % Note: theoretically, we only need to copy profile.m once, but if the use uses multiple Matlab releases
    % ^^^^  then this could cause incompatibilities - it's safer to copy profile.m each single time.
    curFolder = fileparts(mfilename('fullpath'));
    targetFileName = [curFolder '/profile_orig.m'];
    try
        oldWarn = warning('off','MATLAB:DELETE:FileNotFound');
        delete(targetFileName);
        copyfile([matlabroot '/toolbox/matlab/codetools/profile.m'], targetFileName, 'f');
    catch
        % might not be writable for some reason
    end
    warning(oldWarn);

    % At this point, the @char folder should contain a copy of the original (MathWorks)
    % profile.m, renamed profile_orig.m, so try to invoke it with the specified input args
    %
    % Note: Theoretically we only need to call profile('-timestamp',...), or the equivalent callstats('history',2), once.
    % ^^^^  So after running the first time, we could simply delete this profile.m wrapper file.
    %       Unfortunately, this would not work when using separate Matlab releases on the same computer,
    %       since each release stores its own separate callstats() settings. Also, if the user happened
    %       to call profile('-history',...) then this would override the setting and profile_history would
    %       no longer have timing data to work with. So it's safer to call '-timestamp' each single time.
    if nargout
        % one or more output arg(s) requested
        if any(strcmpi(varargin,'on'))
            varargout{:} = profile_orig('-timestamp',varargin{:});
        else
            varargout{:} = profile_orig(varargin{:});
        end
    else  % no output args requested
        if any(strcmpi(varargin,'on'))
            profile_orig('-timestamp',varargin{:});
        else
            profile_orig(varargin{:});
        end
    end
end
