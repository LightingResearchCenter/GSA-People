function Average = daysimeterworkaverages(csArray,illuminanceArray,activityArray)
%DAYSIMETERAVERAGES Summary of this function goes here
%   Detailed explanation goes here

% Preallocate output
Average = struct(...
    'cs'         , {[]},...
    'illuminance', {[]},...
    'medianIlluminance', {[]},...
    'activity'   , {[]});

% Average data
Average.cs          = mean(csArray);
Average.illuminance = logmean2(illuminanceArray);
Average.medianIlluminance = logmedian(illuminanceArray);
Average.activity    = mean(activityArray);

end

