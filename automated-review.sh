#!/bin/bash

# automated-review.sh
# Automated code review using GitHub Copilot CLI and GitHub API

set -e

# Configuration
REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-$(git config --get remote.origin.url | sed -n 's#.*/\([^/]*\)/.*#\1#p')}"
REPO_NAME="${GITHUB_REPOSITORY_NAME:-$(basename -s .git $(git config --get remote.origin.url))}"
INSTRUCTIONS_FILE="${REVIEW_INSTRUCTIONS_PATH:-.github/instructions/github-review.instructions.md}"
TEMP_DIR="${REVIEW_TEMP_DIR:-/tmp/copilot-review}"
PR_NUMBER="$1"
COPILOT_MODEL="${COPILOT_MODEL:-gpt-4o}"
REVIEW_VERBOSITY="${REVIEW_VERBOSITY:-normal}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REVIEW_STYLE="${REVIEW_STYLE:-detailed}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Check dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    command -v gh >/dev/null 2>&1 || error "GitHub CLI (gh) is required but not installed"
    command -v git >/dev/null 2>&1 || error "Git is required but not installed"
    command -v jq >/dev/null 2>&1 || error "jq is required but not installed"
    
    # Check if GitHub Copilot CLI is available
    if ! gh copilot --help >/dev/null 2>&1; then
        error "GitHub Copilot CLI is not available. Install with: gh extension install github/gh-copilot"
    fi
    
    # Check GitHub authentication
    if ! gh auth status >/dev/null 2>&1; then
        if [ -n "$GITHUB_TOKEN" ]; then
            log "Using provided GITHUB_TOKEN for authentication"
            export GH_TOKEN="$GITHUB_TOKEN"
        else
            error "Not authenticated with GitHub. Run: gh auth login or set GITHUB_TOKEN environment variable"
        fi
    fi
    
    # Check environment variables
    if [ -z "$COPILOT_MODEL" ]; then
        warn "COPILOT_MODEL not set, defaulting to gpt-4o"
    fi
    
    log "All dependencies satisfied"
}

# Get PR information
get_pr_info() {
    if [ -z "$PR_NUMBER" ]; then
        # Try to detect current PR
        BRANCH=$(git branch --show-current)
        PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")
        
        if [ -z "$PR_NUMBER" ] || [ "$PR_NUMBER" = "null" ]; then
            error "No PR number provided and couldn't detect current PR. Usage: $0 <PR_NUMBER>"
        fi
    fi
    
    log "Analyzing PR #$PR_NUMBER"
    
    # Get PR details
    PR_INFO=$(gh pr view "$PR_NUMBER" --json baseRefName,headRefName,title,body)
    BASE_BRANCH=$(echo "$PR_INFO" | jq -r '.baseRefName')
    HEAD_BRANCH=$(echo "$PR_INFO" | jq -r '.headRefName')
    
    log "Base branch: $BASE_BRANCH, Head branch: $HEAD_BRANCH"
}

# Get changed files and their diff
get_changes() {
    log "Getting changed files..."
    
    mkdir -p "$TEMP_DIR"
    
    # Get list of changed files
    CHANGED_FILES=$(gh pr diff "$PR_NUMBER" --name-only)
    
    if [ -z "$CHANGED_FILES" ]; then
        warn "No files changed in this PR"
        exit 0
    fi
    
    echo "$CHANGED_FILES" > "$TEMP_DIR/changed_files.txt"
    
    # Get full diff
    gh pr diff "$PR_NUMBER" > "$TEMP_DIR/full_diff.patch"
    
    log "Found $(echo "$CHANGED_FILES" | wc -l) changed files"
}

# Load review instructions
load_instructions() {
    if [ ! -f "$INSTRUCTIONS_FILE" ]; then
        warn "Instructions file $INSTRUCTIONS_FILE not found, using default standards"
        INSTRUCTIONS="Follow general coding best practices, security guidelines, and performance optimization."
    else
        INSTRUCTIONS=$(cat "$INSTRUCTIONS_FILE")
        log "Loaded review instructions from $INSTRUCTIONS_FILE"
    fi
    
    # Apply environment-based configuration
    if [ "$REVIEW_VERBOSITY" = "detailed" ]; then
        log "Using detailed review mode"
    elif [ "$REVIEW_VERBOSITY" = "minimal" ]; then
        log "Using minimal review mode"
    fi
}

# Analyze code with GitHub Copilot
analyze_with_copilot() {
    local file_path="$1"
    local file_content="$2"
    local diff_content="$3"
    
    log "Analyzing $file_path with Copilot..."
    
    # Create analysis prompt
    local prompt="You are a senior code reviewer. Analyze the following code changes and provide specific feedback.

REVIEW INSTRUCTIONS:
$INSTRUCTIONS

FILE: $file_path

CHANGES (diff format):
$diff_content

FULL FILE CONTENT:
$file_content

Please provide review feedback in the following JSON format:
{
  \"overall_score\": \"1-10\",
  \"summary\": \"Brief overall assessment\",
  \"issues\": [
    {
      \"type\": \"blocker|improvement|nitpick\",
      \"line\": line_number_or_null,
      \"message\": \"Detailed feedback\",
      \"suggestion\": \"Specific improvement suggestion\"
    }
  ]
}

Focus on:
- Security vulnerabilities
- Performance issues
- Code quality and maintainability
- Architecture compliance
- Best practices violations

Only include actionable feedback. Be specific about line numbers where possible."

    # Use GitHub Copilot CLI to analyze
    echo "$prompt" | gh copilot suggest --target shell 2>/dev/null | \
    grep -A 1000 "{" | \
    head -n -2 > "$TEMP_DIR/analysis_$(basename "$file_path").json" || {
        warn "Copilot analysis failed for $file_path, using fallback"
        echo "{\"overall_score\": \"5\", \"summary\": \"Analysis unavailable\", \"issues\": []}" > "$TEMP_DIR/analysis_$(basename "$file_path").json"
    }
}

# Process each changed file
process_files() {
    log "Processing changed files..."
    
    while IFS= read -r file_path; do
        # Skip non-code files
        case "$file_path" in
            *.md|*.txt|*.json|*.yml|*.yaml|*.xml|*.lock|*.log) 
                continue ;;
            *) ;;
        esac
        
        log "Processing $file_path"
        
        # Get file content from PR head
        file_content=$(gh api \
            "/repos/$REPO_OWNER/$REPO_NAME/contents/$file_path" \
            --jq '.content' \
            -H "Accept: application/vnd.github.v3.raw" 2>/dev/null || echo "")
        
        if [ -z "$file_content" ]; then
            warn "Could not fetch content for $file_path"
            continue
        fi
        
        # Get diff for this specific file
        file_diff=$(git diff "origin/$BASE_BRANCH" "origin/$HEAD_BRANCH" -- "$file_path" 2>/dev/null || echo "")
        
        # Analyze with Copilot
        analyze_with_copilot "$file_path" "$file_content" "$file_diff"
        
    done < "$TEMP_DIR/changed_files.txt"
}

# Post review comments
post_comments() {
    log "Posting review comments..."
    
    local comment_body="## 🤖 Automated Code Review\n\n"
    local has_issues=false
    
    for analysis_file in "$TEMP_DIR"/analysis_*.json; do
        if [ ! -f "$analysis_file" ]; then
            continue
        fi
        
        file_name=$(basename "$analysis_file" .json | sed 's/analysis_//')
        
        # Parse analysis results
        overall_score=$(jq -r '.overall_score // "N/A"' "$analysis_file")
        summary=$(jq -r '.summary // "No summary available"' "$analysis_file")
        
        comment_body+="\n### 📁 \`$file_name\` (Score: $overall_score/10)\n"
        comment_body+="$summary\n\n"
        
        # Process individual issues
        issues_count=$(jq '.issues | length' "$analysis_file")
        
        if [ "$issues_count" -gt 0 ]; then
            has_issues=true
            
            # Post line-specific comments
            jq -c '.issues[]' "$analysis_file" | while read -r issue; do
                issue_type=$(echo "$issue" | jq -r '.type')
                line_number=$(echo "$issue" | jq -r '.line')
                message=$(echo "$issue" | jq -r '.message')
                suggestion=$(echo "$issue" | jq -r '.suggestion')
                
                # Format comment based on type
                case "$issue_type" in
                    "blocker")
                        emoji="🔴"
                        prefix="BLOCKER"
                        ;;
                    "improvement")
                        emoji="🟡"
                        prefix="IMPROVEMENT"
                        ;;
                    "nitpick")
                        emoji="🔵"
                        prefix="NITPICK"
                        ;;
                    *)
                        emoji="ℹ️"
                        prefix="NOTE"
                        ;;
                esac
                
                comment_text="$emoji **$prefix**: $message"
                if [ "$suggestion" != "null" ] && [ -n "$suggestion" ]; then
                    comment_text+="\n\n**Suggestion**: $suggestion"
                fi
                
                # Post line comment if line number is available
                if [ "$line_number" != "null" ] && [ "$line_number" -gt 0 ]; then
                    gh api \
                        "/repos/$REPO_OWNER/$REPO_NAME/pulls/$PR_NUMBER/comments" \
                        -X POST \
                        -f body="$comment_text" \
                        -f path="$file_name" \
                        -F line="$line_number" \
                        -f side="RIGHT" > /dev/null || warn "Failed to post line comment"
                else
                    comment_body+="\n$comment_text\n"
                fi
            done
        else
            comment_body+="\n✅ No issues found\n"
        fi
    done
    
    # Post overall review comment
    comment_body+="\n---\n*Automated review completed at $(date)*"
    
    gh pr comment "$PR_NUMBER" --body "$comment_body"
    
    # Set review status
    if [ "$has_issues" = true ]; then
        log "Review completed with issues found"
        # Optionally request changes
        # gh pr review "$PR_NUMBER" --request-changes --body "Please address the automated review feedback above."
    else
        log "Review completed - no issues found"
        # Optionally approve
        # gh pr review "$PR_NUMBER" --approve --body "Automated review passed - code looks good!"
    fi
}

# Cleanup
cleanup() {
    rm -rf "$TEMP_DIR"
}

# Main execution
main() {
    log "Starting automated code review..."
    
    check_dependencies
    get_pr_info
    get_changes
    load_instructions
    process_files
    post_comments
    cleanup
    
    log "Automated review completed for PR #$PR_NUMBER"
}

# Run main function
main "$@"