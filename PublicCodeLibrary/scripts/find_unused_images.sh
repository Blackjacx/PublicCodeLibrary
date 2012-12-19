#!/bin/sh
# -------
# Usage sh unusedImages.sh (jpg|png|gif)
# -------
# Caveat
# 1 -
# NSString *imageName = [NSString stringWithFormat:@"image_%d.png", 1];
# This script would incorrectly list these images as unreferenced. For example, you might have
# This script will incorrectly think image_1.png is unreferenced.
# 2 - If you have a method, or variable with the same name as the image it won't pick it up

SOURCE_ROOT_DIR="$SRCROOT"
PROJ=`find $SOURCE_ROOT_DIR -name '*.xib' -o -name '*.[mh]' -o -name '*.storyboard' -o -name '*.plist'`

accuFileSize=0

for imageName in `find . -name '*.'$1`
do
name=`basename -s .$1 $imageName`
name=`basename -s ~ipad $name`
name=`basename -s @iPad $name`
name=`basename -s ~iphone $name`
name=`basename -s @iPhone $name`
name=`basename -s @2x $name`

if ! grep -q $name $PROJ; then
filesize=$(ls -al $imageName | awk '{ print $5 }')
accuFileSize=$(expr $accuFileSize + $filesize)
echo "$imageName ($filesize)"
fi
done

echo "Total Wasted Size: `expr ${accuFileSize} / 1000` KB"
