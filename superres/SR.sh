#!/bin/sh

## This is a script to create a 'super resolution' image from a stack of lower resolution images

mkdir -p resized || exit 1 # make a new directory to hold resized images
convert *.jpg -resize 200% ./resized/%04d.jpg # upscale images by 200% (4x more pixels) and copy to new directory
cd ./resized || exit 1
align_image_stack --use-given-order --distortion -C -z -a al --corr=0.8 -t 1 -c 100 -v *.jpg # auto-align resized images and crop all of them to aligned area
cd ..
convert ./resized/al* -evaluate-sequence mean SR_mean.jpg # calculate average at each new pixel
convert ./resized/al* -evaluate-sequence median SR_median.jpg # calculate median at each new pixel

#rmdir -fr resized # remove interm images

echo "Script complete. If all went well, look for superresolution images entitled SR_mean.jpg and SR_median.jpg in the working directory"

exit 0
