#!/bin/bash

# Commit Helper Script
# Helps create conventional commits for semantic versioning

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Commit types
declare -A COMMIT_TYPES=(
  ["feat"]="✨ A new feature (triggers minor version)"
  ["fix"]="🐛 A bug fix (triggers patch version)"
  ["docs"]="📚 Documentation only changes"
  ["style"]="💄 Code style changes (formatting, etc)"
  ["refactor"]="♻️ Code refactoring without feature/fix"
  ["perf"]="⚡ Performance improvements"
  ["test"]="🧪 Adding or updating tests"
  ["build"]="📦 Build system or dependency changes"
  ["ci"]="👷 CI/CD configuration changes"
  ["chore"]="🔧 Other changes (maintenance)"
  ["revert"]="⏪ Revert a previous commit"
)

# Function to display commit types
show_types() {
  echo -e "${CYAN}Conventional Commit Types:${NC}"
  echo ""
  for type in "${!COMMIT_TYPES[@]}"; do
    echo -e "${GREEN}${type}${NC}: ${COMMIT_TYPES[$type]}"
  done
  echo ""
}

# Function to validate commit type
validate_type() {
  local type=$1
  if [[ -n "${COMMIT_TYPES[$type]}" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to create commit message
create_commit() {
  local type=$1
  local scope=$2
  local breaking=$3
  local description=$4
  local body=$5
  local footer=$6
  
  # Build commit message
  local message="${type}"
  
  if [[ -n "$scope" ]]; then
    message="${message}(${scope})"
  fi
  
  if [[ "$breaking" == "y" ]]; then
    message="${message}!"
  fi
  
  message="${message}: ${description}"
  
  # Add body and footer if provided
  if [[ -n "$body" ]]; then
    message="${message}\n\n${body}"
  fi
  
  if [[ -n "$footer" ]]; then
    message="${message}\n\n${footer}"
  fi
  
  if [[ "$breaking" == "y" ]] && [[ -z "$footer" ]]; then
    echo -e "${YELLOW}Breaking change detected. Please provide details:${NC}"
    read -p "Breaking change description: " breaking_desc
    message="${message}\n\nBREAKING CHANGE: ${breaking_desc}"
  fi
  
  echo "$message"
}

# Main interactive flow
main() {
  echo -e "${BLUE}=== Conventional Commit Helper ===${NC}"
  echo ""
  
  # Show git status
  echo -e "${CYAN}Current changes:${NC}"
  git status --short
  echo ""
  
  # Get commit type
  show_types
  while true; do
    read -p "Enter commit type: " type
    if validate_type "$type"; then
      break
    else
      echo -e "${RED}Invalid type. Please choose from the list above.${NC}"
    fi
  done
  
  # Get scope (optional)
  echo -e "${CYAN}Scope (optional) - component or area affected:${NC}"
  echo "Examples: api, frontend, docker, ci, docs"
  read -p "Enter scope (or press Enter to skip): " scope
  
  # Check for breaking change
  echo -e "${CYAN}Is this a breaking change? (y/n):${NC}"
  read -p "Breaking change: " breaking
  
  # Get description
  echo -e "${CYAN}Short description (imperative mood, no period):${NC}"
  echo "Example: add user authentication endpoint"
  while true; do
    read -p "Description: " description
    if [[ -n "$description" ]]; then
      break
    else
      echo -e "${RED}Description is required.${NC}"
    fi
  done
  
  # Get body (optional)
  echo -e "${CYAN}Longer description (optional, press Enter to skip):${NC}"
  read -p "Body: " body
  
  # Get footer (optional)
  echo -e "${CYAN}Footer - references, closes issues (optional):${NC}"
  echo "Example: Closes #123, Refs #456"
  read -p "Footer: " footer
  
  # Create commit message
  commit_message=$(create_commit "$type" "$scope" "$breaking" "$description" "$body" "$footer")
  
  # Show preview
  echo ""
  echo -e "${GREEN}=== Commit Preview ===${NC}"
  echo -e "$commit_message"
  echo ""
  
  # Confirm and commit
  echo -e "${YELLOW}Do you want to create this commit? (y/n):${NC}"
  read -p "Confirm: " confirm
  
  if [[ "$confirm" == "y" ]]; then
    # Stage all changes if not already staged
    if [[ -n $(git diff --name-only) ]]; then
      echo -e "${CYAN}Staging all changes...${NC}"
      git add -A
    fi
    
    # Create commit
    echo -e "$commit_message" | git commit -F -
    
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✅ Commit created successfully!${NC}"
      
      # Show version prediction
      echo ""
      echo -e "${CYAN}Version Impact:${NC}"
      case "$type" in
        feat)
          if [[ "$breaking" == "y" ]]; then
            echo -e "${RED}This will trigger a MAJOR version bump (breaking change)${NC}"
          else
            echo -e "${YELLOW}This will trigger a MINOR version bump${NC}"
          fi
          ;;
        fix)
          if [[ "$breaking" == "y" ]]; then
            echo -e "${RED}This will trigger a MAJOR version bump (breaking change)${NC}"
          else
            echo -e "${GREEN}This will trigger a PATCH version bump${NC}"
          fi
          ;;
        *)
          echo -e "${BLUE}This will not trigger a version bump${NC}"
          ;;
      esac
    else
      echo -e "${RED}✗ Commit failed${NC}"
      exit 1
    fi
  else
    echo -e "${YELLOW}Commit cancelled${NC}"
    exit 0
  fi
}

# Run main function
main