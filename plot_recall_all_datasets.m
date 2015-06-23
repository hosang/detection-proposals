function plot_recall_all_datasets()
  % Plot the average recall of PASCAL, ImageNet, and COCO for all methods.
  %
  % This function requires the proposals to already be saved to disk. It will
  % compute a matching between ground truth and proposals (if the result is not
  % yet found on disk) and then plot recall curves. The plots are saved to
  % figures/.
  
  methods = get_method_configs();
  methods([14 16 19:25]) = [];
  
  pascal = {methods.best_voc07_candidates_file};
  imagenet = {methods.best_imagenet_candidates_file};
  coco = {methods.best_coco14_candidates_file};
  
  valid_methods = check_for_data(cat(2, pascal(:), imagenet(:), coco(:)));
  if ~any(valid_methods)
    fprintf('no methods have the recall matchings computed, run the plot scripts for each of the datasets, to get the required data\n');
    return
  end
  methods = methods(valid_methods);
  pascal = {methods.best_voc07_candidates_file};
  imagenet = {methods.best_imagenet_candidates_file};
  coco = {methods.best_coco14_candidates_file};
  
%   plot_legend(methods);
%   printpdf('figures/imagenet_recall_legend.pdf');
  
  fprintf('\n\n');
  for i = 1:numel(methods)
    fprintf('Valid data for plots: %s\n', methods(i).name);
  end
  
  dataset_labels = {'PASCAL 2007', 'ImageNet 2013', 'COCO 2014'};
  AR_plots(methods, cat(2, pascal(:), imagenet(:), coco(:)), dataset_labels);
end


function AR_plots(methods, iou_files, dataset_labels)
  num_candidates = 1000;

  n = size(iou_files, 1);
  num_datasets = size(iou_files, 2);

  for i = 1:n
    ARs = zeros(1, num_datasets);
    for dataset_i = 1:num_datasets, iou_file = iou_files{i,dataset_i};
      try
        data = load(iou_file);

        num_experiments = numel(data.best_candidates);
        exp_idx = find([data.best_candidates.candidates_threshold] == num_candidates);
        assert(numel(exp_idx) == 1);
        experiment = data.best_candidates(exp_idx);
        [~, ~, ARs(dataset_i)] = compute_average_recall(experiment.best_candidates.iou);
      catch
        ARs(dataset_i) = nan;
      end
    end
    
    line_style = '-';
    if methods(i).is_baseline
      line_style = '--';
    end
    if ~isempty(methods(i).line_style)
      line_style = methods(i).line_style;
    end
    plot(1:num_datasets, ARs, '.', 'MarkerSize', 20, 'Color', methods(i).color, 'LineWidth', 1.5, 'LineStyle', line_style);
    hold on;
  end
  xlim([0.5, num_datasets + 0.5]);
  ylim([0.1, 0.6]);
  ylabel('average recall');
  hold off; grid on;
  set(gca,'XTick',(1:num_datasets),'XTickLabel',dataset_labels);
  set(gca,'XTickLabelRotation',25);
  set(gca, 'box','off');
  set(gca,'YTick', 0.1:0.1:0.6);

  hei = 10;
  wid = 8;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/average_recall_all_datasets.pdf');
end


function valid = check_for_data(candidate_files)
  valid = true(size(candidate_files));
  for i = 1:size(candidate_files,1)
    for j = 1:size(candidate_files,2)
      try
        ld = load(candidate_files{i,j});
      catch
        fprintf('file missing: %s\n', candidate_files{i,j});
        valid(i,j) = false;
      end
    end
  end
  valid = all(valid,2);
end
