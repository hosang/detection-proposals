
if ~isdeployed()
  proposal_root_path = fileparts(mfilename('fullpath'));
  
  addpath(fullfile(proposal_root_path, 'repeatability'));
  addpath(fullfile(proposal_root_path, 'util'));
  addpath(fullfile(proposal_root_path, 'shared'));
  addpath(fullfile(proposal_root_path, 'recall'));
end
