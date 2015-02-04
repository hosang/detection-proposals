function [overlaps, score, class_ids, avg_cube, avg_cube_per_class] = detector_wiggle_rcnn(filename)
  ld = load(filename);
  scoremaps = ld.scoremaps;
  
  n = numel(scoremaps);
  all_overlap_scores = cell(n,1);
  for i = 1:n, s = scoremaps(i);
    gt = double(s.gt_box);
    boxes = double(s.boxes);
    invalid = isinf(boxes(:,5)) | isnan(boxes(:,5));
    boxes = boxes(~invalid,:);
    
    t_overlap = overlap(gt, boxes);
    t_class_ids = repmat(s.class, size(t_overlap));
    all_overlap_scores{i} = cat(2, t_overlap, boxes(:,5), double(t_class_ids));
  end
  
  all_overlap_scores = cat(1, all_overlap_scores{:});
  overlaps = all_overlap_scores(:,1);
  score = all_overlap_scores(:,2);
  class_ids = all_overlap_scores(:,3);
  
  avg_cube = [];
  avg_cube_per_class = [];
  if isfield(scoremaps, 'score_map') && ~isempty(scoremaps(1).score_map)
    all_maps = cat(4,scoremaps.score_map);
    avg_cube = nanmean(all_maps, 4);
    
    classes = unique([scoremaps.class]);
    avg_cube_per_class = cell(1, numel(classes));
    for c = 1:numel(classes)
      t_scoremaps = scoremaps([scoremaps.class] == classes(c));
      avg_cube_per_class{c} = nanmean(cat(4,t_scoremaps.score_map), 4);
    end
  end
end
