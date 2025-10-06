#!/bin/bash
# Quick verification that all required files are in place

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

check() {
    if [ -f "$1" ] || [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        return 1
    fi
}

echo -e "${BLUE}Verifying TAKERMAN repository structure...${NC}"
echo ""

errors=0

# Core files
echo "Core files:"
check "build.sh" || ((errors++))
check "setup.sh" || ((errors++))
check "docker-compose.yml" || ((errors++))
check "README.md" || ((errors++))

echo ""
echo "Config directory:"
check "configs/preseed.cfg" || ((errors++))

echo ""
echo "Directories:"
check "configs" || ((errors++))
check "docs" || ((errors++))
check "old_backup" || ((errors++))

echo ""
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ All files in place!${NC}"
    echo ""
    echo "Ready to build:"
    echo "  bash build.sh"
    exit 0
else
    echo -e "${RED}✗ $errors file(s) missing!${NC}"
    exit 1
fi
