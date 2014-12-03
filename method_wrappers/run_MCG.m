function [candidates, score] = run_MCG(im, num_candidates)

  if ~isdeployed
    old_path = path;
    
    root_dir = '../MCG-PreTrained';
    addpath(root_dir);
    addpath(fullfile(root_dir,'lib'));
    addpath(fullfile(root_dir,'scripts'));
    addpath(fullfile(root_dir,'datasets'));
    addpath(genpath(fullfile(root_dir,'src')));
  end

  tic;
  try
    % Test the 'accurate' version, which tackes around 30 seconds in mean
    [candidates_mcg, ~] = im2mcg(im,'accurate');
    candidates = flip_xy(candidates_mcg.bboxes);
    score = candidates_mcg.scores;
  
  catch err
    if (strcmp(err.identifier,'MATLAB:badsubscript'))
      fprintf('MCG didn''t work properly (no proper segmentation?)\n');
      candidates = [];
      score = [];
    else
      rethrow(err);
    end

  end
  toc;

  if ~isdeployed
    path(old_path);
  end
end

function [boxes2] = flip_xy(boxes)
    boxes2 = zeros(size(boxes));
    boxes2(:,1) = boxes(:,2);
    boxes2(:,2) = boxes(:,1);
    boxes2(:,3) = boxes(:,4);
    boxes2(:,4) = boxes(:,3);
end
