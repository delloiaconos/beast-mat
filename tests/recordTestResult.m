function result = recordTestResult(name, status, message)
%RECORDTESTRESULT Registers a test result
%   Detailed explanation goes here
    result = struct('name', name, 'status', status, 'message', message);
end
