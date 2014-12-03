function [proposals, scores] = run_randomized_prims(im, num_proposals, seed)
  if ~isdeployed
    old_path = path;
    addpath(fullfile('..', 'randomized_prims'));
    addpath(fullfile('..', 'randomized_prims', 'cmex'));
    addpath(fullfile('..', 'randomized_prims', 'matlab'));
  end
  
  if nargin < 3
    % seed to milliseconds
    seed = str2double(datestr(now,'HHMMSSFFF'));
  end
  
  configFile = '/path/to/randomized_prims/config/rp_4segs.mat'; 
  configParams = load(configFile);
  configParams = configParams.params;
  configParams.approxFinalNBoxes = num_proposals;
  configParams.q = 1;
  configParams.rSeedForRun = seed;
  proposals = RP(im, configParams);
  scores = [];
  
  if ~isdeployed
    path(old_path);
  end
end
