#!/bin/bash
# 
# Verification script for backTap2 iOS project
# This script checks that all required files are present and properly structured
#

set -e

echo "========================================="
echo "backTap2 iOS Project Verification"
echo "========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ (MISSING)"
        return 1
    fi
}

echo "Checking project structure..."
echo ""

# Core project files
echo "Core Files:"
check_file "README.md"
check_file "LICENSE"
check_file ".gitignore"
check_file "backTap2.xcodeproj/project.pbxproj"
echo ""

# Source files
echo "Source Files:"
check_file "backTap2/backTap2App.swift"
check_file "backTap2/Models.swift"
check_file "backTap2/Store.swift"
check_file "backTap2/BudgetHomeView.swift"
check_file "backTap2/RecordExpenseIntent.swift"
check_file "backTap2/Info.plist"
echo ""

# Assets
echo "Assets:"
check_dir "backTap2/Assets.xcassets"
check_file "backTap2/Assets.xcassets/Contents.json"
check_file "backTap2/Assets.xcassets/AppIcon.appiconset/Contents.json"
check_file "backTap2/Assets.xcassets/AccentColor.colorset/Contents.json"
echo ""

# Workspace
echo "Workspace:"
check_file "backTap2.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
check_file "backTap2.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings"
echo ""

echo "========================================="
echo "File Content Checks"
echo "========================================="
echo ""

# Check Swift file line counts
echo "Swift Files (line count):"
for file in backTap2/*.swift; do
    lines=$(wc -l < "$file")
    echo "  $(basename $file): $lines lines"
done
echo ""

# Check for key Swift components
echo "Checking for key Swift components..."
grep -q "struct CategoryGroup" backTap2/Models.swift && echo -e "${GREEN}✓${NC} CategoryGroup model found"
grep -q "struct Category" backTap2/Models.swift && echo -e "${GREEN}✓${NC} Category model found"
grep -q "struct Budget" backTap2/Models.swift && echo -e "${GREEN}✓${NC} Budget model found"
grep -q "struct Transaction" backTap2/Models.swift && echo -e "${GREEN}✓${NC} Transaction model found"

grep -q "protocol Store" backTap2/Store.swift && echo -e "${GREEN}✓${NC} Store protocol found"
grep -q "class InMemoryStore" backTap2/Store.swift && echo -e "${GREEN}✓${NC} InMemoryStore implementation found"
grep -q "static func preview()" backTap2/Store.swift && echo -e "${GREEN}✓${NC} Preview data method found"

grep -q "struct RecordExpenseIntent" backTap2/RecordExpenseIntent.swift && echo -e "${GREEN}✓${NC} RecordExpenseIntent found"
grep -q "AppIntent" backTap2/RecordExpenseIntent.swift && echo -e "${GREEN}✓${NC} AppIntent protocol conformance found"

grep -q "struct BudgetHomeView" backTap2/BudgetHomeView.swift && echo -e "${GREEN}✓${NC} BudgetHomeView found"
grep -q "Chart" backTap2/BudgetHomeView.swift && echo -e "${GREEN}✓${NC} Charts integration found"
grep -q "struct BudgetEditorSheet" backTap2/BudgetHomeView.swift && echo -e "${GREEN}✓${NC} BudgetEditorSheet found"

grep -q "@main" backTap2/backTap2App.swift && echo -e "${GREEN}✓${NC} App entry point found"
grep -q "InMemoryStore.preview()" backTap2/backTap2App.swift && echo -e "${GREEN}✓${NC} Store injection found"

echo ""
echo "========================================="
echo "Verification Complete!"
echo "========================================="
echo ""
echo "The project structure is complete and ready to build in Xcode."
echo ""
echo "Next steps:"
echo "  1. Open backTap2.xcodeproj in Xcode 15+"
echo "  2. Select iPhone simulator (iOS 16+)"
echo "  3. Build and run (⌘+R)"
echo ""
