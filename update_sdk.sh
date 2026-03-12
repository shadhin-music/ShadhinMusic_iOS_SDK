#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./update_sdk.sh \"commit message\" \"version\""
  echo "Example: ./update_sdk.sh \"feat: new feature\" \"1.0.1\""
  exit 1
fi

COMMIT_MSG=$1
VERSION=$2
SOURCE="/Users/mrt/Desktop/Office work/MYGP/gpmusicios"
SDK="/Users/mrt/Desktop/ShadhinMusic_iOS_SDK"

echo "Step 1: Syncing files..."
cp -r "$SOURCE/Shadhin_Gp" "$SDK/"
cp "$SOURCE/Package.swift" "$SDK/"
echo "Files synced!"

echo "Step 2: Committing..."
cd "$SDK"
git add .
git commit -m "$COMMIT_MSG"
git push origin main
echo "Pushed to GitHub!"

echo "Step 3: Tagging $VERSION..."
git tag "$VERSION"
git push origin "$VERSION"

echo "Done! Version $VERSION is live!"
echo "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK"
