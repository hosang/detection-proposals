function [overlaps, score, class_ids, avg_cube, avg_cube_per_class] = detector_wiggle_from_iou_score(filename)
  ld = load(filename, 'ious', 'scores', 'classes');
  
  avg_cube = [];
  avg_cube_per_class = [];
  score = ld.scores;
  overlaps = ld.ious;
  class_ids = ld.classes;
end