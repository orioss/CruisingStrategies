function d = calcdist(pts)
% calcdist calculates cumlative distance between positions 
%
%% Syntax
% d = calcdist(pts)
%
%% Description
% calcdist returns the cumulative distance between the given position vectors.
%
% Required Input.
% pts: nx2 matrix of position vectors as row vectors.
% 
% Output.
% d: scalar distance as the sum of the l-2 norms of the difference between consecutive vectors in 'pts'.


    % Filter out rows containing NaN and Inf
	pts = pts(all(isfinite(pts),2),:);
    
    % Get the difference vectors
    dvecs = pts(2:end,:)-pts(1:end-1,:);
    
    % Sum the L-2 norms.
    d = sum( sqrt(sum(dvecs.^2,2)) );
end