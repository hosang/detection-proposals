function [candidates, priority] = run_selective_search(im, num_candidates)
  if ~isdeployed
    old_path = path;
    addpath(fullfile('..', 'SelectiveSearchCodeIJCV'));
    addpath(fullfile('..', 'SelectiveSearchCodeIJCV', 'Dependencies'));
  end
  
  %
  % Parameters. Note that this controls the number of hierarchical
  % segmentations which are combined.
  colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
  % colorType = colorTypes{1}; % Single color space for demo

  % Here you specify which similarity functions to use in merging
  simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
  % simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies

  % Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
  % Note that by default, we set minSize = k, and sigma = 0.8.
  ks = [50 100 150 300]; % controls size of segments of initial segmentation. 
  sigma = 0.8;
  minBoxWidth = 20;
  
  boxesT = cell(length(ks)*length(colorTypes),1); priorityT = cell(length(ks)*length(colorTypes),1);
  idx = 1;
      for j=1:length(ks)
        k = ks(j); % Segmentation threshold k
        minSize = k; % We set minSize = k
        for n = 1:length(colorTypes)
          colorType = colorTypes{n};
          [box blobIndIm blobBoxes hierarchy priorityT{idx}] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
          boxesT{idx} = [box(:,2), box(:,1), box(:,4), box(:,3)];
          idx = idx + 1;
        end
      end

  candidates = cat(1, boxesT{:}); % Concatenate boxes from all hierarchies
  priority = cat(1, priorityT{:}); % Concatenate priorities
  % Do pseudo random sorting as in paper
  priority = priority .* rand(size(priority));
  [priority, sortIds] = sort(priority, 'ascend');
  candidates = candidates(sortIds,:);
  [candidates, filteredIdx] = FilterBoxesWidth(candidates, minBoxWidth);
  priority = priority(filteredIdx);
  [candidates, uniqueIdx] = BoxRemoveDuplicates(candidates);
  priority = priority(uniqueIdx);
  
  if size(candidates, 1) > num_candidates
    candidates = candidates(1:num_candidates,:);
    priority = priority(1:num_candidates);
  end

  if ~isdeployed
    path(old_path);
  end
end
