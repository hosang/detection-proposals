function [proposals, scores] = run_felsen_candidates(im, num_proposals, seed)
  if ~isdeployed
    old_path = path;
    addpath(fullfile('..', 'segmentation_baseline'));
    addpath(fullfile('..', 'segmentation_baseline', 'cmex'));
    addpath(fullfile('..', 'segmentation_baseline', 'matlab'));
  end
  
  if nargin < 3
    % seed to milliseconds
    seed = str2double(datestr(now,'HHMMSSFFF'));
  end
  
  configFile = '/path/to/segmentation_baseline/config/rp_4segs.mat'; 
  configParams = load(configFile);
  configParams = configParams.params;
  configParams.approxFinalNBoxes = num_proposals;
  configParams.q = 1;
  configParams.rSeedForRun = seed;
  proposals = felsen_candidates(im, configParams);
  scores = [];
  
  if ~isdeployed
    path(old_path);
  end
end
