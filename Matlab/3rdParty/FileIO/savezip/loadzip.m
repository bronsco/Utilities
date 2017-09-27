function data = loadzip(filepath)
% loadzip - load data from a compressed zip file
%
% loadzip accepts a file name/path previously saved with savezip, and
% returns its contained data. If the specified filepath does not include
% an extension, then '.zip' is assumed.
%
% Syntax:
%    data = loadzip(filepath)
%
% Input Parameters:
%    filepath - filename with optional path (default: current folder)
%                  and extension (default: '.zip')
%
% Output parameters:
%    data - Matlab data, previously stored using the savezip utility
%
% Examples:
%    savezip('myData', magic(4))   %save data to myData.zip in current folder
%    savezip('myData', 'myVar')    %save myVar to myData.zip in current folder
%    savezip('myData.gz', 'myVar') %save data to myData.gz in current folder
%    savezip('data\myData', magic(4))    %save data to .\data\myData.zip
%    savezip('data\myData.gz', magic(4)) %save data to .\data\myData.gz
%
%    myData = loadzip('myData');
%    myData = loadzip('myData.zip');
%    myData = loadzip('data\myData');
%    myData = loadzip('data\myData.gz');
%
% Technical description:
%    http://UndocumentedMatlab.com/blog/savezip-utility
%
% Note: 
%    This utility relies on the undocumented and unsupported serialization
%    functionality, as described in http://undocumentedmatlab.com/blog/serializing-deserializing-matlab-data
%    It works on all the recent Matlab releases, but might stop working in
%    any future Matlab release without prior notice. Use at your own risk!
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% See also:
%    save, load, savezip
%
% Release history:
%    1.0 2014-08-29: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>

% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.0 $  $Date: 2014/08/29 14:31:30 $

    % Some sanity checks
    if nargin<1
        error('YMA:loadzip:args','The file path must be specified as input argument.');
    elseif ~ischar(filepath)
        error('YMA:loadzip:filepath','Input argument must be a string (file name/path).');
    end

    % Get the requested input file's full path
    [fpath,fname,fext] = fileparts(filepath);
    if isempty(fext),   fext = '.zip';  end
    if isempty(fpath),  fpath = pwd;    end
    filepath = fullfile(fpath, [fname fext]);

    % Get the serialized data
    import com.mathworks.mlwidgets.io.*
    streamCopier = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    baos = java.io.ByteArrayOutputStream;
    fis  = java.io.FileInputStream(filepath);
    if strcmpi(fext,'.gz')
        % Gzip variant:
        zis  = java.util.zip.GZIPInputStream(fis);
    else
        % Zip variant:
        zis  = java.util.zip.ZipInputStream(fis);

        % Note: although the ze & fileName variables are unused in the Matlab
        % ^^^^  code below, they are essential in order to read the ZIP!
        ze = zis.getNextEntry;
        fileName = char(ze.getName);  %#ok<NASGU> => 'data.dat' (virtual data file)
    end
    streamCopier.copyStream(zis,baos);
    fis.close;
    data = baos.toByteArray;  % array of Matlab int8

    % Deserialize the data back into the original Matlab data format
    % Note: the zipped data is int8 => need to convert into uint8:
    data = uint8(mod(int16(data),256))';
    data = getArrayFromByteStream(data);
