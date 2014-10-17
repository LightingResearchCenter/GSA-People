function [millerTimeArray_seconds,millerDataArray] = millerize(timeArray,dataArray)
%MILLERIZE Summary of this function goes here
%   Detailed explanation goes here

relTimeArray_days = mod(timeArray-floor(timeArray(1)),1);

relTimeArray_seconds = round(relTimeArray_days*24*60*60/30)*30; % precise to 30 seconds

millerTimeArray_seconds = unique(relTimeArray_seconds);

nPoints = numel(millerTimeArray_seconds);

millerDataArray = zeros(nPoints,1);

for i1 = 1:nPoints
    idx = relTimeArray_seconds == millerTimeArray_seconds(i1);
    millerDataArray(i1) = mean(dataArray(idx));
end


end

