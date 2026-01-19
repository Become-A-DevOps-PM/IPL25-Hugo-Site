#!/bin/bash
# Add course taxonomy frontmatter to all content files (excluding legacy)
# Usage: ./scripts/add-course-taxonomy.sh

set -e

CONTENT_DIR="/Users/lasse/Developer/IPL_Development/IPL25-Hugo-Site/content"

count=0
skipped=0

# Find all .md files excluding legacy directories
while IFS= read -r file; do
    # Check if file already has the taxonomy fields
    if grep -q 'program = "IPL"' "$file" 2>/dev/null; then
        echo "SKIP (already has taxonomy): $file"
        ((skipped++))
        continue
    fi

    # Check if file has TOML frontmatter (+++ within first 3 lines)
    if ! head -3 "$file" | grep -q '^+++$'; then
        echo "SKIP (no TOML frontmatter): $file"
        ((skipped++))
        continue
    fi

    # Create temp file with added fields
    # Insert the three fields after the title line
    awk '
    /^title = / && !done {
        print
        print "program = \"IPL\""
        print "cohort = \"25\""
        print "courses = [\"SNS\"]"
        done = 1
        next
    }
    { print }
    ' "$file" > "${file}.tmp"

    # Replace original with modified
    mv "${file}.tmp" "$file"

    echo "UPDATED: $file"
    ((count++))

done < <(find "$CONTENT_DIR" -name "*.md" -type f | grep -v "/legacy/")

echo ""
echo "=== Summary ==="
echo "Updated: $count files"
echo "Skipped: $skipped files"
