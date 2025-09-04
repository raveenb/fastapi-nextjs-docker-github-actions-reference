#!/bin/bash

# Branch Protection Setup Script
# Configures branch protection rules for the repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
BRANCH="${1:-main}"
REPO="${2:-raveenb/fastapi-nextjs-docker-github-actions-reference}"

echo -e "${BLUE}=== Branch Protection Setup ===${NC}"
echo -e "Repository: ${CYAN}${REPO}${NC}"
echo -e "Branch: ${CYAN}${BRANCH}${NC}"
echo ""

# Function to setup protection rules
setup_protection() {
    echo -e "${YELLOW}Configuring branch protection rules...${NC}"
    
    # Create the protection rules JSON
    cat > /tmp/branch-protection.json << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "test-backend",
      "test-frontend",
      "lint",
      "type-check",
      "build-backend",
      "build-frontend"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": true
}
EOF

    # Apply protection rules using GitHub API
    if gh api \
        --method PUT \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/${REPO}/branches/${BRANCH}/protection" \
        --input /tmp/branch-protection.json > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Full protection rules applied${NC}"
    else
        echo -e "${YELLOW}⚠️  Trying basic protection (you may not have full admin rights)${NC}"
        
        # Try with basic protection
        cat > /tmp/branch-protection-basic.json << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": []
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
        
        if gh api \
            --method PUT \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "/repos/${REPO}/branches/${BRANCH}/protection" \
            --input /tmp/branch-protection-basic.json > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Basic protection rules applied${NC}"
        else
            echo -e "${RED}❌ Failed to apply protection rules${NC}"
            echo "You may need to enable this manually in GitHub Settings"
            exit 1
        fi
    fi
    
    # Clean up
    rm -f /tmp/branch-protection*.json
}

# Function to show current protection status
show_status() {
    echo -e "${CYAN}Current Protection Status:${NC}"
    
    if gh api \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/${REPO}/branches/${BRANCH}/protection" 2>/dev/null > /tmp/protection-status.json; then
        
        echo -e "${GREEN}✓ Branch is protected${NC}"
        
        # Parse and display key settings
        if command -v jq > /dev/null 2>&1; then
            echo ""
            echo "Protection Rules:"
            echo -n "  • Require PR reviews: "
            jq -r '.required_pull_request_reviews // "No" | if . == "No" then . else "Yes (\(.required_approving_review_count) approval\(if .required_approving_review_count != 1 then "s" else "" end))" end' /tmp/protection-status.json
            
            echo -n "  • Require status checks: "
            jq -r '.required_status_checks // "No" | if . == "No" then . else "Yes" end' /tmp/protection-status.json
            
            echo -n "  • Require up-to-date branches: "
            jq -r '.required_status_checks.strict // false' /tmp/protection-status.json
            
            echo -n "  • Allow force pushes: "
            jq -r '.allow_force_pushes.enabled // false' /tmp/protection-status.json
            
            echo -n "  • Allow deletions: "
            jq -r '.allow_deletions.enabled // false' /tmp/protection-status.json
            
            echo -n "  • Enforce for admins: "
            jq -r '.enforce_admins.enabled // false' /tmp/protection-status.json
            
            # Show required status checks if any
            echo ""
            echo "Required Status Checks:"
            jq -r '.required_status_checks.contexts[]? // "  • None configured" | "  • \(.)"' /tmp/protection-status.json
        else
            cat /tmp/protection-status.json
        fi
    else
        echo -e "${YELLOW}⚠ Branch is not protected${NC}"
    fi
    
    rm -f /tmp/protection-status.json
}

# Main menu
main() {
    echo "What would you like to do?"
    echo ""
    echo "1) Setup recommended protection rules"
    echo "2) View current protection status"
    echo "3) Remove protection (dangerous!)"
    echo "4) Exit"
    echo ""
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1)
            setup_protection
            echo ""
            show_status
            ;;
        2)
            show_status
            ;;
        3)
            echo -e "${RED}⚠️  WARNING: This will remove all protection rules!${NC}"
            read -p "Are you sure? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                gh api \
                    --method DELETE \
                    -H "Accept: application/vnd.github+json" \
                    -H "X-GitHub-Api-Version: 2022-11-28" \
                    "/repos/${REPO}/branches/${BRANCH}/protection"
                echo -e "${GREEN}✅ Protection removed${NC}"
            else
                echo "Cancelled"
            fi
            ;;
        4)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

# Check if gh is installed
if ! command -v gh > /dev/null 2>&1; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status > /dev/null 2>&1; then
    echo -e "${RED}Error: Not authenticated with GitHub${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Run main function
main

echo ""
echo -e "${GREEN}=== Done ===${NC}"