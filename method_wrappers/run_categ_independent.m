function [candidates, scores] = run_categ_independent(im, num_candidates)
  if ~isdeployed
    old_path = path;
    old_pwd = pwd;
    cd(fullfile('..', 'category_independen_detection'));
  end
  
  [candidates, scores] = mvg_runObjectDetection(im, num_candidates);

  if ~isdeployed
    cd(old_pwd);
    path(old_path);
  end
end

