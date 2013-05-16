#!/bin/bash

# Enable debugging
#set -x

#
# Global parameters
#
PROJECT_ID=$1
DLS_LIBRARY_ID=IPLIB_DLS
DT_LIBRARY_ID=IPDTL

SVN_BASE_PATH="https://supi.telekom.de/svn"
CHECKOUT_DIR="/tmp/release-branch-checkout-dir"

DTLIBRARY_PARENT_DIR_IN_DLSLIBRARY="$CHECKOUT_DIR/$DLS_LIBRARY_ID/DLSLibrary/lib"
DLSLIBRARY_PARENT_DIR_IN_PROJECT="$CHECKOUT_DIR/$PROJECT_ID/project/lib"

#
# Input checking
#
LeaveWithExitCode() {
	echo
	echo "MISSING PARAMETER!!!"
	
	echo
    echo "Usage: ${1} <repo_key> <project_release_version> <dlslib_release_version> <dtlib_release_version>"
	echo "Example: ${1} IPMCN 9.9.9 1.0.0 5.4.2"

	if [ -n $2 ]; then
		echo
		echo "Existing Branches of Project: "
		svn list https://supi.telekom.de/svn/$2/branches
	fi
	
	echo
	echo "Existing Branches of DLSLibrary: "
	svn list https://supi.telekom.de/svn/$DLS_LIBRARY_ID/branches

	echo
	echo "Existing Branches of DTLibrary: "
	svn list https://supi.telekom.de/svn/$DT_LIBRARY_ID/branches
	
	exit 1
}

if [ -z $PROJECT_ID ]; then
	LeaveWithExitCode $0;
fi
if [ -z $2 ]; then
	LeaveWithExitCode $0 $PROJECT_ID;
fi
if [ -z $3 ]; then
	LeaveWithExitCode $0 $PROJECT_ID;
fi
if [ -z $4 ]; then
	LeaveWithExitCode $0 $PROJECT_ID;
fi

#
# Global parameters
#
PROJECT_RELEASE_VERSION=$2
PROJECT_TRUNK_PATH="$SVN_BASE_PATH/$PROJECT_ID/trunk/BASE"
PROJECT_RELEASE_BRANCH="v${PROJECT_RELEASE_VERSION}_release_${PROJECT_ID}"
PROJECT_RELEASE_BRANCH_PATH="$SVN_BASE_PATH/$PROJECT_ID/branches/$PROJECT_RELEASE_BRANCH"

DLS_LIB_RELEASE_VERSION=$3
DLS_LIB_TRUNK_PATH="$SVN_BASE_PATH/$DLS_LIBRARY_ID/trunk"
DLS_LIB_RELEASE_BRANCH="v${DLS_LIB_RELEASE_VERSION}_release_${PROJECT_ID}_v${PROJECT_RELEASE_VERSION}"
DLS_LIB_RELEASE_BRANCH_PATH="$SVN_BASE_PATH/$DLS_LIBRARY_ID/branches/$DLS_LIB_RELEASE_BRANCH"

DT_LIB_RELEASE_VERSION=$4
DT_LIB_TRUNK_PATH="$SVN_BASE_PATH/$DT_LIBRARY_ID/branches/develop"
DT_LIB_RELEASE_BRANCH="v${DT_LIB_RELEASE_VERSION}_release_${PROJECT_ID}_v${PROJECT_RELEASE_VERSION}"
DT_LIB_RELEASE_BRANCH_PATH="$SVN_BASE_PATH/$DT_LIBRARY_ID/branches/$DT_LIB_RELEASE_BRANCH"

#
# Determine HEAD revisions and release messages of project, DLSLibrary and 
# DTLibrary
#
DLS_LIB_REV=$(svn info $SVN_BASE_PATH/$DLS_LIBRARY_ID/trunk |grep 'Revision: ' |cut -d ' ' -f2)
DLS_LIB_RELEASE_MSG="Release DLSLibrary version $DLS_LIB_RELEASE_VERSION with BASE revision $DLS_LIB_REV for project $PROJECT_ID."

DT_LIB_REV=$(svn info $SVN_BASE_PATH/$DT_LIBRARY_ID/branches/develop |grep 'Revision: ' |cut -d ' ' -f2)
DT_LIB_RELEASE_MSG="Release $PROJECT_ID version $DT_LIB_RELEASE_VERSION with BASE revision $DT_LIB_REV for project $PROJECT_ID."

PROJECT_REV=$(svn info $SVN_BASE_PATH/$PROJECT_ID/trunk/BASE |grep 'Revision: ' |cut -d ' ' -f2)
PROJECT_RELEASE_MSG="Release $PROJECT_ID version $PROJECT_RELEASE_VERSION with BASE revision $PROJECT_REV."



#
# Create release branches of Project, DLSLibrary and DTLibrary
#
echo -n "Copy $PROJECT_TRUNK_PATH@$PROJECT_REV to $PROJECT_RELEASE_BRANCH_PATH"
svn copy -m "$PROJECT_RELEASE_MSG" $PROJECT_TRUNK_PATH@$PROJECT_REV $PROJECT_RELEASE_BRANCH_PATH
echo
echo -n "Copy $DLS_LIB_TRUNK_PATH@$DLS_LIB_REV $DLS_LIB_RELEASE_BRANCH_PATH"
svn copy -m "$DLS_LIB_RELEASE_MSG" $DLS_LIB_TRUNK_PATH@$DLS_LIB_REV $DLS_LIB_RELEASE_BRANCH_PATH
echo
echo -n "Copy $DT_LIB_TRUNK_PATH@$DT_LIB_REV $DT_LIB_RELEASE_BRANCH_PATH"
svn copy -m "$DT_LIB_RELEASE_MSG" $DT_LIB_TRUNK_PATH@$DT_LIB_REV $DT_LIB_RELEASE_BRANCH_PATH
echo

#
# Checkout the DLSLibrary release branch and set the external references to
# release version of DTLibrary
#
echo "Checkout $DLS_LIB_RELEASE_BRANCH_PATH and set svn:externals"
svn -q checkout $DLS_LIB_RELEASE_BRANCH_PATH $CHECKOUT_DIR/$DLS_LIBRARY_ID

if [ ! -d $DTLIBRARY_PARENT_DIR_IN_DLSLIBRARY ]; then
	echo "Fail!!!     Directory $DTLIBRARY_PARENT_DIR_IN_DLSLIBRARY does not exist! Delete created release branches and exit..."

	svn -q delete -m "delete branch becausean error occurred during branching ..." $DT_LIB_RELEASE_BRANCH_PATH
	svn -q delete -m "delete branch becausean error occurred during branching ..." $DLS_LIB_RELEASE_BRANCH_PATH
	svn -q delete -m "delete branch becausean error occurred during branching ..." $PROJECT_RELEASE_BRANCH_PATH

	rm -rf $CHECKOUT_DIR

	exit 1
fi

svn -q propset svn:externals "DTLibrary $DT_LIB_RELEASE_BRANCH_PATH/DTLibrary" $DTLIBRARY_PARENT_DIR_IN_DLSLIBRARY
svn commit -m "Switch to release version of DTLibrary" $CHECKOUT_DIR/$DLS_LIBRARY_ID
echo 

#
# Checkout the PROJECT release branch and set the external references to
# release version of DLSLibrary
#

echo "Checkout $PROJECT_RELEASE_BRANCH_PATH and set svn:externals"
svn -q checkout $PROJECT_RELEASE_BRANCH_PATH $CHECKOUT_DIR/$PROJECT_ID

if [ ! -d $DLSLIBRARY_PARENT_DIR_IN_PROJECT ]; then
	echo "Fail!!!     Directory $DLSLIBRARY_PARENT_DIR_IN_PROJECT does not exist! Delete created release branches and exit..."

	svn -q delete -m "delete branch becausean error occurred during branching ..." $DT_LIB_RELEASE_BRANCH_PATH
	svn -q delete -m "delete branch becausean error occurred during branching ..." $DLS_LIB_RELEASE_BRANCH_PATH
	svn -q delete -m "delete branch becausean error occurred during branching ..." $PROJECT_RELEASE_BRANCH_PATH

	rm -rf $CHECKOUT_DIR

	exit 1
fi

svn -q propset svn:externals "DLSLibrary $DLS_LIB_RELEASE_BRANCH_PATH/DLSLibrary" $DLSLIBRARY_PARENT_DIR_IN_PROJECT
svn commit -m "Switch to release version of DLSLibrary" $CHECKOUT_DIR/$PROJECT_ID
echo 

#
# Result LOG
#

GARD_PROJECT_REV=$(svn info $SVN_BASE_PATH/$PROJECT_ID/trunk/BASE |grep 'Revision: ' |cut -d ' ' -f2)

echo 
echo
echo "Success!!!      Released Revision Number of $PROJECT_ID for GARD Delivery: $GARD_PROJECT_REV"
echo

#
# CLEANUP
#

rm -rf $CHECKOUT_DIR

# DEBUG: DELETE BRANCHES (CLEANUP)
#svn -q delete -m "delete branch becausean error occurred during branching ..." $DT_LIB_RELEASE_BRANCH_PATH
#svn -q delete -m "delete branch becausean error occurred during branching ..." $DLS_LIB_RELEASE_BRANCH_PATH
#svn -q delete -m "delete branch becausean error occurred during branching ..." $PROJECT_RELEASE_BRANCH_PATH
