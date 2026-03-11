#!/bin/sh

#
# build-all-and-appimage.sh
# 
# Builds all JPdfBookmarks components and creates an AppImage
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

cd ${SCRIPTDIR}/..

echo "========================================"
echo "Building JPdfBookmarks Components"
echo "========================================"
echo ""

# Function to build a component
build_component() {
  COMPONENT_NAME=$1
  echo "Building ${COMPONENT_NAME}..."
  cd ${COMPONENT_NAME}
  if [ ! -f build.xml ]; then
    echo "ERROR: build.xml not found in ${COMPONENT_NAME}"
    cd ..
    return 1
  fi
  ant jar
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build ${COMPONENT_NAME}"
    cd ..
    return 1
  fi
  cd ..
  echo ""
}

# Build all components in order
# Note: iText-2.1.7-patched uses nbbuild.xml instead of build.xml
echo "Building iText-2.1.7-patched..."
cd iText-2.1.7-patched
ant -f nbbuild.xml jar
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to build iText-2.1.7-patched"
  exit 1
fi
cd ..
echo ""

build_component "Bookmark" || exit 1
build_component "Colors" || exit 1
build_component "Utilities" || exit 1
build_component "ResourceHelper" || exit 1
build_component "CollapsingPanel" || exit 1
build_component "jpdfbookmarks_graphics" || exit 1
build_component "jpdfbookmarks_languages" || exit 1
build_component "iTextBookmarksConverter" || exit 1
build_component "jpdfbookmarks_core" || exit 1

echo "========================================"
echo "Build Complete!"
echo "========================================"
echo ""

# Now build the AppImage
cd ${SCRIPTDIR}
echo "Starting AppImage build..."
echo ""

./build-appimage.sh

cd ${PREV_DIR}
