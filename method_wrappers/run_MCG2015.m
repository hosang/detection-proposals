function [candidates, score] = run_MCG2015(im, num_candidates)

  if ~isdeployed
    old_path = path;
    
    root_dir = '../mcg/pre-trained';
    addpath(root_dir);
    addpath(fullfile(root_dir,'lib'));
    addpath(fullfile(root_dir,'scripts'));
    addpath(fullfile(root_dir,'datasets'));
    addpath(genpath(fullfile(root_dir,'src')));
  end

  tic;
  % Test the 'accurate' version, which tackes around 30 seconds in mean
  [candidates_mcg, ~] = im2mcg(im,'accurate');
  % flip x and y coordinates
  candidates = candidates_mcg.bboxes(:,[2 1 4 3]);
  score = candidates_mcg.bboxes_scores;
  
  toc;

  if ~isdeployed
    path(old_path);
  end
end
