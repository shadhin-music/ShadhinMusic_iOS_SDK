#!/bin/bash

# ==========================================
# ShadhinMusic iOS SDK — Auto Update Script
# Usage: ./update_sdk.sh "commit message" "version"
# Example: ./update_sdk.sh "feat: add player" "1.0.1"
# ==========================================

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check arguments
if [ -z "$1" ] || [ -z "$2" ]; then
  echo -e "${RED}❌ Missing arguments!${NC}"
  echo -e "Usage: ./update_sdk.sh ${YELLOW}\"commit message\" \"version\"${NC}"
  echo -e "Example: ./update_sdk.sh ${YELLOW}\"feat: add player\" \"1.0.1\"${NC}"
  exit 1
fi

COMMIT_MSG=$1
VERSION=$2
SOURCE="/Users/mrt/Desktop/Office work/MYGP/gpmusicios"
SDK=~/Desktop/ShadhinMusic_iOS_SDK

echo -e "${YELLOW}🔄 Step 1: Syncing latest files...${NC}"
cp -r "$SOURCE/Shadhin_Gp" "$SDK/"
cp "$SOURCE/Package.swift" "$SDK/"
echo -e "${GREEN}✅ Files synced!${NC}"

echo -e "${YELLOW}📦 Step 2: Building package...${NC}"
cd "$SDK"
swift build
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Build failed! Fix errors before publishing.${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Build successful!${NC}"

echo -e "${YELLOW}🧪 Step 3: Running tests...${NC}"
swift test
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Tests failed! Fix before publishing.${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Tests passed!${NC}"

echo -e "${YELLOW}💾 Step 4: Committing changes...${NC}"
git add .
git commit -m "$COMMIT_MSG"
git push origin main
echo -e "${GREEN}✅ Code pushed to GitHub!${NC}"

echo -e "${YELLOW}🏷️  Step 5: Tagging version $VERSION...${NC}"
git tag $VERSION
git push origin $VERSION
echo -e "${GREEN}✅ Version $VERSION published!${NC}"

echo ""
echo -e "${GREEN}🎉 SUCCESS! SDK version $VERSION is live!${NC}"
echo -e "🔗 ${YELLOW}https://github.com/shadhin-music/ShadhinMusic_iOS_SDK${NC}"
