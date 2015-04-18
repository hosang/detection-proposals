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

  % define algorithm names, IoU thresholds, recall values and AP scores
  nms={methods.name};

  ld = load('data/pascal_voc07_test_llda_dpm_aps.mat');
  axis_lim = [0 0.975 20 34];
  % the following three lines reproduce Piotr's plots
%   whitelist = [8 7 13 9 15 1 2 4 10 3 6 12];
%   AP = ld.aps(:,1)'; AP = AP(whitelist);
%   ploteroo(T, R(:,whitelist), AP, nms(whitelist), axis_lim);
  llda_dpm_AP = ld.aps(:,2)';
  
  plot_correlation_over_recall(T, R(:,method_selection), ...
    llda_dpm_AP(method_selection), nms(method_selection), axis_lim);
  scale_and_save('figures/LLDA_DPM_mAP_recall_voc07.pdf');
  
  ld = load('data/pascal_voc07_test_rcnn_aps.mat');
  axis_lim = [0 0.975 10 60];
  rcnn_AP = ld.aps;
  
  plot_correlation_over_recall(T, R(:,method_selection), ...
    rcnn_AP(method_selection), nms(method_selection), axis_lim);
  scale_and_save('figures/RCNN_mAP_recall_voc07.pdf');
  
  % Average recall plots
  const_weights = ones(numel(T),1) ./ numel(T);
  integral_area = sum(R .* repmat(const_weights, [1, n_methods]), 1);
  plot_weighted_area_color_coded(integral_area(method_selection), ...
    llda_dpm_AP(method_selection), methods(method_selection), [0 0.6 10 34]);
  scale_and_save('figures/LLDA_DPM_mAP_recall_area_voc07.pdf');
  
  plot_weighted_area_color_coded(integral_area(method_selection), ...
    rcnn_AP(method_selection), methods(method_selection), [0 0.6 10 60]);
  scale_and_save('figures/RCNN_mAP_recall_area_voc07.pdf');
  
end

function scale_and_save(output_filename)
  hei = 6; wid = 6;
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

  function plot_weighted_area_color_coded(areas, AP, methods, axis_lim)
  S=corrcoef([areas' AP']); s = S(1,end);
  figure;
  for i = 1:numel(methods)
    plot(areas(i), AP(i), '.', 'MarkerSize', 20, 'Color', methods(i).color, 'LineWidth', 1.5);
    hold on;
  end
  grid on;
  xlabel(sprintf('average recall')); axis(axis_lim)
  title(sprintf('correlation=%.3f',s)); ylabel('mAP'); hold on;
  p=polyfit(areas,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3); hold off
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
  figure(); plot(T,S,'.-', 'Color', [31,120,180]/256, 'MarkerSize', 20);
  xlabel('IoU overlap threshold'); ylabel('correlation with mAP'); grid on;
  xlim([T(1), T(end-1)]);

% figure;
% for t = 1:numel(S)
%   subplot(5,5,t);
%   R1=R(t,:); plot(R1,AP,'dr'); grid on; %text(R1+.015,AP,nms);
% xlabel(sprintf('recall at IoU=%.3f',T(t))); axis(axis_lim)
% title(sprintf('correlation=%.3f',S(t))); ylabel('AP'); hold on;
% p=polyfit(R1,AP,1); line([0 1],[p(2),sum(p)],'Color',[1 1 1]/3); hold off
% end
end
