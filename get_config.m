function [config] = get_config()

  config.pascal_images = '/BS/hosang/work/monokel_pascal/voc2007/VOCdevkit/VOC2007/JPEGImages/%s.jpg';
  config.transformed_pascal_images = '/var/tmp/transformed_pascal/%s.png';
  
  % this is where candidates and all other computed data are stored
  config.precomputed_candidates = '/BS/candidate_detections/archive00/precomputed';

  if config.precomputed_candidates(end) ~= '/'
    config.precomputed_candidates = [config.precomputed_candidates '/'];
  end
end
