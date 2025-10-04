#!/bin/bash

# Validation Script for Custom Debian ISO Builder
# This script validates the configuration files and dependencies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[VALIDATE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

validate_file_exists() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        log_success "$description exists: $(basename "$file")"
        return 0
    else
        log_error "$description missing: $file"
        return 1
    fi
}

validate_executable() {
    local file="$1"
    local description="$2"
    
    if validate_file_exists "$file" "$description"; then
        if [ -x "$file" ]; then
            log_success "$description is executable"
            return 0
        else
            log_warning "$description is not executable (will be fixed)"
            chmod +x "$file"
            return 0
        fi
    fi
    return 1
}

validate_preseed_config() {
    local preseed_file="$PROJECT_ROOT/configs/preseed.cfg"
    
    if ! validate_file_exists "$preseed_file" "Preseed configuration"; then
        return 1
    fi
    
    # Check for critical preseed settings
    local required_settings=(
        "d-i debian-installer/locale"
        "d-i netcfg/get_hostname"
        "d-i passwd/root-password"
        "d-i passwd/username"
        "d-i partman-auto/method"
        "d-i preseed/late_command"
    )
    
    for setting in "${required_settings[@]}"; do
        if grep -q "^$setting" "$preseed_file"; then
            log_success "Preseed setting found: $setting"
        else
            log_error "Missing preseed setting: $setting"
        fi
    done
}

validate_ai_setup_script() {
    local script_file="$PROJECT_ROOT/scripts/ai_setup_debian.sh"
    
    if ! validate_executable "$script_file" "AI setup script"; then
        return 1
    fi
    
    # Check for critical commands
    local critical_commands=(
        "apt-get update"
        "docker"
        "nvidia-smi"
        "systemctl"
    )
    
    for cmd in "${critical_commands[@]}"; do
        if grep -q "$cmd" "$script_file"; then
            log_success "AI setup includes: $cmd"
        else
            log_warning "AI setup might be missing: $cmd"
        fi
    done
}

validate_build_script() {
    local build_script="$PROJECT_ROOT/build_custom_iso.sh"
    
    validate_executable "$build_script" "Build script"
}

validate_directory_structure() {
    local required_dirs=(
        "$PROJECT_ROOT/configs"
        "$PROJECT_ROOT/scripts"
        "$PROJECT_ROOT/build"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_success "Directory exists: $(basename "$dir")"
        else
            log_error "Missing directory: $dir"
            mkdir -p "$dir"
            log_success "Created directory: $(basename "$dir")"
        fi
    done
}

check_system_dependencies() {
    local deps=("wget" "genisoimage" "syslinux-utils" "xorriso" "isolinux")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null || dpkg -l | grep -q "^ii.*$dep"; then
            log_success "Dependency available: $dep"
        else
            missing_deps+=("$dep")
            log_warning "Missing dependency: $dep"
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log "Install missing dependencies with:"
        echo "  sudo apt-get install ${missing_deps[*]}"
    fi
}

validate_credentials() {
    local preseed_file="$PROJECT_ROOT/configs/preseed.cfg"
    
    if [ -f "$preseed_file" ]; then
        # Check for default passwords
        if grep -q "takerman123" "$preseed_file"; then
            log_warning "Default passwords detected in preseed.cfg"
            log "Consider changing default passwords before building ISO"
        fi
        
        # Check for placeholder values
        if grep -q "your-hostname\\|your-domain" "$preseed_file"; then
            log_warning "Placeholder values detected in preseed.cfg"
            log "Update hostname and domain settings"
        fi
    fi
}

print_summary() {
    echo
    log_success "Validation completed!"
    echo
    echo -e "${GREEN}Next steps:${NC}"
    echo "  1. Review and customize configs/preseed.cfg if needed"
    echo "  2. Modify scripts/ai_setup_debian.sh for your requirements"
    echo "  3. Run ./build_custom_iso.sh to build the custom ISO"
    echo
    echo -e "${YELLOW}Security reminders:${NC}"
    echo "  - Change default passwords in preseed.cfg"
    echo "  - Review firewall and SSH settings"
    echo "  - Test the ISO in a VM before production use"
}

main() {
    log "Starting validation of ISO builder configuration..."
    echo
    
    validate_directory_structure
    validate_preseed_config  
    validate_ai_setup_script
    validate_build_script
    validate_file_exists "$PROJECT_ROOT/scripts/post_install.sh" "Post-install script"
    validate_credentials
    
    echo
    check_system_dependencies
    
    print_summary
}

main "$@"