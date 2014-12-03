function [candidates, scores] = run_cpmc(im, num_candidates)
  [ret_code, exp_dir] = system('mktemp -d');
  assert(ret_code == 0);
  exp_dir = [strtrim(exp_dir) '/'];
  
  mkdir(exp_dir, 'PB');
  mkdir(exp_dir, 'WindowsOfInterest/grid_sampler');
  mkdir(exp_dir, 'MySegmentRankers');
  copyfile('/path/to/cpmc_release1/data/MySegmentRankers/attention_model_fewfeats_lambda_10.00_train*.mat', fullfile(exp_dir, 'MySegmentRankers'));
  mkdir(exp_dir, 'MyCodebooks');
  copyfile('/path/to/cpmc_release1/data/MyCodebooks/*.mat', fullfile(exp_dir, 'MyCodebooks'));
  
  fprintf('created %s\n', exp_dir);
  img_name = 'foo';
  img_folder = [exp_dir 'JPEGImages/'];
  mkdir(img_folder);
  img_filename = [img_folder img_name '.jpg'];
  imwrite(im, img_filename);
  fprintf('wrote %s\n', img_filename);
  
  if ~isdeployed
    old_path = path;
    addpath('../cpmc_release1/');
    addpath('../cpmc_release1/code/');
    addpath('../cpmc_release1/external_code/');
    addpath('../cpmc_release1/external_code/paraFmex/');
    addpath('../cpmc_release1/external_code/imrender/vgg/');
    addpath('../cpmc_release1/external_code/immerge/');
    addpath('../cpmc_release1/external_code/color_sift/');
    addpath('../cpmc_release1/external_code/vlfeats/toolbox/kmeans/');
    addpath('../cpmc_release1/external_code/vlfeats/toolbox/kmeans/');
    addpath('../cpmc_release1/external_code/vlfeats/toolbox/mex/mexa64/');
    addpath('../cpmc_release1/external_code/vlfeats/toolbox/mex/mexglx/');
    addpath('../cpmc_release1/external_code/globalPb/lib/');
    addpath('../cpmc_release1/external_code/mpi-chi2-v1_5/');        
  end
  
  [masks, scores] = cpmc(exp_dir, img_name);
  [candidates, scores] = masks_to_boxes(masks, scores);
  
  system(sprintf('rm -rf "%s"', exp_dir));
  fprintf('cleaned up %s\n', exp_dir);
  if ~isdeployed
    path(old_path);
  end
end


function [boxes, scores] = masks_to_boxes(masks, scores)
  n = size(masks, 3);
  boxes = zeros(n, 4);
  for i = 1:n
    [ys, xs] = find(masks(:,:,i));
    if isempty(ys) || isempty(xs) || any(isnan(xs)) || any(isnan(ys))
        boxes(i,:) = [0 0 0 0];
    else
        boxes(i,:) = [min(xs), min(ys), max(xs), max(ys)];
    end
  end
  invalid = all(boxes == 0, 2);
  fprintf('%d invalid, %d left\n', sum(invalid), sum(~invalid));
  boxes = boxes(~invalid,:);
  scores = scores(~invalid,:);
end
