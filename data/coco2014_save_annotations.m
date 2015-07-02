function save_annotations_to_eval_format()
  dataDir='/BS/databases/coco/tools'; dataType='val2014';
  annFile=sprintf('%s/annotations/instances_%s.json',dataDir,dataType);
  if(~exist('coco','var')), coco=CocoApi(annFile); end
  
  imgIds = coco.getImgIds();
  impos = [];
  pos = [];
  for i = 1:numel(imgIds), imgId = imgIds(i);
    if mod(i, 100) == 0
      fprintf('%d/%d extracing annotations\n', i, numel(imgIds));
    end
    img = coco.loadImgs(imgId);
%     filename = sprintf('%s/images/%s/%s',dataDir,dataType,img.file_name);
    im_id = sprintf('%s/%s',dataType,img.file_name);
    
    annIds = coco.getAnnIds('imgIds',imgId,'iscrowd',0);
    anns = coco.loadAnns(annIds);
    boxes = single(cat(1,anns.bbox));
    if ~isempty(boxes)
      % convert from [x y w h] to [x1 y1 x2 y2]
      boxes(:,3:4) = boxes(:,1:2) + boxes(:,3:4);
    end
    
    idx = numel(impos)+1;
    impos(idx).im = im_id;
    impos(idx).img_size = [img.height, img.width];
    impos(idx).img_area = prod(impos(idx).img_size);
    impos(idx).boxes = boxes;
    
    for j = 1:size(boxes,1)
      idx = numel(pos)+1;
      pos(idx).im = im_id;
      pos(idx).x1 = boxes(j,1);
      pos(idx).y1 = boxes(j,2);
      pos(idx).x2 = boxes(j,3);
      pos(idx).y2 = boxes(j,4);
      pos(idx).boxes = boxes(j,:);
      pos(idx).img_area = impos(end).img_area;
      pos(idx).img_size = impos(end).img_size;
    end
  end
  
  save(['coco_' dataType '.mat'], 'impos', 'pos');
end
