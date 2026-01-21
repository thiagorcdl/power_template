#!/bin/bash

# sync-template.sh
# Script to sync agent and skill definitions from the original power_template repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ORIGINAL_REPO="https://github.com/thiagorcdl/power_template.git"
TEMPLATE_DIR="/tmp/power_template_original"

# Determine script directory and project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$(dirname "$SCRIPT_DIR")}"

# Arrays of files to sync
AGENT_FILES=(
    "agents/builder.md"
    "agents/planner.md"
    "agents/reviewer.md"
    "agents/web-searcher.md"
    "agents/code-reviewer.md"
)

SKILL_FILES=(
    "skills/execute-plan/SKILL.md"
    "skills/init-project/SKILL.md"
    "skills/fix-review-issues/SKILL.md"
    "skills/update-stack-config/SKILL.md"
    "skills/detect-stack/SKILL.md"
)

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if template directory exists and is up to date
setup_template() {
    print_info "Setting up original template repository..."

    if [ -d "$TEMPLATE_DIR" ]; then
        print_info "Template directory already exists, updating..."
        cd "$TEMPLATE_DIR"
        git fetch origin
        git reset --hard origin/master
    else
        print_info "Cloning original template repository..."
        git clone "$ORIGINAL_REPO" "$TEMPLATE_DIR"
    fi

    print_success "Template repository ready"
}

# Function to compare files and show differences
compare_files() {
    local file_type=$1
    shift
    local files=("$@")

    echo ""
    echo "========================================================================"
    echo "  Comparing $file_type files"
    echo "========================================================================"
    echo ""

    local has_diffs=0

    for file in "${files[@]}"; do
        local original_file="$TEMPLATE_DIR/.opencode/$file"
        local project_file="$PROJECT_DIR/.opencode/$file"

        if [ ! -f "$original_file" ]; then
            print_warning "File not found in template: $file"
            continue
        fi

        if [ ! -f "$project_file" ]; then
            print_warning "File not found in project: $file (will be created)"
            continue
        fi

        if diff -q "$original_file" "$project_file" > /dev/null 2>&1; then
            print_success "Already up to date: $file"
        else
            print_warning "Differences found: $file"
            has_diffs=1

            # Show diff summary
            echo -e "${YELLOW}--- Differences for $file ---${NC}"
            diff -u "$original_file" "$project_file" | head -30 || true
            echo -e "${YELLOW}--- (diff truncated, use full diff to see all) ---${NC}"
            echo ""
        fi
    done

    return $has_diffs
}

# Function to copy files
copy_files() {
    local file_type=$1
    shift
    local files=("$@")

    echo ""
    echo "========================================================================"
    echo "  Updating $file_type files"
    echo "========================================================================"
    echo ""

    local copied_count=0
    local created_count=0

    for file in "${files[@]}"; do
        local original_file="$TEMPLATE_DIR/.opencode/$file"
        local project_file="$PROJECT_DIR/.opencode/$file"

        if [ ! -f "$original_file" ]; then
            print_warning "Skipping: $file (not found in template)"
            continue
        fi

        local project_dir=$(dirname "$project_file")
        mkdir -p "$project_dir"

        if [ ! -f "$project_file" ]; then
            cp "$original_file" "$project_file"
            print_success "Created: $file"
            ((created_count++))
        else
            if diff -q "$original_file" "$project_file" > /dev/null 2>&1; then
                print_info "Skipped (already up to date): $file"
            else
                cp "$original_file" "$project_file"
                print_success "Updated: $file"
                ((copied_count++))
            fi
        fi
    done

    echo ""
    print_info "$file_type summary:"
    print_info "  - Updated: $copied_count files"
    print_info "  - Created: $created_count files"
}

# Function to show full diff for a specific file
show_full_diff() {
    local file=$1
    local original_file="$TEMPLATE_DIR/.opencode/$file"
    local project_file="$PROJECT_DIR/.opencode/$file"

    if [ ! -f "$original_file" ]; then
        print_error "File not found in template: $file"
        return 1
    fi

    if [ ! -f "$project_file" ]; then
        print_info "File will be created: $file"
        cat "$original_file"
    else
        print_info "Showing full diff for: $file"
        diff -u "$original_file" "$project_file" || true
    fi
}

# Function to commit changes
commit_changes() {
    echo ""
    echo "========================================================================"
    echo "  Committing Changes"
    echo "========================================================================"
    echo ""

    cd "$PROJECT_DIR"

    print_info "Checking git status..."
    if git diff --quiet .opencode/ && git diff --cached --quiet .opencode/; then
        print_warning "No changes to commit"
        return 0
    fi

    print_info "Showing changes to be committed:"
    git status --short .opencode/
    echo ""

    read -p "Enter commit message [default: chore: sync agent and skill definitions with template]: " commit_msg
    commit_msg=${commit_msg:-"chore: sync agent and skill definitions with template"}

    git add .opencode/
    git commit -m "$commit_msg"

    print_success "Changes committed successfully"
}

# Main menu function
show_menu() {
    echo ""
    echo "========================================================================"
    echo "  Template Sync Menu"
    echo "========================================================================"
    echo ""
    echo "1) Compare all files (dry run)"
    echo "2) Compare and update all files"
    echo "3) Show full diff for specific file"
    echo "4) Exit"
    echo ""
    read -p "Select option [1-4]: " choice
    echo ""

    case $choice in
        1)
            setup_template
            compare_files "Agent" "${AGENT_FILES[@]}" || true
            compare_files "Skill" "${SKILL_FILES[@]}" || true
            ;;
        2)
            setup_template
            compare_files "Agent" "${AGENT_FILES[@]}" || true
            compare_files "Skill" "${SKILL_FILES[@]}" || true
            echo ""
            read -p "Do you want to proceed with the updates? [y/N]: " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                copy_files "Agent" "${AGENT_FILES[@]}"
                copy_files "Skill" "${SKILL_FILES[@]}"
                echo ""
                read -p "Do you want to commit the changes? [y/N]: " commit_confirm
                if [[ $commit_confirm =~ ^[Yy]$ ]]; then
                    commit_changes
                fi
            else
                print_warning "Updates cancelled"
            fi
            ;;
        3)
            setup_template
            echo ""
            echo "Available files:"
            echo ""
            for file in "${AGENT_FILES[@]}" "${SKILL_FILES[@]}"; do
                echo "  - $file"
            done
            echo ""
            read -p "Enter file path to show diff: " file_to_diff
            show_full_diff "$file_to_diff"
            ;;
        4)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
}

# Usage function
show_usage() {
    echo "Usage: $0 [PROJECT_DIR]"
    echo ""
    echo "Arguments:"
    echo "  PROJECT_DIR  Path to your power_template project directory"
    echo "               If not specified, uses the current working directory"
    echo ""
    echo "Example:"
    echo "  $0 /path/to/your/project"
    echo "  cd /path/to/your/project && $0"
    echo ""
    exit 1
}

# Main script execution
main() {
    # Check for help flags before processing PROJECT_DIR
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
    fi

    print_info "Power Template Sync Script"
    print_info "This script helps sync agent and skill definitions from the original template"
    print_info "Project directory: $PROJECT_DIR"
    echo ""

    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "Project directory not found: $PROJECT_DIR"
        exit 1
    fi

    if [ ! -d "$PROJECT_DIR/.opencode" ]; then
        print_error "Not a valid power_template project (missing .opencode directory): $PROJECT_DIR"
        exit 1
    fi

    print_success "Valid project directory found"
    echo ""

    show_menu
}

# Run main function
main "$@"
