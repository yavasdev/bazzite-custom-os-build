#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# 1. CONFIGURATION - Add your variables here
# ==============================================================================

# Define as many placeholders and their replacements as needed.
declare -A REPLACEMENTS=(
    ["{{BADGE_URL}}"]="https://ghcr-badge.egpl.dev/yavasdev"
    ["{{BADGE_PARAMS}}"]="tags?label=release&ignore=*-*-*,sha256-*,stable,latest,testing&n=3"
    
    # Examples of other variables you might add later (KISS - add as needed):
    # ["{{REPO_NAME}}"]="ublue-tuxedo"
    # ["{{AUTHOR}}"]="yavasdev"
)

# List of template files to process
TEMPLATES=(
    "README.template.md"
    "docs/README-TR.template.md"
)

# ==============================================================================
# 2. ENGINE / LOGIC - No need to touch below this line
# ==============================================================================

echo "Generating README files..."

for template in "${TEMPLATES[@]}"; do
    # If the file doesn't exist, warn and skip to the next one
    if [[ ! -f "$template" ]]; then
        echo "Warning: $template not found, skipping."
        continue
    fi

    # Set the output filename (regex) (removes '.template' from the name)
    # E.g., docs/README-TR.template.md -> docs/README-TR.md
    output="${template/.template/}"
    
    # Start by copying the template to the actual file target
    cp "$template" "$output"

    # Perform text replacement for each defined variable
    for key in "${!REPLACEMENTS[@]}"; do
        value="${REPLACEMENTS[$key]}"
        escaped_value="${value//&/\\&}" # Prevents the '&' character sed gotcha
        
        # Replace using sed, write to a temp file, then overwrite
        # (This approach is 100% robust and compatible across Linux and macOS)
        sed -e "s|${key}|${escaped_value}|g" "$output" > "${output}.tmp"
        mv "${output}.tmp" "$output"
    done

    echo " -> Generated: $output"
done

echo "All files updated successfully!"