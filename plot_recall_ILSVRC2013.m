function plot_recall_ILSVRC2013()
  % Plot the recall of ILSVRC2013 validation set ground truth for all methods.
  %
  % This function requires the proposals to already be saved to disk. It will
  % compute a matching between ground truth and proposals (if the result is not
  % yet found on disk) and then plot recall curves. The plots are saved to
  % figures/.
  
  val = load('data/ILSVRC2013_val_annotations.mat');
  methods = get_method_configs();
  methods = methods([3 4 6 8 9 11 12 13 14 15 16]);
  
  valid_methods = compute_best_candidates(val, methods);
  methods = methods(valid_methods);
  
  fprintf('\n\n');
  for i = 1:numel(methods)
    fprintf('Valid data for plots: %s\n', methods(i).name);
  end

  fh = figure;
  plot_overlap_recall_curve({methods.best_imagenet_candidates_file}, methods, 100, fh, true, 'NorthEast');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/imagenet_recall_100.pdf')
  
  fh = figure;
  plot_overlap_recall_curve({methods.best_imagenet_candidates_file}, methods, 1000, fh, false, 'NorthEast');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/imagenet_recall_1000.pdf')

  fh = figure;
  plot_overlap_recall_curve({methods.best_imagenet_candidates_file}, methods, 1000, fh, true, 'NorthEast');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/imagenet_recall_1000_with_labels.pdf')

  fh = figure;
  plot_overlap_recall_curve({methods.best_imagenet_candidates_file}, methods, 10000, fh, false, 'NorthEast');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/imagenet_recall_10000.pdf')
  
  plot_num_candidates_auc({methods.best_imagenet_candidates_file}, methods, 'imagenet_');
end

function valid_methods = compute_best_candidates(testset, methods)
  num_annotations = numel(testset.pos);
  candidates_thresholds = round(10 .^ (0:0.5:4));
  num_candidates_thresholds = numel(candidates_thresholds);
  
  valid_methods = false(numel(methods), 1);
  for method_idx = 1:numel(methods)
    method = methods(method_idx);
    fprintf('%s\n', method.name);
    try
      load(method.best_imagenet_candidates_file, 'best_candidates');
      valid_methods(method_idx) = true;
      continue;
    catch
    end
    
    % preallocate
    best_candidates = [];
    best_candidates(num_candidates_thresholds).candidates_threshold = [];
    best_candidates(num_candidates_thresholds).best_candidates = [];
    for i = 1:num_candidates_thresholds
      best_candidates(i).candidates_threshold = candidates_thresholds(i);
      best_candidates(i).best_candidates.candidates = zeros(num_annotations, 4);
      best_candidates(i).best_candidates.iou = zeros(num_annotations, 1);
      best_candidates(i).image_statistics(numel(testset.impos)).num_candidates = 0;
    end
    
    files_missing = false;
    pos_range_start = 1;
    for j = 1:numel(testset.impos)
      tic_toc_print('evalutating %s: %d/%d\n', method.name, j, numel(testset.impos));
      pos_range_end = pos_range_start + size(testset.impos(j).boxes, 1) - 1;
      assert(pos_range_end <= num_annotations);
    
%       tic_toc_print('sampling candidates for image %d/%d\n', j, numel(testset.impos));
      [~,img_id,~] = fileparts(testset.impos(j).im);

      for i = 1:num_candidates_thresholds
        try
          [candidates, scores] = get_candidates(method, img_id, ...
            candidates_thresholds(i));
        catch
          fprintf('%s candidates for %s missing\n', method.name, img_id);
          files_missing = true;
          break;
        end
        if isempty(candidates)
          impos_best_ious = zeros(size(testset.impos(j).boxes,1),1);
          impos_best_boxes = zeros(size(testset.impos(j).boxes,1),4);
        else
          [impos_best_ious, impos_best_boxes] = closest_candidates(...
            testset.impos(j).boxes, candidates);
        end

        best_candidates(i).best_candidates.candidates(pos_range_start:pos_range_end,:) = impos_best_boxes;
        best_candidates(i).best_candidates.iou(pos_range_start:pos_range_end) = impos_best_ious;
        best_candidates(i).image_statistics(j).num_candidates = size(candidates, 1);
      end
      if files_missing
        break;
      end
      
      pos_range_start = pos_range_end + 1;
    end
    valid_methods(method_idx) = ~files_missing;
    if ~files_missing
      save(method.best_imagenet_candidates_file, 'best_candidates');
    end
    
  end
end
