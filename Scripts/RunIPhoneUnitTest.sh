#!/bin/bash

#  RunIPhoneUnitTest.sh
#  Copyright 2008 Google Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not
#  use this file except in compliance with the License.  You may obtain a copy
#  of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
#  License for the specific language governing permissions and limitations under
#  the License.
#
#  Runs all unittests through the iPhone simulator. We don't handle running them
#  on the device. To run on the device just choose "run".

# If we aren't running from the command line, then exit
if [ "$GHUNIT_CLI" = "" ] && [ "$GHUNIT_AUTORUN" = "" ]; then
  exit 0
fi

set -o errexit
set -o nounset

# Uncomment the next line to trace execution.
#set -o verbose

#  Controlling environment variables:
# DT_DISABLE_ZOMBIES -
#   Set to a non-zero value to turn on zombie checks. You will probably
#   want to turn this off if you enable leaks.
DT_DISABLE_ZOMBIES=${DT_DISABLE_ZOMBIES:=1}

# DT_ENABLE_LEAKS -
#   Set to a non-zero value to turn on the leaks check. You will probably want
#   to disable zombies, otherwise you will get a lot of false positives.

# DT_DISABLE_TERMINATION
#   Set to a non-zero value so that the app doesn't terminate when it's finished
#   running tests. This is useful when using it with external tools such
#   as Instruments.

# DT_LEAKS_SYMBOLS_TO_IGNORE
#   List of comma separated symbols that leaks should ignore. Mainly to control
#   leaks in frameworks you don't have control over.
#   Search this file for GTM_LEAKS_SYMBOLS_TO_IGNORE to see examples.
#   Please feel free to add other symbols as you find them but make sure to
#   reference Radars or other bug systems so we can track them.

# DT_REMOVE_GCOV_DATA
#   Before starting the test, remove any *.gcda files for the current run so
#   you won't get errors when the source file has changed and the data can't
#   be merged.
#
DT_REMOVE_GCOV_DATA=${DT_REMOVE_GCOV_DATA:=0}

# DT_DISABLE_USERDIR_SETUP
#   Controls whether or not CFFIXED_USER_HOME is erased and set up from scratch
#   for you each time the script is run. In some cases you may have a wrapper
#   script calling this one that takes care of that for us so you can set up
#   a certain user configuration.
DT_DISABLE_USERDIR_SETUP=${DT_DISABLE_USERDIR_SETUP:=0}

# DT_DISABLE_IPHONE_LAUNCH_DAEMONS
#   Controls whether or not we launch up the iPhone Launch Daemons before
#   we start testing. You need Launch Daemons to test anything that interacts
#   with security. Note that it is OFF by default. Set
#   GTM_DISABLE_IPHONE_LAUNCH_DAEMONS=0 before calling this script
#   to turn it on.
DT_DISABLE_IPHONE_LAUNCH_DAEMONS=${DT_DISABLE_IPHONE_LAUNCH_DAEMONS:=0}
  
ScriptDir=$(dirname "$(echo $0 | sed -e "s,^\([^/]\),$(pwd)/\1,")")
ScriptName=$(basename "$0")
ThisScript="${ScriptDir}/${ScriptName}"

DTXcodeNote() {
    echo ${ThisScript}:${1}: note: DT ${2}
}

if [ "$PLATFORM_NAME" == "iphonesimulator" ]; then

  # We kill the iPhone simulator because otherwise we run into issues where
  # the unittests fail becuase the simulator is currently running, and
  # at this time the iPhone SDK won't allow two simulators running at the same
  # time.
  set +e
  /usr/bin/killall "iPhone Simulator"
  set -e
  
  if [ $DT_REMOVE_GCOV_DATA -ne 0 ]; then
    if [ "${OBJECT_FILE_DIR}-${CURRENT_VARIANT}" != "-" ]; then
      if [ -d "${OBJECT_FILE_DIR}-${CURRENT_VARIANT}" ]; then
	  	DTXcodeNote ${LINENO} "Removing any .gcda files"
        (cd "${OBJECT_FILE_DIR}-${CURRENT_VARIANT}" && \
            find . -type f -name "*.gcda" -print0 | xargs -0 rm -f )
      fi
    fi
  fi
  
  export DYLD_ROOT_PATH="$SDKROOT"
  export DYLD_FRAMEWORK_PATH="$CONFIGURATION_BUILD_DIR"
  export IPHONE_SIMULATOR_ROOT="$SDKROOT"
  export CFFIXED_USER_HOME="$TEMP_FILES_DIR/SimulatorUserDir"

  # See http://developer.apple.com/technotes/tn2004/tn2124.html for an
  # explanation of these environment variables.

  # NOTE: any setup work is done before turning on the environment variables
  # to avoid having the setup work also get checked by what the variables
  # enabled.

  if [ $DT_DISABLE_USERDIR_SETUP -eq 0 ]; then
    # Cleanup user home directory
    if [ -d "$CFFIXED_USER_HOME" ]; then
      rm -rf "$CFFIXED_USER_HOME"
    fi
    mkdir "$CFFIXED_USER_HOME"
    mkdir "$CFFIXED_USER_HOME/Documents"
    mkdir -p "$CFFIXED_USER_HOME/Library/Caches"
  fi

  # If we want to test anything that interacts with the keychain, we need
  # securityd up and running. See above for details.
  if [ $DT_DISABLE_IPHONE_LAUNCH_DAEMONS -eq 0 ]; then	
	
	# Remove the probably existing launch deamon job
	launchctl list | grep RunIPhoneLaunchDaemons && launchctl remove RunIPhoneLaunchDaemons
	
#	if [ $(launchctl list | grep "RunIPhoneLaunchDaemons") == "" ];
#	then  
#		echo "First remove the launchctl job: 'RunIPhoneLaunchDaemons'"
#		launchctl remove RunIPhoneLaunchDaemons
#	fi
	
    # Start security deamon
    launchctl submit -l RunIPhoneLaunchDaemons -- "${ScriptDir}/RunIPhoneLaunchDaemons.sh" $IPHONE_SIMULATOR_ROOT $CFFIXED_USER_HOME
        
    # No matter how we exit, we want to shut down our launchctl job.
    trap "launchctl remove RunIPhoneLaunchDaemons" INT TERM EXIT
  fi
  
  if [ $DT_DISABLE_ZOMBIES -eq 0 ]; then
    DTXcodeNote ${LINENO} "Enabling zombies"
    export CFZombieLevel=3
    export NSZombieEnabled=YES
  fi
  
  # Turned off due to many stuff that's not neccessary to read for now
  # export MallocScribble=YES
  # export MallocPreScribble=YES
  # export MallocGuardEdges=YES
  # export MallocStackLogging=YES
  export NSAutoreleaseFreedObjectCheckEnabled=YES

  # Turn on the mostly undocumented OBJC_DEBUG stuff.
  # show help for OBJC debugging vars
  # export OBJC_HELP=1
  export OBJC_DEBUG_FRAGILE_SUPERCLASSES=YES
  export OBJC_DEBUG_UNLOAD=YES
  # Turned off due to the amount of false positives from NS classes.
  # export OBJC_DEBUG_FINALIZERS=YES
  export OBJC_DEBUG_NIL_SYNC=YES
  # Turned off due to many stuff that's not neccessary to read for now
  # export OBJC_PRINT_REPLACED_METHODS=YES

  # 6251475 iPhone simulator leaks @ CFHTTPCookieStore shutdown if
  #         CFFIXED_USER_HOME empty
  #
  # I think it is only used in google toolbox?!
  #
  # GTM_LEAKS_SYMBOLS_TO_IGNORE="CFHTTPCookieStore"
  
  # Setup the unit test executable path
  TEST_TARGET_EXECUTABLE_PATH="$TARGET_BUILD_DIR/$EXECUTABLE_PATH"

  if [ ! -e "$TEST_TARGET_EXECUTABLE_PATH" ]; then
    echo ""
    echo "  ------------------------------------------------------------------------"
    echo "  Missing executable path: "
    echo "     $TEST_TARGET_EXECUTABLE_PATH."
    echo "  The product may have failed to build or could have an old xcodebuild in your path (from 3.x instead of 4.x)."
    echo "  ------------------------------------------------------------------------"
    echo ""
    exit 1
  fi

  # Start Tests
  RUN_CMD="\"$TEST_TARGET_EXECUTABLE_PATH\" -RegisterForSystemEvents"
  echo "Running: $RUN_CMD"
  set +o errexit # Disable exiting on error so script continues if tests fail
  eval $RUN_CMD
  RETVAL=$?
  set -o errexit

  unset DYLD_ROOT_PATH
  unset DYLD_FRAMEWORK_PATH
  unset IPHONE_SIMULATOR_ROOT
  unset CFFIXED_USER_HOME

  if [ -n "$WRITE_JUNIT_XML" ]; then
    MY_TMPDIR=`/usr/bin/getconf DARWIN_USER_TEMP_DIR`
    RESULTS_DIR="${MY_TMPDIR}test-results"

    if [ -d "$RESULTS_DIR" ]; then
	  `$CP -r "$RESULTS_DIR" "$BUILD_DIR" && rm -r "$RESULTS_DIR"`
    fi
  fi
  
  exit $RETVAL
else
  DTXcodeNote ${LINENO} "Skipping running of unittests for device build."
  exit 0
fi