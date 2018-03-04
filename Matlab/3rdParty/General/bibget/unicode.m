function tX = unicode(tX, bRemoveSpace)
% unicode Replace Unicode references with actual Unicode characters
%
%   A Unicode reference has one of the following forms:
%
%    &#x....;   numerical hex reference
%    &#.....;   numerical decimal reference
%    &......;   character entity reference
%
%   The dots represent a variable-size part consisting of
%   a hex number, a decimal number or a character string.
%
%   If bRemoveSpace is true, whitespace characters before and after the
%   Unicode reference are removed. By default, bRemoveSpace is false.

% default for optional input argument
if nargin < 2
  bRemoveSpace = false;
end

% search string to find unicode character references
tSearch = '&(#?)(x?)([A-Za-z0-9]+);';

% remove whitespace option
if bRemoveSpace
  tSearch = ['\s*', tSearch, '\s*'];
end
                          
% apply search string
[cM, cT] = regexp(tX, tSearch, 'match', 'tokens');

% apply replacement
for iM = 1 : length(cM)
  tX = strrep(tX, cM{iM}, getUnicode(cT{iM}{:}));
end

% --- Subfunction ---------------------------------------------------------

function tX = getUnicode(t1, t2, t3)
% getUnicode Convert from Unicode reference to unicode character
%
%   Inputs:
%
%   t1 ... '#' or '' (i.e. numeric or character)
%   t2 ... 'x' or '' (i.e. hex or decimal)
%   t3 ... string containing hex, decimal or character data
%
%   Output:
%
%   tX ... actual Unicode character or empty

if isempty(t1)
  % character entity reference
  tX = char(hex2dec(ref2hex(t3)));
elseif isempty(t2)
  % numeric hex reference
  tX = char(str2double(t3));
else
  % numeric decimal reference
  tX = char(hex2dec(t3));
end

% --- Subfunction ---------------------------------------------------------

function tX = ref2hex(tX)
% ref2hex Convert from character entity name to numeric hex string
%
%   The following switch statement translates from a character entity name
%   as defined in HTML 4 to its corresponding Unicode point in hex.
%
%   If the input is not a valid character entity name, an empty string is
%   returned and a warning message is displayed.

switch(tX)
  case 'quot'
    tX = '0022';
  case 'amp'
    tX = '0026';
  case 'apos'
    tX = '0027';
  case 'lt'
    tX = '003C';
  case 'gt'
    tX = '003E';
  case 'nbsp'
    tX = '00A0';
  case 'iexcl'
    tX = '00A1';
  case 'cent'
    tX = '00A2';
  case 'pound'
    tX = '00A3';
  case 'curren'
    tX = '00A4';
  case 'yen'
    tX = '00A5';
  case 'brvbar'
    tX = '00A6';
  case 'sect'
    tX = '00A7';
  case 'uml'
    tX = '00A8';
  case 'copy'
    tX = '00A9';
  case 'ordf'
    tX = '00AA';
  case 'laquo'
    tX = '00AB';
  case 'not'
    tX = '00AC';
  case 'shy'
    tX = '00AD';
  case 'reg'
    tX = '00AE';
  case 'macr'
    tX = '00AF';
  case 'deg'
    tX = '00B0';
  case 'plusmn'
    tX = '00B1';
  case 'sup2'
    tX = '00B2';
  case 'sup3'
    tX = '00B3';
  case 'acute'
    tX = '00B4';
  case 'micro'
    tX = '00B5';
  case 'para'
    tX = '00B6';
  case 'middot'
    tX = '00B7';
  case 'cedil'
    tX = '00B8';
  case 'sup1'
    tX = '00B9';
  case 'ordm'
    tX = '00BA';
  case 'raquo'
    tX = '00BB';
  case 'frac14'
    tX = '00BC';
  case 'frac12'
    tX = '00BD';
  case 'frac34'
    tX = '00BE';
  case 'iquest'
    tX = '00BF';
  case 'Agrave'
    tX = '00C0';
  case 'Aacute'
    tX = '00C1';
  case 'Acirc'
    tX = '00C2';
  case 'Atilde'
    tX = '00C3';
  case 'Auml'
    tX = '00C4';
  case 'Aring'
    tX = '00C5';
  case 'AElig'
    tX = '00C6';
  case 'Ccedil'
    tX = '00C7';
  case 'Egrave'
    tX = '00C8';
  case 'Eacute'
    tX = '00C9';
  case 'Ecirc'
    tX = '00CA';
  case 'Euml'
    tX = '00CB';
  case 'Igrave'
    tX = '00CC';
  case 'Iacute'
    tX = '00CD';
  case 'Icirc'
    tX = '00CE';
  case 'Iuml'
    tX = '00CF';
  case 'ETH'
    tX = '00D0';
  case 'Ntilde'
    tX = '00D1';
  case 'Ograve'
    tX = '00D2';
  case 'Oacute'
    tX = '00D3';
  case 'Ocirc'
    tX = '00D4';
  case 'Otilde'
    tX = '00D5';
  case 'Ouml'
    tX = '00D6';
  case 'times'
    tX = '00D7';
  case 'Oslash'
    tX = '00D8';
  case 'Ugrave'
    tX = '00D9';
  case 'Uacute'
    tX = '00DA';
  case 'Ucirc'
    tX = '00DB';
  case 'Uuml'
    tX = '00DC';
  case 'Yacute'
    tX = '00DD';
  case 'THORN'
    tX = '00DE';
  case 'szlig'
    tX = '00DF';
  case 'agrave'
    tX = '00E0';
  case 'aacute'
    tX = '00E1';
  case 'acirc'
    tX = '00E2';
  case 'atilde'
    tX = '00E3';
  case 'auml'
    tX = '00E4';
  case 'aring'
    tX = '00E5';
  case 'aelig'
    tX = '00E6';
  case 'ccedil'
    tX = '00E7';
  case 'egrave'
    tX = '00E8';
  case 'eacute'
    tX = '00E9';
  case 'ecirc'
    tX = '00EA';
  case 'euml'
    tX = '00EB';
  case 'igrave'
    tX = '00EC';
  case 'iacute'
    tX = '00ED';
  case 'icirc'
    tX = '00EE';
  case 'iuml'
    tX = '00EF';
  case 'eth'
    tX = '00F0';
  case 'ntilde'
    tX = '00F1';
  case 'ograve'
    tX = '00F2';
  case 'oacute'
    tX = '00F3';
  case 'ocirc'
    tX = '00F4';
  case 'otilde'
    tX = '00F5';
  case 'ouml'
    tX = '00F6';
  case 'divide'
    tX = '00F7';
  case 'oslash'
    tX = '00F8';
  case 'ugrave'
    tX = '00F9';
  case 'uacute'
    tX = '00FA';
  case 'ucirc'
    tX = '00FB';
  case 'uuml'
    tX = '00FC';
  case 'yacute'
    tX = '00FD';
  case 'thorn'
    tX = '00FE';
  case 'yuml'
    tX = '00FF';
  case 'OElig'
    tX = '0152';
  case 'oelig'
    tX = '0153';
  case 'Scaron'
    tX = '0160';
  case 'scaron'
    tX = '0161';
  case 'Yuml'
    tX = '0178';
  case 'fnof'
    tX = '0192';
  case 'circ'
    tX = '02C6';
  case 'tilde'
    tX = '02DC';
  case 'Alpha'
    tX = '0391';
  case 'Beta'
    tX = '0392';
  case 'Gamma'
    tX = '0393';
  case 'Delta'
    tX = '0394';
  case 'Epsilon'
    tX = '0395';
  case 'Zeta'
    tX = '0396';
  case 'Eta'
    tX = '0397';
  case 'Theta'
    tX = '0398';
  case 'Iota'
    tX = '0399';
  case 'Kappa'
    tX = '039A';
  case 'Lambda'
    tX = '039B';
  case 'Mu'
    tX = '039C';
  case 'Nu'
    tX = '039D';
  case 'Xi'
    tX = '039E';
  case 'Omicron'
    tX = '039F';
  case 'Pi'
    tX = '03A0';
  case 'Rho'
    tX = '03A1';
  case 'Sigma'
    tX = '03A3';
  case 'Tau'
    tX = '03A4';
  case 'Upsilon'
    tX = '03A5';
  case 'Phi'
    tX = '03A6';
  case 'Chi'
    tX = '03A7';
  case 'Psi'
    tX = '03A8';
  case 'Omega'
    tX = '03A9';
  case 'alpha'
    tX = '03B1';
  case 'beta'
    tX = '03B2';
  case 'gamma'
    tX = '03B3';
  case 'delta'
    tX = '03B4';
  case 'epsilon'
    tX = '03B5';
  case 'zeta'
    tX = '03B6';
  case 'eta'
    tX = '03B7';
  case 'theta'
    tX = '03B8';
  case 'iota'
    tX = '03B9';
  case 'kappa'
    tX = '03BA';
  case 'lambda'
    tX = '03BB';
  case 'mu'
    tX = '03BC';
  case 'nu'
    tX = '03BD';
  case 'xi'
    tX = '03BE';
  case 'omicron'
    tX = '03BF';
  case 'pi'
    tX = '03C0';
  case 'rho'
    tX = '03C1';
  case 'sigmaf'
    tX = '03C2';
  case 'sigma'
    tX = '03C3';
  case 'tau'
    tX = '03C4';
  case 'upsilon'
    tX = '03C5';
  case 'phi'
    tX = '03C6';
  case 'chi'
    tX = '03C7';
  case 'psi'
    tX = '03C8';
  case 'omega'
    tX = '03C9';
  case 'thetasym'
    tX = '03D1';
  case 'upsih'
    tX = '03D2';
  case 'piv'
    tX = '03D6';
  case 'ensp'
    tX = '2002';
  case 'emsp'
    tX = '2003';
  case 'thinsp'
    tX = '2009';
  case 'zwnj'
    tX = '200C';
  case 'zwj'
    tX = '200D';
  case 'lrm'
    tX = '200E';
  case 'rlm'
    tX = '200F';
  case 'ndash'
    tX = '2013';
  case 'mdash'
    tX = '2014';
  case 'lsquo'
    tX = '2018';
  case 'rsquo'
    tX = '2019';
  case 'sbquo'
    tX = '201A';
  case 'ldquo'
    tX = '201C';
  case 'rdquo'
    tX = '201D';
  case 'bdquo'
    tX = '201E';
  case 'dagger'
    tX = '2020';
  case 'Dagger'
    tX = '2021';
  case 'bull'
    tX = '2022';
  case 'hellip'
    tX = '2026';
  case 'permil'
    tX = '2030';
  case 'prime'
    tX = '2032';
  case 'Prime'
    tX = '2033';
  case 'lsaquo'
    tX = '2039';
  case 'rsaquo'
    tX = '203A';
  case 'oline'
    tX = '203E';
  case 'frasl'
    tX = '2044';
  case 'euro'
    tX = '20AC';
  case 'image'
    tX = '2111';
  case 'weierp'
    tX = '2118';
  case 'real'
    tX = '211C';
  case 'trade'
    tX = '2122';
  case 'alefsym'
    tX = '2135';
  case 'larr'
    tX = '2190';
  case 'uarr'
    tX = '2191';
  case 'rarr'
    tX = '2192';
  case 'darr'
    tX = '2193';
  case 'harr'
    tX = '2194';
  case 'crarr'
    tX = '21B5';
  case 'lArr'
    tX = '21D0';
  case 'uArr'
    tX = '21D1';
  case 'rArr'
    tX = '21D2';
  case 'dArr'
    tX = '21D3';
  case 'hArr'
    tX = '21D4';
  case 'forall'
    tX = '2200';
  case 'part'
    tX = '2202';
  case 'exist'
    tX = '2203';
  case 'empty'
    tX = '8960';
  case 'nabla'
    tX = '2207';
  case 'isin'
    tX = '2208';
  case 'notin'
    tX = '2209';
  case 'ni'
    tX = '220B';
  case 'prod'
    tX = '220F';
  case 'sum'
    tX = '2211';
  case 'minus'
    tX = '2212';
  case 'lowast'
    tX = '2217';
  case 'radic'
    tX = '221A';
  case 'prop'
    tX = '221D';
  case 'infin'
    tX = '221E';
  case 'ang'
    tX = '2220';
  case 'and'
    tX = '2227';
  case 'or'
    tX = '2228';
  case 'cap'
    tX = '2229';
  case 'cup'
    tX = '222A';
  case 'int'
    tX = '222B';
  case 'there4'
    tX = '2234';
  case 'sim'
    tX = '223C';
  case 'cong'
    tX = '2245';
  case 'asymp'
    tX = '2248';
  case 'ne'
    tX = '2260';
  case 'equiv'
    tX = '2261';
  case 'le'
    tX = '2264';
  case 'ge'
    tX = '2265';
  case 'sub'
    tX = '2282';
  case 'sup'
    tX = '2283';
  case 'nsub'
    tX = '2284';
  case 'sube'
    tX = '2286';
  case 'supe'
    tX = '2287';
  case 'oplus'
    tX = '2295';
  case 'otimes'
    tX = '2297';
  case 'perp'
    tX = '22A5';
  case 'sdot'
    tX = '22C5';
  case 'lceil'
    tX = '2308';
  case 'rceil'
    tX = '2309';
  case 'lfloor'
    tX = '230A';
  case 'rfloor'
    tX = '230B';
  case 'lang'
    tX = '2329';
  case 'rang'
    tX = '232A';
  case 'loz'
    tX = '25CA';
  case 'spades'
    tX = '2660';
  case 'clubs'
    tX = '2663';
  case 'hearts'
    tX = '2665';
  case 'diams'
    tX = '2666';
  otherwise
    warning('Removed unknown unicode character entity "%s".', tX);
    tX = '';     
end
