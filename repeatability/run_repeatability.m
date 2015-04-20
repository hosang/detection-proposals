function run_repeatability(index, method_idx)
  num_candidates = 1000;

  load('data/pascal_voc07_test_annotations.mat');
  images = {impos.im};
%   testset = get_small_test();
%   images = unique({testset.im});
  if nargin >= 1
    index = index(index <= numel(images));
    fprintf('running on image %s/%d\n', mat2str(index), numel(images));
    images = images(index);
  end
  clear 'testset';
  
  config = repeatability_get_config();
  methods = get_method_configs();
  if nargin >= 2
    methods = methods(method_idx);
  end
  
  % seed to milliseconds
  seed = str2double(datestr(now,'HHMMSSFFF'));
  rng(seed);
  
  for im_i = 1:numel(images)
    tic_toc_print('run repeatability image %d/%d\n', im_i, numel(images));
    fprintf('%s\n', images{im_i});
    im = imread(images{im_i});
    if size(im, 3) == 1
      im = repmat(im, [1 1 3]);
    end
    [~,orig_img_id,~] = fileparts(images{im_i});
    reference(im, orig_img_id, methods, num_candidates);
    fields = fieldnames(config);
    for field_i = 1:numel(fields)
      fprintf('running %s\n', fields{field_i});
      subtask(im, orig_img_id, config.(fields{field_i}), methods, num_candidates);
    end
  end
end


function reference(im, orig_img_id, methods, num_candidates)
  ref_im_id = [orig_img_id '_reference'];
  for method_i = 1:numel(methods)
    method = methods(method_i);
    if numel(method.repeatability_num_candidates) > 0
      t_num_candidates = method.repeatability_num_candidates;
    else
      t_num_candidates = num_candidates;
    end
    try % if the candidates are already there
      read_candidates_mat(method.repeatability_candidate_dir, ref_im_id, 5);
      continue;
    catch
    end
    fprintf('running %s\n', method.name);
    [candidates, scores] = method.extract(im, t_num_candidates);
    save_candidates_mat(method.repeatability_candidate_dir, ref_im_id, candidates, scores, [], 5);
  end
end

function subtask(im, orig_img_id, sub_config, methods, num_candidates)
  for i = 1:numel(sub_config.params)
    param = sub_config.params(i);
    transformed_im = sub_config.func(im, param);
    img_id = sprintf(sub_config.img_id, orig_img_id, i);
    
    for method_i = 1:numel(methods)
      method = methods(method_i);
      if numel(method.repeatability_num_candidates) > 0
        t_num_candidates = method.repeatability_num_candidates;
      else
        t_num_candidates = num_candidates;
      end
      try % if the candidates are already there
        read_candidates_mat(method.repeatability_candidate_dir, img_id, 5);
        continue;
      catch
      end
      fprintf('running %s\n', method.name);
      [candidates, scores] = method.extract(transformed_im, t_num_candidates);
      save_candidates_mat(method.repeatability_candidate_dir, img_id, candidates, scores, [], 5);
    end
  end
end

