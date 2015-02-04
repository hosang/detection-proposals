function [proposals, scores] = run_rigor(im, num_candidates)

  if ~isdeployed
    old_path = path;
      
    addpath('/path/to/rigor');
  end
  
  
  interp_data = load('/path/to/rigor_num_candidates_interpolation_data.mat');
  if num_candidates <= min(interp_data.num_candidates)
    num_seeds = 1;
  elseif num_candidates >= max(interp_data.num_candidates)
    num_seeds = 1024;
  else
    num_seeds = interp1(interp_data.num_candidates, interp_data.all_num_seeds, num_candidates);
    assert(~isnan(opts.gc_branches));
  end
  
  [masks, seg_obj, total_time] = rigor_obj_segments(im, num_seeds, 'io', true, 'force_recompute', true);
  scores = [];
  proposals = masks_to_boxes(masks);
  proposals = unique(proposals, 'rows');

  if ~isdeployed
    path(old_path);
  end
  
end


function [boxes] = masks_to_boxes(masks)
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
end
