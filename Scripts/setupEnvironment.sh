#!/bin/bash

#
# Build-Time file replacement to the correct ones for the respective environment
# The environment is determined from teh configuration name
#

if [ "$CONFIGURATION" == "LIVE" ]; then

ENVIRONMENT="LIVE"

elif [ "$CONFIGURATION" == "Release" ]; then

ENVIRONMENT="LIVE"

elif [ "$CONFIGURATION" == "DLSI_V0" ]; then

ENVIRONMENT="DLSI_V0"

elif [ "$CONFIGURATION" == "Jenkins" ]; then

ENVIRONMENT="DLSI_V0"

elif [ "$CONFIGURATION" == "DLSN_V0" ]; then

ENVIRONMENT="DLSN_V0"

else

echo "Unmatched configuration: $CONFIGURATION"
exit 1

fi

ENVIRONMENT_TEMPLATE_DATA_PATH="${PROJECT_DIR}/lib/DLSLibrary/env/$ENVIRONMENT"
ENVIRONMENT_TARGET_DATA_PATH="${PROJECT_DIR}/env"

# Copy environment specific app config
cp $ENVIRONMENT_TEMPLATE_DATA_PATH/DLSAppConfig_$ENVIRONMENT.m $ENVIRONMENT_TARGET_DATA_PATH/DLSAppConfig.m