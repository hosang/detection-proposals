function [candidates, score] = run_bing(im, num_candidates)
  bing_path = '/path/to/bing.sh';
  model_prefix = '/path/to/BING-Objectness/VOC2007/Results/ObjNessB2W8MAXBGR';
  
  [ret_code, tmp_dir] = system('mktemp -d');
  assert(ret_code == 0);
  tmp_dir = strtrim(tmp_dir);
  fprintf('created %s\n', tmp_dir);
  
  img_filename = fullfile(tmp_dir, 'foo.png');
  imwrite(im, img_filename);
  
  candidates_file = fullfile(tmp_dir, 'candidates.txt');
  
  cmd = sprintf('%s -i %s -o %s -m %s -d %d', ...
    bing_path, img_filename, candidates_file, model_prefix, num_candidates);
  [ret_code] = system(cmd);
  assert(ret_code == 0);
  
  [score, x1, y1, x2, y2] = textread(candidates_file, '%f %d %d %d %d', 'headerlines', 1);
  candidates = [x1 y1 x2 y2];
  
  system(sprintf('rm -rf "%s"', tmp_dir));
end
