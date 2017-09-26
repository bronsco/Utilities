function Vpred = interpns(V,Xi,nodelist,method)
% interpne: Interpolates an array using simplicial interpolation
% usage: Vpred = interpns(V,Xi)
% usage: Vpred = interpns(V,Xi,nodelist)
%
% Note: Interpolates using a simplicial dissection of the n-d hyper-rectangle
% into factorial(n) simplexes. This is sometimes known as the diagonal
% extraction, where all simplexes share one edge along a main diagonal of
% the hyper-rectangle.
%
% Note: interpns does NOT perform extrapolation. For that behavior,
% you will need to use a tool like interpne.
%
% arguments: (input)
%  V - p-dimensional array to be interpolated/extrapolated at the list
%      of points in the array Xi.
%
%      Note: interpne will work in any number of dimensions >= 1
%
%  Xi - (n by p) array of n points to interpolate/extrapolate. Each
%      point is one row of the array Xi.
%
%  nodelist - (OPTIONAL) cell array of nodes in each dimension.
%      If nodelist is not provided, then by default I will assume:
%
%      nodelist{i} = 1:size(V,i)
%
%      The nodes in nodelist need not be uniformly spaced.
%
%
% arguments: (output)
%  Vpred - n by 1 array of interpolated/extrapolated values
%
%
% Example 1: 2d case
%  [x1,x2] = meshgrid(0:.2:1);
%  z = exp(x1+x2);
%  Xi = rand(1000,2);
%  Zi = interpns(z,Xi,{0:.2:1, 0:.2:1});
%  surf(0:.2:1,0:.2:1,z)
%  hold on
%  plot3(Xi(:,1),Xi(:,2),Zi,'r.')
%
%
% My apology: this interface is not fully compatible with that of
% interpn. But in higher dimensions, the interpn interface is both
% a mess to use and to write.
%
%
% See also: interp1, interp2, interpne, interpn
%
% Author: John D'Errico
% e-mail address: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 3/31/2011

% get some sizes
vsize = size(V);
ndims = length(vsize);
[n,p] = size(Xi);
if ndims~=p
  error 'Xi is not compatible in size with the array V for interpolation.'
end

% default for nodelist
if (nargin<2) || isempty(nodelist)
  nodelist = cell(1,ndims);
  for i=1:ndims
    nodelist{i} = (1:vsize(i))';
  end
end
if length(nodelist)~=ndims
  error 'nodelist is incompatible with the size of V.'
end
nll = cellfun('length',nodelist);
if any(nll~=vsize)
  error 'nodelist is incompatible with the size of V.'
end

% get deltax for the node spacing
dx = nodelist;
for i=1:ndims
  nodelist{i} = nodelist{i}(:);
  dx{i} = diff(nodelist{i});
  if any(dx{i}<=0)
    error 'The nodes in nodelist must be monotone increasing.'
  end
end

% Which cell of the array does each point lie in?
% This includes extrapolated points, which are also taken
% to fall in a cell. histc will do all the real work.
ind = zeros(n,ndims);
for i = 1:ndims
  [junk,bin] = histc(Xi(:,i),nodelist{i});
  
  % catch any point along the very top edge.
  bin(bin==vsize(i)) = vsize(i) - 1;
  ind(:,i) = bin;
  k = find(bin==0);
  
  % look for any points external to the nodes
  if ~isempty(k)
    % bottom end
    ind(k(Xi(k,i)<nodelist{i}(1)),i) = 1;
    
    % top end
    ind(k(Xi(k,i)>nodelist{i}(end)),i) = vsize(i) - 1;
  end
end  % for i = 1:ndims

% where in each cell does each point fall?
t = zeros(n,ndims);
for i = 1:ndims
  t(:,i) = (Xi(:,i) - nodelist{i}(ind(:,i)))./dx{i}(ind(:,i));
end
sub = cumprod([1,vsize(1:(end-1))])';
base = 1+(ind-1)*sub;

% first, we need to form a triangulation of the hypercube
% list of vertices of the cube itself
vertices = dec2bin(0:(2^ndims-1))- '0';

% for each vertex of the hypercube, compute an offset in
% the grid of the n-d lattice of V.
offsets = vertices*sub;

% permutations of 1:ndims. Each permutation corresponds to
% a simplex in the dissection.
pn = perms(1:ndims);

% the number of simplexes. it should be factorial(ndims)
ns = size(pn,1);
tessellation = zeros(ns,ndims+1);
for i=1:ns
  tessellation(i,:) = find(all(diff(vertices(:,pn(i,:)),[],2)>=0,2))';
end

% do the interpolation, using tsearchn to compute the
% barycentric coordinates, relative to the cell the point
% is known to lie in.
[tri,bary] = tsearchn(vertices,tessellation,t);

% The interpolation itself is easy. Just an exercise in
% indirect indexing.
Vpred = zeros(n,1);
for i = 1:(ndims + 1)
  Vpred = Vpred + bary(:,i).*V(base + offsets(tessellation(tri,i)));
end





