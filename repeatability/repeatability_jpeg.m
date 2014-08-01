function [im2,H] = repeatability_jpeg(im, compression)
  if compression > 100
    tmp_filename = [tempname() '.jpg'];
    imwrite(im, tmp_filename, 'jpeg', 'Mode', 'lossless');
    im2 = imread(tmp_filename);
    if size(im2,3) == 1
      im2 = repmat(im2, [1 1 3]);
    end
    assert(all(size(im) == size(im2)));
    delete(tmp_filename);
  else
    tmp_filename = [tempname() '.jpg'];
    imwrite(im, tmp_filename, 'jpeg', 'Mode', 'lossy', 'Quality', compression);
    im2 = imread(tmp_filename);
    if size(im2,3) == 1
      im2 = repmat(im2, [1 1 3]);
    end
    assert(all(size(im) == size(im2)));
    delete(tmp_filename);
  end
  
  H = eye(3);
end
