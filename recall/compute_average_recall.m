function [overlap, recall, AR] = compute_average_recall(unsorted_overlaps)
  overlap = sort(unsorted_overlaps(:)', 'ascend');
  num_pos = numel(overlap);
  if max(overlap) < 1
    overlap = [0, overlap, max(overlap)+0.001];
    recall = [1, (num_pos:-1:1)/num_pos, 0];
  else
    overlap = [0, overlap];
    recall = [1, (num_pos:-1:1)/num_pos];
  end
  
  good_overlap = overlap(overlap >= 0.5);
  good_recall = recall(overlap >= 0.5);
  dx = good_overlap(2:end) - good_overlap(1:end-1);
  y = (good_recall(1:end-1) + good_recall(2:end)) / 2;
  AR = 2 * sum(dx .* y);
  
  % resample overlap/recall so the plot points are not too dense
  delta = 0.005;
  mask = false(size(overlap));
  next_overlap = delta;
  for i = 1:(numel(overlap) - 1)
    if overlap(i+1) >= next_overlap
      mask(i) = true;
      next_overlap = overlap(i) + delta;
    end
  end
  mask(1) = true;
  mask(end) = true;
  overlap = overlap(mask);
  recall = recall(mask);
end
