function repeatability_matching(index, method_idx)
% Computes the matching between proposals on the repeatability set.

  num_candidates = 1000;
  
  load('voc07/cache/all_with_imsize_test.mat');
  images = {impos.im};
  if nargin >= 1
    fprintf('running on image %s/%d\n', mat2str(index), numel(images));
    images = images(index);
  end
  
  config = repeatability_get_config();
  methods = get_method_configs();
  methods = methods(method_idx);
  
  run_matching(images, config, methods, num_candidates);
end

function [matchings] = run_matching(images, config, methods, num_candidates)
  fields = fieldnames(config);
  num_methods = numel(methods);
  matchings = cell(num_methods, 1);
  % preallocate
  for method_i = 1:num_methods
    for field_i = 1:numel(fields)
      matchings{method_i}.matchings(numel(images)).(fields{field_i}) = [];
    end
  end
  
  for im_i = 1:numel(images)
    tic_toc_print('run matching image %d/%d\n', im_i, numel(images));
    im = imread(images{im_i});
    if size(im, 3) == 1
      im = repmat(im, [1 1 3]);
    end
    [~,orig_img_id,~] = fileparts(images{im_i});
    subdir = orig_img_id(1:5);
    for method_i = 1:num_methods
      fprintf('method: %s\n', methods(method_i).name);
      
      for field_i = 1:numel(fields)
        fprintf('task: %s\n', fields{field_i});
      
        if numel(matchings{method_i}.matchings(im_i).(fields{field_i})) ~= numel(config.(fields{field_i}).params)
          t_matchings = ...
            matching_subtask(im, orig_img_id, config.(fields{field_i}), ...
            methods(method_i), num_candidates);
          matchings{method_i}.matchings(im_i).(fields{field_i}) = t_matchings(1,:);
        end
      end
      
      matfile = fullfile(methods(method_i).repeatability_candidate_dir, ...
        subdir, sprintf('%s_matchings.mat', orig_img_id));
      fprintf('writing %s\n', matfile);
      matching = matchings{method_i}.matchings(im_i);
      save(matfile, 'matching');
    end

  end
%   for im_i = 1:numel(images)
%     tic_toc_print('run matching image %d/%d\n', im_i, numel(images));
%     im = imread(images{im_i});
%     if size(im, 3) == 1
%       im = repmat(im, [1 1 3]);
%     end
%     [~,orig_img_id,~] = fileparts(images{im_i});
%     fields = fieldnames(config);
%     for field_i = 1:numel(fields)
%       t_matchings = ...
%         matching_subtask(im, orig_img_id, config.(fields{field_i}), methods, num_candidates);
%       for method_i = 1:num_methods
%         matchings{method_i}.matchings(im_i).(fields{field_i}) = t_matchings(method_i,:);
%       end
%     end
%   end
end

function [matchings] = matching_subtask(orig_im, orig_img_id, sub_config, methods, num_candidates)
  if ~isfield(sub_config, 'ref_params_idx') || isempty(sub_config.ref_params_idx)
    ref_img_id = [orig_img_id '_reference'];
    ref_im = orig_im;
  else
    ref_img_id = sprintf(sub_config.img_id, orig_img_id, sub_config.ref_params_idx);
    ref_im = sub_config.func(orig_im, sub_config.ref_params);
  end

  num_parameters = numel(sub_config.params);
  num_methods = numel(methods);
  
  matchings = [];
  matchings(num_methods, num_parameters).iou = [];
  matchings(num_methods, num_parameters).reference_boxes = [];
  matchings(num_methods, num_parameters).matched_boxes = [];
  matchings(num_methods, num_parameters).im_size = [];
  matchings(num_methods, num_parameters).ref_im_size = [];
  
  ref_im_size = [size(ref_im, 2), size(ref_im, 1)];
  for method_i = 1:num_methods
    method = methods(method_i);
    
    for param_i = 1:num_parameters
      param = sub_config.params(param_i);
      img_id = sprintf(sub_config.img_id, orig_img_id, param_i);
      [im,H] = sub_config.func(orig_im, param);
      Hinv = inv(H);
      im_size = [size(im, 2), size(im, 1)];
    
      [candidates] = get_candidates(method, img_id, num_candidates, true, 5, method.repeatability_candidate_dir);
%       [candidates] = read_candidates_mat(method.repeatability_candidate_dir, img_id, 5);
%       assert(size(candidates, 1) <= num_candidates);
      ref_candidates = get_candidates(method, ref_img_id, num_candidates, true, 5, method.repeatability_candidate_dir);
%       [ref_candidates] = read_candidates_mat(method.repeatability_candidate_dir, ref_img_id, 5);
%       assert(size(ref_candidates, 1) <= num_candidates);
      
      if isempty(candidates) || isempty(ref_candidates)
        best_iou_per_cand = [];
        matched_candidates = [];
      else
        proj_candidates = project_candidates(candidates, Hinv);
        proj_ref_candidates = project_candidates(ref_candidates, H);

        proj_candidates_centers = [mean(proj_candidates(:,[1 3]), 2), mean(proj_candidates(:,[2 4]), 2)];
        orig_valid = (proj_candidates_centers(:,1) >= 1) & (proj_candidates_centers(:,2) >= 1) ...
          & (proj_candidates_centers(:,1) <= ref_im_size(1)) & (proj_candidates_centers(:,2) <= ref_im_size(2));
        proj_ref_candidates_centers = [mean(proj_ref_candidates(:,[1 3]), 2), mean(proj_ref_candidates(:,[2 4]), 2)];
        ref_valid = (proj_ref_candidates_centers(:,1) >= 1) & (proj_ref_candidates_centers(:,2) >= 1) ...
          & (proj_ref_candidates_centers(:,1) <= im_size(1)) & (proj_ref_candidates_centers(:,2) <= im_size(2));

        fprintf('filtered out (transformed/reference): %d/%d, left %d/%d\n', ...
          sum(~[orig_valid]), sum(~[ref_valid]), sum(orig_valid), sum(ref_valid));
        proj_candidates = proj_candidates(orig_valid,:);
        ref_candidates = ref_candidates(ref_valid,:);
        
        [best_iou_per_cand, matched_candidates] = closest_candidates(ref_candidates, proj_candidates);
      end
      
      matchings(method_i, param_i).iou = best_iou_per_cand;
      matchings(method_i, param_i).reference_boxes = ref_candidates;
      matchings(method_i, param_i).matched_boxes = matched_candidates;
      matchings(method_i, param_i).ref_im_size = ref_im_size;
      matchings(method_i, param_i).im_size = im_size;
    end
  end
end

