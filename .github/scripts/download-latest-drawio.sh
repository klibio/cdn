#!/usr/bin/env bash
# Download the latest drawio-desktop Windows zip release from GitHub

set -e

REPO="jgraph/drawio-desktop"
PAGE_URL="https://github.com/$REPO/releases/latest"

# Get the redirect URL for the latest release
LATEST_URL=$(curl -s -L -o /dev/null -w %{url_effective} "$PAGE_URL")
LATEST_TAG=$(basename "$LATEST_URL")
# Remove leading 'v' if present
LATEST_TAG_NO_V=${LATEST_TAG#v}

OS="$(uname -s)"
WORKDIR="_workdir"
mkdir -p "$WORKDIR"
if [[ "$OS" == MINGW* || "$OS" == CYGWIN* || "$OS" == MSYS* || "$OS" == Windows* ]]; then
	# Windows
	FILE_NAME="draw.io-${LATEST_TAG_NO_V}-windows.zip"
	DOWNLOAD_URL="https://github.com/$REPO/releases/download/${LATEST_TAG}/${FILE_NAME}"
	echo "Downloading $FILE_NAME from $DOWNLOAD_URL ..."
	curl -L -o "$WORKDIR/$FILE_NAME" "$DOWNLOAD_URL"
	echo "Downloaded $FILE_NAME to $WORKDIR"
		echo "Extracting $FILE_NAME ..."
		mkdir -p "$WORKDIR/drawio"
		unzip -o "$WORKDIR/$FILE_NAME" -d "$WORKDIR/drawio"
		echo "Extraction complete."
elif [[ "$OS" == Linux* ]]; then
	# Linux
	FILE_NAME="drawio-x86_64-${LATEST_TAG_NO_V}.AppImage"
	DOWNLOAD_URL="https://github.com/$REPO/releases/download/${LATEST_TAG}/${FILE_NAME}"
	echo "Downloading $FILE_NAME from $DOWNLOAD_URL ..."
	curl -sL -o "$WORKDIR/$FILE_NAME" "$DOWNLOAD_URL"
	echo "Downloaded $FILE_NAME to $WORKDIR"
else
	echo "Unsupported OS: $OS"
	exit 1
fi
