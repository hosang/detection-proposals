function [boxes, scores, num_candidates] = read_candidates_mat(dirname, img_id, subdirlen)
  if nargin < 3
    subdirlen = 4;
  end
  subdir = img_id(1:subdirlen);
  matfile = fullfile(dirname, subdir, sprintf('%s.mat', img_id));
  
  % default value
  num_candidates = 10000;
  
  load(matfile);
end