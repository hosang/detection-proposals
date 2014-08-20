function plot_recall_voc07()
  % Plot the recall of pascal test set ground truth for all methods.
  %
  % This function requires the proposals to already be saved to disk. It will
  % compute a matching between ground truth and proposals (if the result is not
  % yet found on disk) and then plot recall curves. The plots are saved to
  % figures/.

  testset = load('data/pascal_voc07_test_annotations.mat');
  methods = get_method_configs();
  
  compute_best_candidates(testset, methods);

  fh = figure;
  plot_overlap_recall_curve({methods.best_voc07_candidates_file}, methods, 100, fh, true, 'NorthEast');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/recall_100.pdf')
  
  plot_overlap_recall_curve({methods.best_voc07_candidates_file}, methods, 100, fh, true, 'NorthEast', true);
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/recall_100_long_names.pdf')
  
  fh = figure;
  plot_overlap_recall_curve({methods.best_voc07_candidates_file}, methods, 1000, fh, false, 'NorthEast');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/recall_1000.pdf')
  
  fh = figure;
  plot_overlap_recall_curve({methods.best_voc07_candidates_file}, methods, 10000, fh, false, 'SouthWest');
  hei = 10;
  wid = 10;
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf('figures/recall_10000.pdf')

  plot_num_candidates_auc({methods.best_voc07_candidates_file}, methods);
end

function compute_best_candidates(testset, methods)
  num_annotations = numel(testset.pos);
  candidates_thresholds = round(10 .^ (0:0.5:4));
  num_candidates_thresholds = numel(candidates_thresholds);
  
  for method_idx = 1:numel(methods)
    method = methods(method_idx);
    try
      load(method.best_voc07_candidates_file, 'best_candidates');
      continue
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
    
    pos_range_start = 1;
    for j = 1:numel(testset.impos)
      tic_toc_print('evalutating %s: %d/%d\n', method.name, j, numel(testset.impos));
      pos_range_end = pos_range_start + size(testset.impos(j).boxes, 1) - 1;
      assert(pos_range_end <= num_annotations);
    
      tic_toc_print('sampling candidates for image %d/%d\n', j, numel(testset.impos));
      [~,img_id,~] = fileparts(testset.impos(j).im);

      for i = 1:num_candidates_thresholds
        [candidates, scores] = get_candidates(method, img_id, ...
          candidates_thresholds(i));
        if isempty(candidates)
          impos_best_ious = zeros(size(testset.impos(j).boxes, 1), 1);
          impos_best_boxes = zeros(size(testset.impos(j).boxes, 1), 4);
        else
          [impos_best_ious, impos_best_boxes] = closest_candidates(...
            testset.impos(j).boxes, candidates);
        end

        best_candidates(i).best_candidates.candidates(pos_range_start:pos_range_end,:) = impos_best_boxes;
        best_candidates(i).best_candidates.iou(pos_range_start:pos_range_end) = impos_best_ious;
        best_candidates(i).image_statistics(j).num_candidates = size(candidates, 1);
      end
      
      pos_range_start = pos_range_end + 1;
    end
    
    save(method.best_voc07_candidates_file, 'best_candidates');
  end
end
