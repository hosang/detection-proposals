function save_recall_voc07()
  methods = get_method_configs();
  iou_files = {methods.best_voc07_candidates_file};
  num_candidates = 1000;
  
  iou_thresholds = .5:.025:1;
  
  labels = {methods.short_name};
  long_labels = {methods.name};
  n_methods = numel(iou_files);

  recalls = zeros(n_methods, numel(iou_thresholds));
  
  for i = 1:n_methods
    data = load(iou_files{i});
    thresh_idx = find( ...
      [data.best_candidates.candidates_threshold] <= num_candidates, 1, 'last');
    experiment = data.best_candidates(thresh_idx);
    [overlaps, recall, AR] = compute_average_recall(experiment.best_candidates.iou);
    
    for j = 1:numel(iou_thresholds)
      [~,min_idx] = min(abs(overlaps - iou_thresholds(j)));
      recalls(i,j) = recall(min_idx);
    end
  end
  
  save('data/pascal_voc07_test_recall.mat', 'recalls', 'methods', 'iou_thresholds');
end
