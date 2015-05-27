function [boxes, scores, num_candidates] = read_candidates_mat(dirname, img_id, subdirlen, coco)
  if nargin < 3
    subdirlen = 4;
  end
  if nargin < 4
    coco = false;
  end
  
  if coco
    subdirlen1 = 14;
    subdir1 = img_id(1:subdirlen1);
    subdirlen2 = 22;
    subdir2 = img_id(1:subdirlen2);
    subdir = fullfile(subdir1, subdir2);
  else
    subdir = img_id(1:subdirlen);
  end
  matfile = fullfile(dirname, subdir, sprintf('%s.mat', img_id));
  
  % default value
  num_candidates = 10000;
  
  load(matfile);
end