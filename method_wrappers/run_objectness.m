function [candidates, score] = run_objectness(im, num_boxes)
  struct = load('/path/to/objectness-release-v2.2/Data/params.mat');
  params = struct.params;
  clear 'struct';
  if ~isdeployed
    old_path = path;
    old_pwd = pwd;
  
    cd('/path/to/objectness-release-v2.2');
    startup;
  else
  end

  candidates = runObjectness(im, num_boxes, params);
  score = candidates(:,5);
  candidates = round(candidates(:,1:4));
  
  if ~isdeployed
    cd(old_pwd);
    path(old_path);
  end
end
