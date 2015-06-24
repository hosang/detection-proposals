function plot_correlation_voc07()
% Plots for analyzing the correlation between detector performance
% (LLDA-DPM and R-CNN) on the different proposal methods and different
% proxy measures based on recall of the proposals.
%
% based on Piotr's blog post:
% https://pdollar.wordpress.com/2014/11/18/evaluating-object-proposals/

  methods = get_method_configs();
  n_methods = numel(methods);
  
  method_selection = 1:n_methods;
  method_selection([14 16 19:25]) = [];

  % Recall matrix used for experiments nThresholds x nAlgorithms
  ld = load('data/pascal_voc07_test_recall.mat');
  R = ld.recalls';
  T = ld.iou_thresholds;
  ARs = ld.ARs(:);
  ARs_per_class = ld.ARs_per_class';

  % define algorithm names, IoU thresholds, recall values and AP scores
  nms={methods.name};

  ld = load('data/pascal_voc07_test_llda_dpm_aps.mat');
  axis_lim = [0.5 0.975 0.6 1];
  % the following three lines reproduce Piotr's plots
%   whitelist = [8 7 13 9 15 1 2 4 10 3 6 12];
%   AP = ld.aps(:,1)'; AP = AP(whitelist);
%   ploteroo(T, R(:,whitelist), AP, nms(whitelist), axis_lim);
  llda_dpm_AP = ld.aps(:,2)';
  llda_dpm_AP_per_class = ld.aps_per_class(:,:,2)';
  
  plot_correlation_over_recall(T, R(:,method_selection), ...
    llda_dpm_AP(method_selection), nms(method_selection), axis_lim);
  scale_and_save('figures/LLDA_DPM_mAP_recall_voc07.pdf');
  
  ld = load('data/pascal_voc07_test_rcnn_aps.mat');
  rcnn_AP = ld.aps;
  rcnn_AP_per_class = ld.aps_per_class';
  
  plot_correlation_over_recall(T, R(:,method_selection), ...
    rcnn_AP(method_selection), nms(method_selection), axis_lim);
  scale_and_save('figures/RCNN_mAP_recall_voc07.pdf');
  
  ld = load('data/pascal_voc07_test_frcn_aps.mat');
  frcn_AP = ld.aps;
  frcn_AP_per_class = ld.aps_per_class';
 
  plot_correlation_over_recall(T, R(:,method_selection), ...
    frcn_AP(method_selection), nms(method_selection), axis_lim);
  scale_and_save('figures/FRCN_mAP_recall_voc07.pdf');
  
  ld = load('data/pascal_voc07_test_frcn_noregr_aps.mat');
  frcn_noregr_AP = ld.aps;
  frcn_noregr_AP_per_class = ld.aps_per_class';
 
  plot_correlation_over_recall(T, R(:,method_selection), ...
    frcn_noregr_AP(method_selection), nms(method_selection), axis_lim);
  scale_and_save('figures/FRCN_noregr_mAP_recall_voc07.pdf');
  
  % Average recall plots
  plot_weighted_area_color_coded(ARs(method_selection), ...
    llda_dpm_AP(method_selection), methods(method_selection), [0 0.6 10 38]);
  scale_and_save('figures/LLDA_DPM_mAP_recall_area_voc07.pdf');
  
  axlim = [0 0.6 12 67];
  plot_weighted_area_color_coded(ARs(method_selection), ...
    rcnn_AP(method_selection), methods(method_selection), axlim);
  scale_and_save('figures/RCNN_mAP_recall_area_voc07.pdf');
  
  plot_weighted_area_color_coded(ARs(method_selection), ...
    frcn_AP(method_selection), methods(method_selection), axlim);
  scale_and_save('figures/FRCN_mAP_recall_area_voc07.pdf');
  
  frcn_AR = mean(R(T>=0.5 & T<=0.7,:), 1);
  plot_weighted_area_color_coded(frcn_AR(method_selection)', ...
    frcn_AP(method_selection), methods(method_selection), [0 1 12 67]);
  scale_and_save('figures/FRCN_mAP_recall_area0.5_0.8_voc07.pdf');
  
  plot_weighted_area_color_coded(ARs(method_selection), ...
    frcn_noregr_AP(method_selection), methods(method_selection), axlim);
  scale_and_save('figures/FRCN_noregr_mAP_recall_area_voc07.pdf');
  
  % Average recall plots per class
  per_class_method_selection = method_selection;
%   plot_AR_per_class(ARs_per_class(:,per_class_method_selection), ...
%     llda_dpm_AP_per_class(:,per_class_method_selection), methods(per_class_method_selection), [0 .85 0 65]);
%   scale_and_save('figures/LLDA_DPM_correlation_per_class_lines_voc07.pdf', 6, 7);
%   plot_AR_per_class(ARs_per_class(:,per_class_method_selection), ...
%     rcnn_AP_per_class(:,per_class_method_selection), methods(per_class_method_selection), [0 .85 0 85]);
%   scale_and_save('figures/RCNN_correlation_per_class_lines_voc07.pdf', 6, 7);
%   plot_AR_per_class(ARs_per_class(:,per_class_method_selection), ...
%     frcn_AP_per_class(:,per_class_method_selection), methods(per_class_method_selection), [0 .85 0 90]);
%   scale_and_save('figures/FRCN_correlation_per_class_lines_voc07.pdf', 6, 7);
%   plot_AR_per_class(ARs_per_class(:,per_class_method_selection), ...
%     frcn_noregr_AP_per_class(:,per_class_method_selection), methods(per_class_method_selection), [0 .85 0 90]);
%   scale_and_save('figures/FRCN_noregr_correlation_per_class_lines_voc07.pdf', 6, 7);
  
%   plot_correlation_per_class(ARs_per_class(:,per_class_method_selection), ...
%     llda_dpm_AP_per_class(:,per_class_method_selection), true);
%   scale_and_save('figures/LLDA_DPM_correlation_per_class_colorbars_voc07.pdf', 6, 12);
%   plot_correlation_per_class(ARs_per_class(:,per_class_method_selection), ...
%     rcnn_AP_per_class(:,per_class_method_selection), true);
%   scale_and_save('figures/RCNN_correlation_per_class_colorbars_voc07.pdf', 6, 12);
%   plot_correlation_per_class(ARs_per_class(:,per_class_method_selection), ...
%     frcn_AP_per_class(:,per_class_method_selection), true);
%   scale_and_save('figures/FRCN_correlation_per_class_colorbars_voc07.pdf', 6, 12);
%   plot_correlation_per_class(ARs_per_class(:,per_class_method_selection), ...
%     frcn_noregr_AP_per_class(:,per_class_method_selection), true);
%   scale_and_save('figures/FRCN_noregr_correlation_per_class_colorbars_voc07.pdf', 6, 12);
  
  plot_correlation_per_class_multi(ARs_per_class(:,per_class_method_selection), ...
    cat(1, llda_dpm_AP_per_class(:,per_class_method_selection), ...
           rcnn_AP_per_class(:,per_class_method_selection), ...
           frcn_noregr_AP_per_class(:,per_class_method_selection), ...
           frcn_AP_per_class(:,per_class_method_selection)), ...
    {'LM-LLDA bbpred', 'R-CNN', 'Fast R-CNN', 'Fast R-CNN bbpred'}, ...
    'bars');
  scale_and_save('figures/all_detectors_correlation_per_class_colorbars_voc07.pdf', 7, 16);

  
%   plot_correlation_per_class(ARs_per_class(:,per_class_method_selection), ...
%     llda_dpm_AP_per_class(:,per_class_method_selection), false);
%   scale_and_save('figures/LLDA_DPM_correlation_per_class_bars_voc07.pdf', 6, 12);
%   plot_correlation_per_class(ARs_per_class(:,per_class_method_selection), ...
%     rcnn_AP_per_class(:,per_class_method_selection), false);
%   scale_and_save('figures/RCNN_correlation_per_class_bars_voc07.pdf', 6, 12);
end

function scale_and_save(output_filename, hei, wid)
  s = 0.13;
  if nargin < 2, hei = 40*s; end
  if nargin < 3, wid = 45*s; end
  set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
  set(gcf, 'PaperPositionMode','auto');
  printpdf(output_filename);
end

function plot_weighted_area(areas, AP, nms, axis_lim)
  S=corrcoef([areas' AP']); s = S(1,end);
  figure; plot(areas, AP, 'dr'); grid on; text(areas+.015,AP,nms);
  xlabel(sprintf('weighted area under recall')); axis(axis_lim)
  title(sprintf('correlation=%.3f',s)); ylabel('mAP'); hold on;
  p=polyfit(areas,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3); hold off
end

function colors = class_colors()
  colors = [[74,136,55],
[127,137,221],
[209,79,44],
[95,40,42],
[209,68,117],
[218,145,59],
[117,171,189],
[205,132,115],
[54,70,41],
[198,147,179],
[204,104,203],
[114,198,70],
[64,74,86],
[121,60,105],
[86,117,53],
[121,113,53],
[111,182,140],
[138,75,38],
[189,175,70],
[82,92,146]]/255;
end

function plot_correlation_per_class_multi(AR_per_class, AP_per_class, legend_strs, type)
colors = [
24,98,169
236,178,0
30,129,43
211,118,166
]./255;
% 255, 197, 108
% 110, 197, 233
% 0, 58, 111
% 255, 89, 89

  load('data/short_classes.mat');
  n = numel(classes);
  n_detectors = numel(legend_strs);
  
  S=corrcoef([AR_per_class' AP_per_class']);
  Spd = cell(1, n_detectors);
  for i = 1:n_detectors
    Spd{i} = diag(S((i*n+1):((i+1)*n), 1:n));
  end
  Spd = cat(2, Spd{:});
  
  figure;
  if strcmp(type, 'lines')
    for i = 1:n_detectors
      plot(1:n, Spd(:,i), '.-', 'Color', colors(i,:));
      if i == 1; hold on; end
    end
    
    legend(legend_strs);
  elseif strcmp(type, 'bars')
    hb = bar(1:n, Spd);
    for i = 1:n_detectors
      set(hb(i), 'FaceColor', colors(i,:), 'EdgeColor', colors(i,:));
    end
    
    set(gca,'XTick',(1:numel(classes))-0.3,'XTickLabel',classes);
    set(gca,'XTickLabelRotation',60);
    xlim([0,21]);
    ylim([0.6 1]);
    ylabel('correlation with AP');
    
    legend(legend_strs, 'Location', 'SouthEast');
  else
    error('unknown type');
  end
end

function plot_correlation_per_class(AR_per_class, AP_per_class, colorful)
  colors = class_colors();
  load('data/short_classes.mat');
  
  n = numel(classes);
  S=corrcoef([AR_per_class' AP_per_class']); S=diag(S(n+1:end,1:n));
  figure; hold on;
  if colorful
    for i = 1:n
      bar(i, S(i), 'FaceColor', colors(i,:), 'EdgeColor', colors(i,:));
      hold on;
    end
  else
    bar(S, 'FaceColor', [31,120,180]/256, 'EdgeColor', [31,120,180]/256);
  end
%   bar(S);
  set(gca,'XTick',(1:numel(classes))-0.3,'XTickLabel',classes);
  set(gca,'XTickLabelRotation',60);
  xlim([0,21]);
  ylim([0.6 1]);
  ylabel('correlation with AP');
end

function plot_AR_per_class(AR_per_class, AP_per_class, methods, axis_lim)
  colors = class_colors();
  load('data/short_classes.mat');
  
  S=corrcoef([AR_per_class(:) AP_per_class(:)]); s = S(1,end);
  figure;
  for c = 1:numel(classes), cls = classes{c};
    for i = 1:numel(methods)
      plot(AR_per_class(c,i), AP_per_class(c,i), 'o', 'MarkerSize', 3, 'Color', colors(c,:), 'LineWidth', 0.5);
      hold on;
    end
    p=polyfit(AR_per_class(c,:),AP_per_class(c,:),1); line([0 1],[p(2),sum(p)],'Color',colors(c,:));
  end
  grid on;
  xlabel(sprintf('average recall')); 
  ylabel('AP'); hold off;
  axis(axis_lim); 
  
  % move the title inside of the plot
  v = axis;
  handle = title(sprintf('correlation=%.3f',s));
  titlepos = [(v(2)-v(1))*0.5+v(1), (v(4)-v(3))*0.89+v(3), 0];
  set(handle, 'Position', titlepos);
end

function plot_weighted_area_color_coded(areas, AP, methods, axis_lim)
  AP = AP(:);
  S=corrcoef([areas AP]); s = S(1,end);
  figure;
  for i = 1:numel(methods)
    plot(areas(i), AP(i), '.', 'MarkerSize', 20, 'Color', methods(i).color, 'LineWidth', 1.5);
    hold on;
  end
  grid on;
  xlabel(sprintf('average recall')); axis(axis_lim)
%   title(sprintf('correlation=%.3f',s));
  ylabel('mAP');
  p=polyfit(areas,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3); hold off
  
  % move the title inside of the plot
  v = axis;
  handle = title(sprintf('correlation=%.3f',s));
  titlepos = [(v(2)-v(1))*0.5+v(1), (v(4)-v(3))*0.89+v(3), 0];
  set(handle, 'Position', titlepos);
end

function ploteroo(T, R, AP, nms, axis_lim)
  % plot correlation versus IoU and compute best threshold t
  S=corrcoef([R' AP']); S=S(1:end-1,end); [s,t]=max(S);
  figure(); plot(T,S,'-or'); xlabel('IoU'); ylabel('corr'); grid on;
  % plot AP versus recall at single best threshold t
  figure(); R1=R(t,:); plot(R1,AP,'dg'); grid on; text(R1+.015,AP,nms);
  xlabel(sprintf('recall at IoU=%.3f',T(t))); axis(axis_lim)
  title(sprintf('correlation=%.3f',s)); ylabel('mAP'); hold on;
  p=polyfit(R1,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3); hold off
  % plot AP versus recall for a series of thresholds
  figure;
  for t = 1:20
    subplot(4,5,t);
    R1=R(t,:); plot(R1,AP,'dr'); grid on; %text(R1+.015,AP,nms);
  xlabel(sprintf('recall at IoU=%.3f',T(t))); axis(axis_lim)
  title(sprintf('correlation=%.3f',S(t))); ylabel('mAP'); hold on;
  p=polyfit(R1,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3); hold off
  end
  % compute correlation against optimal range of thrs(a:b)
  n=length(T); S=zeros(n,n);
  for a=1:n, for b=a:n, s=corrcoef(sum(R(a:b,:),1),AP); S(a,b)=s(2); end; end
  [s,t]=max(S(:)); [a,b]=ind2sub([n n],t); R1=mean(R(a:b,:),1);
  figure(); plot(R1,AP,'dg'); grid on; text(R1+.015,AP,nms);
  xlabel(sprintf('recall at IoU=%.3f-%.3f',T(a),T(b))); axis(axis_lim)
  title(sprintf('correlation=%.3f',s)); ylabel('mAP'); hold on;
  p=polyfit(R1,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3); hold off
end

function plot_correlation_over_recall(T, R, AP, nms, axis_lim)
  S=corrcoef([R' AP']); S=S(1:end-1,end);
  figure(); xlim([T(1), T(end-1)]);
  plot(T,S,'.-', 'Color', [31,120,180]/256, 'MarkerSize', 20);
  axis(axis_lim);
  xlabel('IoU overlap threshold'); ylabel('correlation with mAP'); grid on;
end
