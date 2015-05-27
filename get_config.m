function [config] = get_config()

  config.pascal_images = '/BS/hosang/work/VOC2007/VOCdevkit/VOC2007/JPEGImages/%s.jpg';
  config.transformed_pascal_images = '/var/tmp/transformed_pascal/%s.png';
  
  % this is where candidates and all other computed data are stored
  % for pascal and imagenet
  config.precomputed_candidates = '/BS/candidate_detections/archive00/precomputed';
  % for coco
  config.precomputed_candidates_coco = '/BS/candidate_detections/archive00/precomputed-coco';
end
