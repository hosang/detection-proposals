function [candidates, scores] = run_endres(im, num_candidates)
  if ~isdeployed
    old_path = path;
    addpath(genpath('/path/to/Endres/PROP/proposals'));
  end
  
  [proposals, superpixels] = generate_proposals(im);
  candidates = masks_to_boxes(proposals, superpixels);
  scores = [];
  
  if ~isdeployed
    path(old_path);
  end
end


function boxes = masks_to_boxes(proposals, superpixels)
  n = numel(proposals);
  boxes = zeros(n, 4);
  for i = 1:n
    mask = ismember(superpixels, proposals{i});
    [ys, xs] = find(mask);
    boxes(i,:) = [min(xs), min(ys), max(xs), max(ys)];
  end
end
