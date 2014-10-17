function [millerTimeArray_days,millerDataArray] = millerize2(timeArray_seconds,dataArray)
%MILLERIZE Summary of this function goes here
%   Detailed explanation goes here

relTimeArray_seconds = round(timeArray_seconds/180)*180; % precise to 3 minutes

millerTimeArray_seconds = unique(relTimeArray_seconds);

nPoints = numel(millerTimeArray_seconds);

millerDataArray = zeros(nPoints,1);

for i1 = 1:nPoints
    idx = relTimeArray_seconds == millerTimeArray_seconds(i1);
    millerDataArray(i1) = mean(dataArray(idx));
end

millerTimeArray_days = millerTimeArray_seconds/(60*60*24);

end

