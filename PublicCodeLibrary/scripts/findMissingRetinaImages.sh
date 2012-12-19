#!/bin/bash


# Finds missing retina images for iphone

IMAGES_DIR=./Resources/images

# Only split on new lines
IFS=$'\n'

# Search missing images
echo 
echo --- Images for wich the retina version is missing ---
echo 

for file in $(ls $IMAGES_DIR)
do
  if [[ ${file} == *@2x.png ]];
  then
    echo -n ""
  else
    RETINA_COUNTERPART_NAME=$IMAGES_DIR/$(echo $file | sed "s/.png//g")@2x.png

    if [[ ! -e "$RETINA_COUNTERPART_NAME" && ${file} != iTunesArtwork* && ${file} != CD_[0-9]** ]]
    then
		echo $IMAGES_DIR/$file
    fi
  fi
done
