function plot_legend(method_configs)

  figure; hold on;
  n_methods = numel(method_configs);
  [~,order] = sort([method_configs.sort_key]);
  method_configs = method_configs(order);
  
  x = 1:10;
  y = 1:10;
  handles = zeros([n_methods, 1]);
  for i = 1:n_methods
    style = '-';
    if method_configs(i).is_baseline
      style = '--';
    end
    if ~isempty(method_configs(i).line_style)
      style = method_configs(i).line_style;
    end
    handles(i) = plot(x, y, 'Color', method_configs(i).color, ...
      'LineWidth', 1.5, 'LineStyle', style);
  end
  lh = legend({method_configs.name});
  legend boxoff;
  for i = 1:n_methods
    set(handles(i), 'visible', 'off');
  end
  set(gca, 'visible', 'off');
end