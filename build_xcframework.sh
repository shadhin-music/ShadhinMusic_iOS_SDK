#!/bin/bash

# Configuration
PROJECT_NAME="Shadhin_Gp"
SCHEME_NAME="Shadhin_Gp"
OUTPUT_DIR="$(pwd)/output"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "${GREEN}🚀 Starting XCFramework build process...${NC}"
echo "${YELLOW}Project: ${PROJECT_NAME}${NC}"
echo "${YELLOW}Scheme: ${SCHEME_NAME}${NC}"
echo ""

# Clean output directory
echo "${GREEN}🧹 Cleaning output directory...${NC}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Archive for iOS Device
echo ""
echo "${GREEN}📱 Building for iOS Device...${NC}"
xcodebuild archive \
  -scheme "${SCHEME_NAME}" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "${OUTPUT_DIR}/${PROJECT_NAME}.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  | xcpretty || exit 1

if [ $? -ne 0 ]; then
    echo "${RED}❌ iOS Device build failed${NC}"
    exit 1
fi
echo "${GREEN}✅ iOS Device build completed${NC}"

# Archive for iOS Simulator
echo ""
echo "${GREEN}💻 Building for iOS Simulator...${NC}"
xcodebuild archive \
  -scheme "${SCHEME_NAME}" \
  -configuration Release \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "${OUTPUT_DIR}/${PROJECT_NAME}-sim.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  | xcpretty || exit 1

if [ $? -ne 0 ]; then
    echo "${RED}❌ iOS Simulator build failed${NC}"
    exit 1
fi
echo "${GREEN}✅ iOS Simulator build completed${NC}"

# Create XCFramework
echo ""
echo "${GREEN}📦 Creating XCFramework...${NC}"
xcodebuild -create-xcframework \
  -framework "${OUTPUT_DIR}/${PROJECT_NAME}.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
  -framework "${OUTPUT_DIR}/${PROJECT_NAME}-sim.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
  -output "${OUTPUT_DIR}/${PROJECT_NAME}.xcframework"

if [ $? -ne 0 ]; then
    echo "${RED}❌ XCFramework creation failed${NC}"
    exit 1
fi

echo ""
echo "${GREEN}✅ XCFramework created successfully!${NC}"
echo "${GREEN}📍 Location: ${OUTPUT_DIR}/${PROJECT_NAME}.xcframework${NC}"
echo ""

# Optional: Open output folder
echo "${YELLOW}Opening output folder...${NC}"
open "${OUTPUT_DIR}"
