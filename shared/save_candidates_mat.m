function save_candidates_mat(dirname, img_id, boxes, scores, num_candidates, subdirlen, coco)
% Save candidates to disk.

  if nargin < 5
    num_candidates = [];
  end
  if nargin < 6
    subdirlen = 4;
  end
  if nargin < 7
    coco = false;
  end
    
  if coco
    % full directories turn out to be slow
    subdirlen1 = 14;
    subdir1 = img_id(1:subdirlen1);
    subdirlen2 = 22;
    subdir2 = img_id(1:subdirlen2);
    subdir = fullfile(subdir1, subdir2);
  else
    subdir = img_id(1:subdirlen);
  end

  path = fullfile(dirname, subdir);
  if ~exist(path, 'dir')
    mkdir(path);
  end
  matfile = fullfile(dirname, subdir, sprintf('%s.mat', img_id));
  save(matfile, 'boxes', 'scores', 'num_candidates');
end
