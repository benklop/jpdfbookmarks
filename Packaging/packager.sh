#!/bin/sh

#
# packager.sh
# 
# Copyright (c) 2010 Flaviano Petrocchi <flavianopetrocchi at gmail.com>.
# All rights reserved.
# 
# This file is part of JPdfBookmarks.
# 
# JPdfBookmarks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# JPdfBookmarks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with JPdfBookmarks.  If not, see <http://www.gnu.org/licenses/>.
#

SCRIPTDIR=$(cd $(dirname "$0"); pwd)
PREV_DIR=$(pwd)


cd ${SCRIPTDIR}

PROP_FILE=../jpdfbookmarks_core/src/it/flavianopetrocchi/jpdfbookmarks/jpdfbookmarks.properties
VERSION=$(sed '/^\#/d' ${PROP_FILE} | grep 'VERSION'  | tail -n 1 | sed 's/^.*=//')

NAME=jpdfbookmarks-${VERSION}
SRCNAME=jpdfbookmarks-src-${VERSION}

rm -f ${NAME}.zip
rm -f ${NAME}.tar
rm -f ${NAME}.tar.gz
rm -f -R ${NAME}

mkdir ${NAME}

cp jpdfbookmarks.exe ${NAME}
cp jpdfbookmarks_cli.exe ${NAME}               
# if the script is run from cygwin cp cannot write jpdfbookmarks.exe and 
# jpdfbookamarks in the same folder, we use the native windows xcopy
if [ -e /usr/bin/cygcheck ] 
then
	xcopy jpdfbookmarks ${NAME}
	xcopy jpdfbookmarks_cli ${NAME}
else 
 	cp jpdfbookmarks ${NAME}
	cp jpdfbookmarks_cli ${NAME}
fi
cp link_this_in_linux_path.sh ${NAME}
cp link_this_in_linux_path_cli.sh ${NAME}
cp ../jpdfbookmarks_core/dist/jpdfbookmarks.jar ${NAME}
cp ../README ${NAME}
cp ../COPYING ${NAME}
mkdir ${NAME}/lib

# Copy all dependency JARs
cp ../Colors/dist/Colors.jar ${NAME}/lib/
cp ../Utilities/dist/Utilities.jar ${NAME}/lib/
cp ../jpdfbookmarks_graphics/dist/jpdfbookmarks_graphics.jar ${NAME}/lib/
cp ../jpdfbookmarks_languages/dist/jpdfbookmarks_languages.jar ${NAME}/lib/
cp ../iTextBookmarksConverter/dist/iTextBookmarksConverter.jar ${NAME}/lib/
cp ../Bookmark/dist/Bookmark.jar ${NAME}/lib/
cp ../iText-2.1.7-patched/dist/iText-2.1.7-patched.jar ${NAME}/lib/
cp ../CollapsingPanel/dist/CollapsingPanel.jar ${NAME}/lib/
cp ../ResourceHelper/dist/ResourceHelper.jar ${NAME}/lib/

# Copy external library JARs
cp ../jpdfbookmarks_lib/*.jar ${NAME}/lib/

cp ../jpdfbookmarks_graphics/artwork/jpdfbookmarks.png ${NAME}

zip -r ${NAME}.zip ${NAME}
tar -cpvzf ${NAME}.tar.gz ${NAME}     

rm -f ${NAME}.tar
rm -f -R ${NAME}

# Create source package - handle both Git and SVN
if [ -d ../.git ]; then
  # Git repository - use git archive
  cd ..
  git archive --format=tar --prefix=${SRCNAME}/ HEAD | tar -x -C Packaging/
  cd ${SCRIPTDIR}
elif [ -d ../.svn ]; then
  # SVN repository - use svn export
  svn export .. ${SRCNAME}
else
  echo "Warning: Not a Git or SVN repository, skipping source package creation"
fi

if [ -d ${SRCNAME} ]; then
  zip -r ${SRCNAME}.zip ${SRCNAME}
  tar -cpzf ${SRCNAME}.tar.gz ${SRCNAME}      
  rm -f -R ${SRCNAME}
fi

cd ${PREV_DIR}
