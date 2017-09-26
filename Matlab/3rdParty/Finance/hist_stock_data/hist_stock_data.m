function stocks = hist_stock_data(start_date, end_date, varargin)
% HIST_STOCK_DATA     Obtain historical stock data
%   hist_stock_data(X,Y,'Ticker1','Ticker2',...) retrieves historical stock
%   data for the ticker symbols Ticker1, Ticker2, etc... between the dates
%   specified by X and Y.  X and Y are strings in the format ddmmyyyy,
%   where X is the beginning date and Y is the ending date.  The program
%   returns the stock data in a structure giving the Date, Open, High, Low,
%   Close, Volume, and Adjusted Close price adjusted for dividends and
%   splits.
%
%   hist_stock_data(X,Y,'tickers.txt') retrieves historical stock data
%   using the ticker symbols found in the user-defined text file.  Ticker
%   symbols must be separated by line feeds.
%
%   EXAMPLES
%       stocks = hist_stock_data('23012003','15042008','GOOG','C');
%           Returns the structure array 'stocks' that holds historical
%           stock data for Google and CitiBank for dates from January
%           23, 2003 to April 15, 2008.
%
%       stocks = hist_stock_data('12101997','18092001','tickers.txt');
%           Returns the structure arrary 'stocks' which holds historical
%           stock data for the ticker symbols listed in the text file
%           'tickers.txt' for dates from October 12, 1997 to September 18,
%           2001.  The text file must be a column of ticker symbols
%           separated by new lines.
%
%       stocks = hist_stock_data('12101997','18092001','C','frequency','w')
%           Returns historical stock data for Citibank using the date range
%           specified with a frequency of weeks.  Possible values for
%           frequency are d (daily), wk (weekly), or mo (monthly).  If not
%           specified, the default frequency is daily.
%
%   DATA STRUCTURE
%       INPUT           DATA STRUCTURE      FORMAT
%       X (start date)  ddmmyyyy            String
%       Y (end date)    ddmmyyyy            String
%       Ticker          NA                  String 
%       ticker.txt      NA                  Text file
%
%   OUTPUT FORMAT
%       All data is output in the structure 'stocks'.  Each structure
%       element will contain the ticker name, then vectors consisting of
%       the organized data sorted by date, followed by the Open, High, Low,
%       Close, Volume, then Adjusted Close prices.
%
%   DATA FEED
%       The historical stock data is obtained using Yahoo! Finance website.
%       By using Yahoo! Finance, you agree not to redistribute the
%       information found therein.  Therefore, this program is for personal
%       use only, and any information that you obtain may not be
%       redistributed.
%
%   NOTE
%       This program uses the Matlab command urlread in a very basic form.
%       If the program gives you an error and does not retrieve the stock
%       information, it is most likely because there is a problem with the
%       urlread command.  You may have to tweak the code to let the program
%       connect to the internet and retrieve the data.

% Created by Josiah Renfree
% January 25, 2008

stocks = struct([]);        % initialize data structure

% Format start and end dates into Unix time
startDate = posixtime(datetime(start_date, 'InputFormat', 'ddMMyyyy'));
endDate = posixtime(datetime(end_date, 'InputFormat', 'ddMMyyyy'));

% determine if user specified frequency
temp = find(strcmp(varargin,'frequency') == 1); % search for frequency
if isempty(temp)                            % if not given
    freq = 'd';                             % default is daily
else                                        % if user supplies frequency
    freq = varargin{temp+1};                % assign to user input
    varargin(temp:temp+1) = [];             % remove from varargin
end
clear temp

% Determine if user supplied ticker symbols or a text file
if isempty(strfind(varargin{1},'.txt'))     % If individual tickers
    tickers = varargin;                     % obtain ticker symbols
else                                        % If text file supplied
    fid = fopen(varargin{1}, 'r');
    tickers = textscan(fid, '%s'); tickers = tickers{:};
    fclose(fid);
end

h = waitbar(0, 'Please Wait...');           % create waitbar
idx = 1;                                    % idx for current stock data

% Cycle through each ticker symbol and retrieve historical data
for i = 1:length(tickers)
    
    % Update waitbar to display current ticker
    waitbar((i-1)/length(tickers),h,sprintf('%s %s %s%0.2f%s', ...
        'Retrieving stock data for',tickers{i},'(',(i-1)*100/length(tickers),'%)'))
    
    % Create url string for retrieving data
    url = sprintf(['https://query1.finance.yahoo.com/v7/finance/download/', ...
        '%s?period1=%d&period2=%d&interval=1%s&events=history'], ...
        tickers{i}, startDate, endDate, freq);
    
    % Call data from Yahoo Finance
    [temp, status] = urlread(url,'post',{'matlabstockdata@yahoo.com', 'historical stocks'});
        
    % If data was downloaded successfully, then proceed to process it.
    % Otherwise, ignore this ticker symbol
    if status
        
        % Parse out the historical data
        data = textscan(temp, '%s%f%f%f%f%f%f', 'delimiter', ',', ...
            'Headerlines', 1);
        
        % Put data into appropriate variables
        [stocks(idx).Date, stocks(idx).Open, stocks(idx).High, ...
            stocks(idx).Low, stocks(idx).Close, stocks(idx).Volume, ...
            stocks(idx).AdjClose] = deal(data{:});

        stocks(idx).Ticker = tickers{i};	% Store ticker symbol
        
        idx = idx + 1;                      % Increment stock index
    end
        
    % update waitbar
    waitbar(i/length(tickers),h)
end
close(h)    % close waitbar