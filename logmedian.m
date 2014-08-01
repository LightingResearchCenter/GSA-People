function average = logmedian(data)
%LOGMEDIAN Transform data to log space take the median and untransform
%   data is a vector of real numbers

data(data<0.01) = 0.01;
logData = log(data);
averageLog = median(logData);
average = exp(averageLog);

end

