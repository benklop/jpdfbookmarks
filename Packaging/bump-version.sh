#!/bin/sh

#
# bump-version.sh
#
# Update VERSION in jpdfbookmarks properties file.
# Usage:
#   ./bump-version.sh 2.6
# Input normalization:
#   2.6 -> 2.6.0
#

set -e

SCRIPTDIR=$(cd "$(dirname "$0")"; pwd)
PREV_DIR=$(pwd)

cd "${SCRIPTDIR}"

PROP_FILE="../jpdfbookmarks_core/src/it/flavianopetrocchi/jpdfbookmarks/jpdfbookmarks.properties"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <new-version>"
  echo "Example: $0 2.6"
  exit 1
fi

NEW_VERSION="$1"

if ! printf '%s' "$NEW_VERSION" | grep -Eq '^[0-9]+(\.[0-9]+)*$'; then
  echo "ERROR: Invalid version '$NEW_VERSION'."
  echo "Expected numeric dot format like 2.6 or 2.6.0"
  exit 1
fi

NORMALIZED_VERSION="$NEW_VERSION"
DOT_COUNT=$(printf '%s' "$NEW_VERSION" | awk -F'.' '{print NF - 1}')
if [ "$DOT_COUNT" -eq 1 ]; then
  NORMALIZED_VERSION="${NEW_VERSION}.0"
fi

if [ ! -f "$PROP_FILE" ]; then
  echo "ERROR: Version file not found: $PROP_FILE"
  exit 1
fi

OLD_VERSION=$(sed '/^#/d' "$PROP_FILE" | grep '^VERSION=' | tail -n 1 | sed 's/^.*=//')

if [ "$OLD_VERSION" = "$NORMALIZED_VERSION" ]; then
  echo "Version already set to $NORMALIZED_VERSION"
  cd "$PREV_DIR"
  exit 0
fi

TMP_FILE=$(mktemp)
awk -v new_version="$NORMALIZED_VERSION" '
  BEGIN { updated = 0 }
  /^VERSION=/ {
    print "VERSION=" new_version
    updated = 1
    next
  }
  { print }
  END {
    if (updated == 0) {
      exit 2
    }
  }
' "$PROP_FILE" > "$TMP_FILE" || {
  rm -f "$TMP_FILE"
  echo "ERROR: Could not update VERSION entry in $PROP_FILE"
  exit 1
}

mv "$TMP_FILE" "$PROP_FILE"

echo "Version bumped: $OLD_VERSION -> $NORMALIZED_VERSION"

cd "$PREV_DIR"
