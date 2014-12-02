function [ average ] = nonzerogeomean( data )
%NONZEROGEOMEAN Summary of this function goes here
%   Detailed explanation goes here
nonZeroIdx = data > 0.01;
nonZeroData = data(nonZeroIdx);
average = geomean(nonZeroData);

end

