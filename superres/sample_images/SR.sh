#!/bin/bash

## This is a script to create a 'super resolution' image from a stack of lower resolution images

mkdir -p resized # make a new directory to hold resized images
convert *.jpg -resize 200% ./resized/%04d.jpg # upscale images by 200% (4x more pixels) and copy to new directory
cd ./resized
align_image_stack -a al -C -t 0.3 -c 20 -v *.jpg # auto-align resized images and crop all of them to aligned area
cd ..
convert ./resized/al* -evaluate-sequence mean SR_mean.jpg # calculate average at each new pixel
convert ./resized/al* -evaluate-sequence median SR_median.jpg # calculate median at each new pixel

#rmdir -fr resized # remove interm images 

