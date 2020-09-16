function d = rba_basedir()

% d = rba_basedir()
% return directory pathname of resource-balance-analysis package

d = [fileparts(which(mfilename)) filesep '..' filesep '..' filesep '..' filesep ];
