function savezip(filepath, dataOrVarname)
% savezip - save data in a compressed zip file
%
% savezip accepts a file name/path and variable data or name, and stores
% the data in compressed zip or gzip format in the specified file.
% If the specified filepath does not include an extension, then '.zip'
% will be used. The data can be in any Matlab data format. The data can
% be loaded back into Matlab using the corresponding loadzip function.
%
% Syntax:
%    savezip(filepath, data)
%    savezip(filepath, 'variableName')
%
% Input Parameters:
%    filepath - filename with optional path (default: current folder)
%                  and extension (default: '.zip')
%    dataOrVarname - Matlab data, or variable name in caller's workspace
%
% Output parameters:
%    none
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
%    save, load, loadzip
%
% Release history:
%    1.0 2014-08-29: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>

% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.0 $  $Date: 2014/08/29 14:51:30 $

    % Some sanity checks
    if nargin<2
        error('YMA:savezip:args','Both filepath and data must be specified as input args.');
    elseif ~ischar(filepath)
        error('YMA:savezip:filepath','First argument must be a string (file name/path).');
    end

    % Get the requested output file's full path
    [fpath,fname,fext] = fileparts(filepath);
    if isempty(fext),       fext = '.zip';  end
    if isempty(fpath),      fpath = pwd;    end
    if ~exist(fpath,'dir'), mkdir(fpath);   end  % create new folder if it does not exist
    filepath = fullfile(fpath, [fname fext]);

    % Get the data, if specified as a variable name
    if ischar(dataOrVarname)
        dataOrVarname = evalin('caller',dataOrVarname);
    end

    % Get the data size (will be used below as the original size in the ZIP file)
    originalDataSizeInBytes = getfield(whos('dataOrVarname'),'bytes');

    % Serialize the data into a 1D array of uint8 bytes
    dataInBytes = getByteStreamFromArray(dataOrVarname);

    % The serialization is uint8 but the ZIP format requires int8, so convert:
    %dataInBytes = int8(data);  % or: getByteStreamFromArray(data)

    % Compress in memory and save to the requested file in ZIP format
    fos = java.io.FileOutputStream(filepath);
    if strcmpi(fext,'.gz')
        % Gzip variant:
        zos = java.util.zip.GZIPOutputStream(fos);  % note the capitalization
    else
        % Zip variant:
        zos = java.util.zip.ZipOutputStream(fos);  % or: org.apache.tools.zip.ZipOutputStream as used by MATLAB's zip.m
        ze  = java.util.zip.ZipEntry('data.dat');  % or: org.apache.tools.zip.ZipEntry as used by MATLAB's zip.m
        ze.setSize(originalDataSizeInBytes);
        zos.setLevel(9);  % set the compression level (0=none, 9=max)
        zos.putNextEntry(ze);
    end
    zos.write(dataInBytes, 0, numel(dataInBytes));
    zos.finish;
    zos.close;
