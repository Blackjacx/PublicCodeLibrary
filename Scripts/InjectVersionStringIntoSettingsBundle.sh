#!/bin/bash

# Debug
#set -x

APP_PATH="$TARGET_BUILD_DIR/$EXECUTABLE_FOLDER_PATH"

if [ ! -d "$APP_PATH" ]; then
	echo "$APP_PATH does not exist!"
	exit 1
fi

PATH_TO_ROOT_PLIST="$APP_PATH/Settings.bundle/Root.plist"
PATH_TO_INFO_PLIST="$TARGET_BUILD_DIR/$INFOPLIST_PATH"
SVN_VERSION_STRING=$(svnversion -c |cut -d ':' -f2 | tr -d MS)

/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:1:DefaultValue $(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PATH_TO_INFO_PLIST") ($SVN_VERSION_STRING)" "$PATH_TO_ROOT_PLIST"