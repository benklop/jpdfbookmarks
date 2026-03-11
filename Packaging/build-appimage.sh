#!/bin/sh

#
# build-appimage.sh
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

# Extract version from properties file
PROP_FILE=../jpdfbookmarks_core/src/it/flavianopetrocchi/jpdfbookmarks/jpdfbookmarks.properties
VERSION=$(sed '/^\#/d' ${PROP_FILE} | grep 'VERSION'  | tail -n 1 | sed 's/^.*=//')

APP_NAME=JPdfBookmarks
APPDIR_NAME=${APP_NAME}.AppDir
APPIMAGE_NAME=jpdfbookmarks-${VERSION}-x86_64.AppImage

echo "Building AppImage for ${APP_NAME} version ${VERSION}..."

# Check if the project has been built
if [ ! -f ../jpdfbookmarks_core/dist/jpdfbookmarks.jar ]; then
  echo ""
  echo "ERROR: Project has not been built yet."
  echo ""
  echo "Looking for: ../jpdfbookmarks_core/dist/jpdfbookmarks.jar"
  echo "Current directory: $(pwd)"
  echo ""
  echo "Directory contents:"
  ls -la ../jpdfbookmarks_core/ 2>/dev/null || echo "jpdfbookmarks_core directory not found"
  echo ""
  if [ -d ../jpdfbookmarks_core/dist ]; then
    echo "Contents of dist directory:"
    ls -la ../jpdfbookmarks_core/dist/
  else
    echo "dist directory does not exist"
  fi
  echo ""
  echo "Please build the project first by running:"
  echo "  cd jpdfbookmarks_core"
  echo "  ant jar"
  echo ""
  echo "Or build all projects with:"
  echo "  cd jpdfbookmarks_core"
  echo "  ant -f nbbuild.xml"
  echo ""
  exit 1
fi

# Clean up previous build
rm -rf ${APPDIR_NAME}
rm -f ${APPIMAGE_NAME}

# Create AppDir structure
mkdir -p ${APPDIR_NAME}/usr/bin
mkdir -p ${APPDIR_NAME}/usr/lib/jpdfbookmarks
mkdir -p ${APPDIR_NAME}/usr/share/applications
mkdir -p ${APPDIR_NAME}/usr/share/icons/hicolor/256x256/apps

# Copy main JAR
echo "Copying JAR files..."
cp ../jpdfbookmarks_core/dist/jpdfbookmarks.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/

# Copy dependency JARs
cp ../Colors/dist/Colors.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../Utilities/dist/Utilities.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../jpdfbookmarks_graphics/dist/jpdfbookmarks_graphics.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../jpdfbookmarks_languages/dist/jpdfbookmarks_languages.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../iTextBookmarksConverter/dist/iTextBookmarksConverter.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../Bookmark/dist/Bookmark.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../iText-2.1.7-patched/dist/iText-2.1.7-patched.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../CollapsingPanel/dist/CollapsingPanel.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../ResourceHelper/dist/ResourceHelper.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/

# Copy external library JARs
cp ../jpdfbookmarks_lib/*.jar ${APPDIR_NAME}/usr/lib/jpdfbookmarks/

# Copy icon
echo "Copying icon..."
cp ../jpdfbookmarks_graphics/artwork/jpdfbookmarks.png ${APPDIR_NAME}/usr/share/icons/hicolor/256x256/apps/jpdfbookmarks.png
cp ../jpdfbookmarks_graphics/artwork/jpdfbookmarks.png ${APPDIR_NAME}/jpdfbookmarks.png

# Create launcher script
echo "Creating launcher script..."
cat > ${APPDIR_NAME}/usr/bin/jpdfbookmarks << 'EOF'
#!/bin/sh

JAR_NAME=jpdfbookmarks.jar
JVM_OPTIONS="-Xms64m -Xmx512m"

SCRIPT_DIR=$(cd $(dirname "$0")/../lib/jpdfbookmarks; pwd)

# Build classpath with all JARs
CLASSPATH="$SCRIPT_DIR/$JAR_NAME"
for jar in "$SCRIPT_DIR"/*.jar; do
  CLASSPATH="$CLASSPATH:$jar"
done

if [ -n "$JAVA_HOME" ]; then
  "$JAVA_HOME/bin/java" $JVM_OPTIONS -cp "$CLASSPATH" it.flavianopetrocchi.jpdfbookmarks.JPdfBookmarks "$@"
else
  java $JVM_OPTIONS -cp "$CLASSPATH" it.flavianopetrocchi.jpdfbookmarks.JPdfBookmarks "$@"
fi
EOF

chmod +x ${APPDIR_NAME}/usr/bin/jpdfbookmarks

# Create AppRun script
echo "Creating AppRun script..."
cat > ${APPDIR_NAME}/AppRun << 'EOF'
#!/bin/sh

APPDIR=$(dirname "$(readlink -f "$0")")

# Check if Java is available
if ! command -v java >/dev/null 2>&1; then
  if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    JAVA_CMD="$JAVA_HOME/bin/java"
  else
    zenity --error --text="Java Runtime Environment (JRE) 6 or later is required to run JPdfBookmarks.\n\nPlease install Java and try again." 2>/dev/null || \
    echo "ERROR: Java Runtime Environment (JRE) 6 or later is required to run JPdfBookmarks." >&2
    exit 1
  fi
else
  JAVA_CMD="java"
fi

JAR_NAME=jpdfbookmarks.jar
JVM_OPTIONS="-Xms64m -Xmx512m"

# Build classpath with all JARs
CLASSPATH="$APPDIR/usr/lib/jpdfbookmarks/$JAR_NAME"
for jar in "$APPDIR"/usr/lib/jpdfbookmarks/*.jar; do
  CLASSPATH="$CLASSPATH:$jar"
done

exec "$JAVA_CMD" $JVM_OPTIONS -cp "$CLASSPATH" it.flavianopetrocchi.jpdfbookmarks.JPdfBookmarks "$@"
EOF

chmod +x ${APPDIR_NAME}/AppRun

# Create .desktop file
echo "Creating desktop entry..."
cat > ${APPDIR_NAME}/usr/share/applications/jpdfbookmarks.desktop << EOF
[Desktop Entry]
Type=Application
Name=JPdfBookmarks
Comment=Create and edit bookmarks on existing PDF files
Exec=jpdfbookmarks %F
Icon=jpdfbookmarks
Categories=Office;Viewer;
MimeType=application/pdf;
Terminal=false
StartupNotify=true
EOF

# Copy .desktop file to AppDir root
cp ${APPDIR_NAME}/usr/share/applications/jpdfbookmarks.desktop ${APPDIR_NAME}/

# Copy README and LICENSE
cp ../README ${APPDIR_NAME}/usr/lib/jpdfbookmarks/
cp ../COPYING ${APPDIR_NAME}/usr/lib/jpdfbookmarks/

# Check if appimagetool is available
if ! command -v appimagetool >/dev/null 2>&1; then
  echo ""
  echo "WARNING: appimagetool not found in PATH."
  echo "To create the AppImage, you need to install appimagetool."
  echo ""
  echo "You can download it from:"
  echo "https://github.com/AppImage/AppImageKit/releases"
  echo ""
  echo "Or install it with:"
  echo "  wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
  echo "  chmod +x appimagetool-x86_64.AppImage"
  echo "  sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool"
  echo ""
  echo "AppDir has been created at: ${APPDIR_NAME}"
  echo "Run appimagetool manually to create the AppImage:"
  echo "  appimagetool ${APPDIR_NAME} ${APPIMAGE_NAME}"
  exit 1
fi

# Build AppImage
echo "Building AppImage..."
ARCH=x86_64 appimagetool ${APPDIR_NAME} ${APPIMAGE_NAME}

if [ $? -eq 0 ]; then
  echo ""
  echo "SUCCESS: AppImage created at ${APPIMAGE_NAME}"
  echo ""
  # Clean up AppDir
  rm -rf ${APPDIR_NAME}
else
  echo ""
  echo "ERROR: Failed to create AppImage"
  echo "AppDir has been preserved at: ${APPDIR_NAME}"
  exit 1
fi

cd ${PREV_DIR}
