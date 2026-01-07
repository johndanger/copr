#!/bin/bash
#
# Setup Copr Packages Script
#
# This script configures all packages in the packages/ directory
# as SCM builds in your Copr project.
#
# Usage: ./setup-copr-packages.sh YOUR_PROJECT YOUR_GITHUB_USERNAME

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if copr-cli is installed
if ! command -v copr-cli &> /dev/null; then
    echo -e "${RED}Error: copr-cli is not installed${NC}"
    echo "Install it with: sudo dnf install -y copr-cli"
    exit 1
fi

# Check if copr-cli is configured
if [ ! -f ~/.config/copr ]; then
    echo -e "${RED}Error: copr-cli is not configured${NC}"
    echo "Configure it by running: copr-cli --config"
    echo "Or visit: https://copr.fedorainfracloud.org/api/"
    exit 1
fi

# Get arguments
COPR_PROJECT="$1"
GITHUB_USERNAME="$2"

if [ -z "$COPR_PROJECT" ] || [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${YELLOW}Usage: $0 COPR_PROJECT GITHUB_USERNAME${NC}"
    echo ""
    echo "Example: $0 username/projectname myusername"
    echo ""
    echo "COPR_PROJECT: Your Copr project identifier (format: username/projectname)"
    echo "GITHUB_USERNAME: Your GitHub username"
    exit 1
fi

REPO_URL="https://github.com/${GITHUB_USERNAME}/copr"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Copr Package Configuration Setup               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Copr Project:${NC} $COPR_PROJECT"
echo -e "${BLUE}GitHub Repo:${NC} $REPO_URL"
echo ""

# Check if packages directory exists
if [ ! -d "packages" ]; then
    echo -e "${RED}Error: packages/ directory not found${NC}"
    echo "Run this script from the root of your copr repository"
    exit 1
fi

# Count packages
PACKAGE_COUNT=$(ls -1 packages | wc -l)
echo -e "${BLUE}Found $PACKAGE_COUNT package(s) to configure${NC}"
echo ""

# Confirm before proceeding
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Track results
SUCCESS_COUNT=0
FAIL_COUNT=0
SKIPPED_COUNT=0

# Process each package
for package_dir in packages/*/; do
    # Get package name from directory
    package_name=$(basename "$package_dir")
    spec_file="packages/${package_name}/${package_name}.spec"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Package:${NC} $package_name"

    # Check if spec file exists
    if [ ! -f "$spec_file" ]; then
        echo -e "${YELLOW}⚠ Warning: Spec file not found: $spec_file${NC}"
        echo -e "${YELLOW}  Skipping...${NC}"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        echo ""
        continue
    fi

    echo -e "${BLUE}Spec file:${NC} $spec_file"

    # Check if package already exists in Copr
    if copr-cli get-package "$COPR_PROJECT" --name "$package_name" &> /dev/null; then
        echo -e "${YELLOW}ℹ Package already exists in Copr${NC}"
        read -p "Update configuration? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}  Skipped${NC}"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
            echo ""
            continue
        fi
        ACTION="edit"
    else
        echo -e "${GREEN}✓ Package not found in Copr, will create new${NC}"
        ACTION="add"
    fi

    # Configure package
    echo -e "${BLUE}Configuring as SCM build...${NC}"

    if [ "$ACTION" = "add" ]; then
        if copr-cli add-package-scm "$COPR_PROJECT" \
            --name "$package_name" \
            --clone-url "$REPO_URL" \
            --spec "$spec_file" \
            --type git \
            --method make_srpm \
            --webhook-rebuild on; then
            echo -e "${GREEN}✓ Successfully added $package_name${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo -e "${RED}✗ Failed to add $package_name${NC}"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        if copr-cli edit-package-scm "$COPR_PROJECT" \
            --name "$package_name" \
            --clone-url "$REPO_URL" \
            --spec "$spec_file" \
            --type git \
            --method make_srpm \
            --webhook-rebuild on; then
            echo -e "${GREEN}✓ Successfully updated $package_name${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo -e "${RED}✗ Failed to update $package_name${NC}"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    fi

    echo ""
done

# Summary
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                        Summary                           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Success: $SUCCESS_COUNT${NC}"
echo -e "${RED}✗ Failed:  $FAIL_COUNT${NC}"
echo -e "${YELLOW}⊘ Skipped: $SKIPPED_COUNT${NC}"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo -e "${GREEN}Packages configured successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Verify packages: copr-cli list-packages $COPR_PROJECT"
    echo "2. Configure GitHub secrets (COPR_CONFIG, COPR_PROJECT)"
    echo "3. Test workflow: Go to Actions → Trigger Copr Builds → Run workflow"
    echo ""
    echo "View your packages at:"
    echo "https://copr.fedorainfracloud.org/coprs/$COPR_PROJECT/packages/"
fi

if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}Some packages failed to configure.${NC}"
    echo "Check the error messages above and try again."
    exit 1
fi

exit 0
