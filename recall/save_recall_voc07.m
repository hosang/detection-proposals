function save_recall_voc07()
  methods = get_method_configs();
  iou_files = {methods.best_voc07_candidates_file};
  n_methods = numel(iou_files);
  num_candidates = 1000;
  num_classes = 20;
  
  iou_thresholds = .5:.025:1;
  
  testset = load('data/pascal_voc07_test_annotations.mat');

  recalls = zeros(n_methods, numel(iou_thresholds));
  ARs = zeros(n_methods,1);
  ARs_per_class = zeros(n_methods, num_classes);
  
  for i = 1:n_methods
    fprintf('%s ', methods(i).name);
    tic;
    data = load(iou_files{i});
    thresh_idx = find( ...
      [data.best_candidates.candidates_threshold] <= num_candidates, 1, 'last');
    experiment = data.best_candidates(thresh_idx);
    [overlaps, recall, ARs(i)] = compute_average_recall(experiment.best_candidates.iou);
    
    for j = 1:numel(iou_thresholds)
      [~,min_idx] = min(abs(overlaps - iou_thresholds(j)));
      recalls(i,j) = recall(min_idx);
    end
    
    for c = 1:num_classes
      masks = get_class_masks(testset.per_class{c}.impos, testset.impos);
      iou = filter_best_ious(experiment.best_candidates.iou, masks);
      [~, ~, ARs_per_class(i,c)] = compute_average_recall(iou);
    end
    toc;
  end
  
  save('data/pascal_voc07_test_recall.mat', 'recalls', 'methods', ...
    'iou_thresholds', 'ARs', 'ARs_per_class');
  fprintf('done, all is well\n');
end


function iou = filter_best_ious(iou, masks)
  flat_mask = cat(1, masks{:});
  assert(numel(iou) == numel(flat_mask));
  iou = iou(flat_mask);
end


function masks = get_class_masks(class_gt, gt)
  gt_ids = {gt.im};
  n = numel(gt_ids);
  masks = cell(n,1);
  
  for i = 1:n
    masks{i} = false(size(gt(i).boxes, 1), 1);
  end
  
  for i = 1:numel(class_gt), im_id = class_gt(i).im;
    gt_idx = find(strcmp(gt_ids, im_id));
    assert(numel(gt_idx)==1);
    gt_boxes = gt(gt_idx).boxes;
    
    boxes = class_gt(i).boxes;
    % sanity check
    found = ismember(boxes, gt_boxes, 'rows');
    assert(all(found));
    
    masks{gt_idx} = ismember(gt_boxes, boxes, 'rows');
  end
end