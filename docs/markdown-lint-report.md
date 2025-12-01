# Markdown Lint Report

**Generated:** 2025-12-01 22:14:22
**Tool:** markdownlint-cli v0.46.0

## Executive Summary

| Metric | Count |
|--------|-------|
| Total files scanned | 155 |
| Files with issues | 139 |
| Total issues | 3297 |

## Issues by Priority

### High Priority (affects rendering)

| Rule | Count | Description | Fix |
|------|-------|-------------|-----|
| MD001 | 3 | Heading levels should only increment by one level at a time | Change heading level (e.g., ## to ###) |
| MD010 | 305 | Hard tabs (use spaces instead) | Convert tabs to spaces |
| MD031 | 30 | Fenced code blocks should be surrounded by blank lines | Add blank lines around code blocks |
| MD032 | 342 | Lists should be surrounded by blank lines | Add blank lines around lists |
| MD040 | 20 | Fenced code blocks should have a language specified | Add language after ```: ```bash |
| MD041 | 18 | First line in a file should be a top-level heading | Start file with # Heading |
| MD059 | 1 | Table contains misaligned column separator | Align table column separators |
| MD060 | 192 | Table cell contains multiple paragraphs | Use <br> for line breaks in tables |

### Medium Priority (style/consistency)

| Rule | Count | Description | Fix |
|------|-------|-------------|-----|
| MD007 | 67 | Unordered list indentation | Fix list indentation (2 spaces per level) |
| MD022 | 285 | Headings should be surrounded by blank lines | Add blank lines around headings |
| MD024 | 19 | Multiple headings with the same content | Make heading text unique |
| MD025 | 54 | Multiple top-level headings in the same document | Use only one # heading |
| MD026 | 7 | Trailing punctuation in heading | Remove punctuation from heading |
| MD027 | 22 | Multiple spaces after blockquote symbol | Use single space after > |
| MD028 | 16 | Blank line inside blockquote | Remove blank line or use > on empty lines |
| MD029 | 5 | Ordered list item prefix | Use consistent numbering (1. 2. 3. or 1. 1. 1.) |
| MD030 | 3 | Spaces after list markers | Use single space after list marker |
| MD033 | 1 | Inline HTML | Replace HTML with markdown or disable rule |
| MD034 | 2 | Bare URL used | Wrap URL in angle brackets <url> |
| MD036 | 46 | Emphasis used instead of a heading | Convert **text** to ## text heading |
| MD038 | 1 | Spaces inside emphasis markers | Remove spaces: ** text ** -> **text** |
| MD047 | 12 | Files should end with a single newline character | Add newline at end of file |
| MD049 | 2 | Emphasis style should be consistent | Use consistent * or _ |

### Low Priority (formatting preferences)

| Rule | Count | Description | Fix |
|------|-------|-------------|-----|
| MD009 | 7 | Trailing spaces | Remove trailing whitespace |
| MD012 | 29 | Multiple consecutive blank lines | Remove extra blank lines |
| MD013 | 1804 | Line length exceeds limit (default 80) | Break long lines or disable rule |
| MD019 | 4 | Multiple spaces after hash on atx style heading | Use single space after # |

## Files by Issue Count (Top 30)

| File | Issues | Top Rules |
|------|--------|-----------|
| content/exercises/network-foundation/legacy/exercise-1-creating-a-virtual-network.md | 134 | MD010(107), MD013(14), MD028(4) |
| content/infrastructure-fundamentals/compute/5-azure-vm-sizing-and-cost.md | 107 | MD060(52), MD013(49), MD032(5) |
| content/exercises/server-foundation/legacy/exercise-5-provisioning-vm-az-cli.md | 102 | MD010(69), MD013(11), MD027(9) |
| CLAUDE.md | 91 | MD032(51), MD013(15), MD040(10) |
| content/exercises/network-foundation/legacy/exercise-2-creating-a-virtual-network-with-enhanced-security.md | 90 | MD010(67), MD013(15), MD032(5) |
| docs/idea_for_book.md | 85 | MD013(37), MD022(20), MD032(15) |
| docs/hugo-github-pages-setup.md | 78 | MD013(55), MD010(23) |
| docs/feedback-system-solution.md | 67 | MD060(28), MD013(22), MD031(7) |
| content/infrastructure-fundamentals/storage/2-databases/databases.md | 63 | MD013(63) |
| content/infrastructure-fundamentals/storage/3-storage/storage.md | 63 | MD013(62), MD047(1) |
| content/infrastructure-fundamentals/network/1-what-is-a-network/what-is-a-network.md | 61 | MD013(61) |
| content/infrastructure-fundamentals/network/6-network-intermediaries/network-intermediaries.md | 53 | MD013(45), MD060(8) |
| content/infrastructure-fundamentals/compute/1-what-is-a-server/what-is-a-server-slides-swe.md | 52 | MD022(17), MD032(17), MD007(11) |
| content/infrastructure-fundamentals/network/3-private-and-public-networks/private-and-public-networks.md | 50 | MD013(44), MD060(6) |
| content/infrastructure-fundamentals/storage/legacy/Databases - Article.md | 50 | MD013(32), MD007(7), MD032(6) |
| content/infrastructure-fundamentals/network/2-ip-addresses-and-cidr-ranges/ip-addresses-and-cidr-ranges.md | 49 | MD013(41), MD060(6), MD040(2) |
| docs/feedback-system-plan.md | 49 | MD013(24), MD031(7), MD032(7) |
| content/exercises/network-foundation/2-command-line-interface/3-virtual-network-az-cli.md | 48 | MD013(48) |
| content/infrastructure-fundamentals/compute/1-what-is-a-server/what-is-a-server.md | 48 | MD013(38), MD060(10) |
| content/tutorials/setup/firebase-studio.md | 45 | MD013(44), MD025(1) |
| content/exercises/network-foundation/1-portal-interface/1-creating-virtual-network.md | 44 | MD013(44) |
| content/infrastructure-fundamentals/network/4-firewalls/firewalls.md | 44 | MD013(41), MD025(1), MD036(1) |
| content/exercises/server-foundation/legacy/exercise-1-provisioning-vm-portal.md | 43 | MD013(20), MD010(7), MD022(4) |
| content/exercises/network-foundation/1-portal-interface/2-virtual-network-enhanced-security.md | 42 | MD013(41), MD026(1) |
| content/infrastructure-fundamentals/compute/2-common-server-roles/common-server-roles-slides-swe.md | 42 | MD022(13), MD032(13), MD007(12) |
| content/infrastructure-fundamentals/compute/2-common-server-roles/common-server-roles.md | 42 | MD013(42) |
| content/infrastructure-fundamentals/compute/3-inside-a-physical-server/inside-a-physical-server-slides-swe.md | 42 | MD022(21), MD032(21) |
| content/infrastructure-fundamentals/compute/3-inside-a-physical-server/inside-a-physical-server-slides.md | 42 | MD022(21), MD032(21) |
| content/infrastructure-fundamentals/storage/legacy/Storage - Article.md | 42 | MD013(36), MD060(5), MD047(1) |
| content/infrastructure-fundamentals/compute/1-what-is-a-server/what-is-a-server-slides.md | 41 | MD022(17), MD032(17), MD013(7) |

## Content Categories Summary

| Category | Files | Issues |
|----------|-------|--------|
| Infrastructure Fundamentals | 59 | 1735 |
| Exercises | 30 | 859 |
| Documentation | 5 | 280 |
| Other | 12 | 199 |
| Tutorials | 20 | 115 |
| Cheat Sheets | 4 | 56 |
| Project Templates | 5 | 37 |
| Getting Started | 4 | 16 |

## Legacy vs Active Content

| Content Type | Files | Issues |
|--------------|-------|--------|
| Active content | 112 | 2409 |
| Legacy content (/legacy/) | 27 | 888 |

## Recommended Fix Order

1. **Fix high-priority issues in active content first**
   - Focus on MD032 (lists need blank lines) - affects rendering
   - Fix MD010 (hard tabs) - causes inconsistent display
   - Address MD040 (code block languages) - affects syntax highlighting

2. **Consider disabling MD013 (line length)**
   - 1804 issues (55% of all issues)
   - Many are in tables, code blocks, or long URLs
   - Add to .markdownlint.json: `{"MD013": false}`

3. **Batch fix formatting issues**
   - MD022 (headings need blank lines)
   - MD031 (code blocks need blank lines)
   - Many are auto-fixable with `markdownlint --fix`

4. **Defer legacy content fixes**
   - 27 files, 888 issues
   - Lower priority since hidden from navigation

## Quick Fix Commands

```bash
# Auto-fix what can be fixed
markdownlint --fix "content/**/*.md"

# Check specific file
markdownlint content/path/to/file.md

# Create config to disable line length rule
echo '{"MD013": false}' > .markdownlint.json
```

## Detailed Issues by File

See `markdown-lint-report.json` for complete machine-readable data.

### Active Content Files (sorted by issue count)

#### content/infrastructure-fundamentals/compute/5-azure-vm-sizing-and-cost.md

**107 issues**

| Line | Rule | Description |
|------|------|-------------|
| 8 | MD013 | Line length: Expected: 80; Actual: 384 |
| 16 | MD013 | Line length: Expected: 80; Actual: 213 |
| 18 | MD013 | Line length: Expected: 80; Actual: 307 |
| 22 | MD013 | Line length: Expected: 80; Actual: 195 |
| 24 | MD013 | Line length: Expected: 80; Actual: 255 |
| 28 | MD013 | Line length: Expected: 80; Actual: 187 |
| 30 | MD013 | Line length: Expected: 80; Actual: 251 |
| 34 | MD013 | Line length: Expected: 80; Actual: 189 |
| 38 | MD013 | Line length: Expected: 80; Actual: 189 |
| 40 | MD013 | Line length: Expected: 80; Actual: 262 |
| 43 | MD060 | Table column style: Table pipe is missing space to the right... |
| 43 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 43 | MD060 | Table column style: Table pipe is missing space to the right... |
| 43 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 43 | MD060 | Table column style: Table pipe is missing space to the right... |
| ... | ... | *92 more issues* |

#### CLAUDE.md

**91 issues**

| Line | Rule | Description |
|------|------|-------------|
| 5 | MD013 | Line length: Expected: 80; Actual: 164 |
| 7 | MD013 | Line length: Expected: 80; Actual: 146 |
| 10 | MD032 | Lists should be surrounded by blank lines |
| 16 | MD032 | Lists should be surrounded by blank lines |
| 34 | MD032 | Lists should be surrounded by blank lines |
| 42 | MD032 | Lists should be surrounded by blank lines |
| 48 | MD032 | Lists should be surrounded by blank lines |
| 55 | MD032 | Lists should be surrounded by blank lines |
| 62 | MD032 | Lists should be surrounded by blank lines |
| 66 | MD032 | Lists should be surrounded by blank lines |
| 70 | MD032 | Lists should be surrounded by blank lines |
| 82 | MD013 | Line length: Expected: 80; Actual: 222 |
| 87 | MD040 | Fenced code blocks should have a language specified |
| 103 | MD040 | Fenced code blocks should have a language specified |
| 226 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *76 more issues* |

#### docs/idea_for_book.md

**85 issues**

| Line | Rule | Description |
|------|------|-------------|
| 3 | MD013 | Line length: Expected: 80; Actual: 155 |
| 5 | MD013 | Line length: Expected: 80; Actual: 111 |
| 13 | MD030 | Spaces after list markers: Expected: 1; Actual: 2 |
| 15 | MD013 | Line length: Expected: 80; Actual: 105 |
| 16 | MD013 | Line length: Expected: 80; Actual: 128 |
| 16 | MD030 | Spaces after list markers: Expected: 1; Actual: 2 |
| 17 | MD030 | Spaces after list markers: Expected: 1; Actual: 2 |
| 24 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 27 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 28 | MD013 | Line length: Expected: 80; Actual: 160 |
| 28 | MD032 | Lists should be surrounded by blank lines |
| 29 | MD013 | Line length: Expected: 80; Actual: 145 |
| 30 | MD013 | Line length: Expected: 80; Actual: 119 |
| 32 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 33 | MD013 | Line length: Expected: 80; Actual: 140 |
| ... | ... | *70 more issues* |

#### docs/hugo-github-pages-setup.md

**78 issues**

| Line | Rule | Description |
|------|------|-------------|
| 5 | MD013 | Line length: Expected: 80; Actual: 202 |
| 47 | MD013 | Line length: Expected: 80; Actual: 231 |
| 67 | MD013 | Line length: Expected: 80; Actual: 339 |
| 79 | MD013 | Line length: Expected: 80; Actual: 128 |
| 95 | MD013 | Line length: Expected: 80; Actual: 105 |
| 126 | MD013 | Line length: Expected: 80; Actual: 355 |
| 138 | MD013 | Line length: Expected: 80; Actual: 187 |
| 196 | MD013 | Line length: Expected: 80; Actual: 106 |
| 203 | MD013 | Line length: Expected: 80; Actual: 99 |
| 209 | MD013 | Line length: Expected: 80; Actual: 104 |
| 215 | MD013 | Line length: Expected: 80; Actual: 147 |
| 222 | MD010 | Hard tabs: Column: 4 |
| 244 | MD010 | Hard tabs: Column: 4 |
| 251 | MD013 | Line length: Expected: 80; Actual: 102 |
| 277 | MD013 | Line length: Expected: 80; Actual: 111 |
| ... | ... | *63 more issues* |

#### docs/feedback-system-solution.md

**67 issues**

| Line | Rule | Description |
|------|------|-------------|
| 3 | MD013 | Line length: Expected: 80; Actual: 240 |
| 11 | MD040 | Fenced code blocks should have a language specified |
| 12 | MD013 | Line length: Expected: 80; Actual: 115 |
| 13 | MD013 | Line length: Expected: 80; Actual: 115 |
| 14 | MD013 | Line length: Expected: 80; Actual: 115 |
| 15 | MD013 | Line length: Expected: 80; Actual: 115 |
| 16 | MD013 | Line length: Expected: 80; Actual: 115 |
| 17 | MD013 | Line length: Expected: 80; Actual: 115 |
| 18 | MD013 | Line length: Expected: 80; Actual: 115 |
| 19 | MD013 | Line length: Expected: 80; Actual: 115 |
| 31 | MD060 | Table column style: Table pipe is missing space to the right... |
| 31 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 31 | MD060 | Table column style: Table pipe is missing space to the right... |
| 31 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 31 | MD060 | Table column style: Table pipe is missing space to the right... |
| ... | ... | *52 more issues* |

#### content/infrastructure-fundamentals/storage/2-databases/databases.md

**63 issues**

| Line | Rule | Description |
|------|------|-------------|
| 12 | MD013 | Line length: Expected: 80; Actual: 405 |
| 16 | MD013 | Line length: Expected: 80; Actual: 193 |
| 20 | MD013 | Line length: Expected: 80; Actual: 274 |
| 22 | MD013 | Line length: Expected: 80; Actual: 316 |
| 26 | MD013 | Line length: Expected: 80; Actual: 388 |
| 28 | MD013 | Line length: Expected: 80; Actual: 258 |
| 32 | MD013 | Line length: Expected: 80; Actual: 330 |
| 34 | MD013 | Line length: Expected: 80; Actual: 297 |
| 38 | MD013 | Line length: Expected: 80; Actual: 302 |
| 40 | MD013 | Line length: Expected: 80; Actual: 235 |
| 44 | MD013 | Line length: Expected: 80; Actual: 272 |
| 46 | MD013 | Line length: Expected: 80; Actual: 253 |
| 50 | MD013 | Line length: Expected: 80; Actual: 165 |
| 54 | MD013 | Line length: Expected: 80; Actual: 240 |
| 56 | MD013 | Line length: Expected: 80; Actual: 255 |
| ... | ... | *48 more issues* |

#### content/infrastructure-fundamentals/storage/3-storage/storage.md

**63 issues**

| Line | Rule | Description |
|------|------|-------------|
| 12 | MD013 | Line length: Expected: 80; Actual: 351 |
| 14 | MD013 | Line length: Expected: 80; Actual: 409 |
| 18 | MD013 | Line length: Expected: 80; Actual: 139 |
| 22 | MD013 | Line length: Expected: 80; Actual: 229 |
| 24 | MD013 | Line length: Expected: 80; Actual: 277 |
| 28 | MD013 | Line length: Expected: 80; Actual: 98 |
| 30 | MD013 | Line length: Expected: 80; Actual: 266 |
| 32 | MD013 | Line length: Expected: 80; Actual: 340 |
| 34 | MD013 | Line length: Expected: 80; Actual: 238 |
| 38 | MD013 | Line length: Expected: 80; Actual: 222 |
| 40 | MD013 | Line length: Expected: 80; Actual: 380 |
| 42 | MD013 | Line length: Expected: 80; Actual: 291 |
| 44 | MD013 | Line length: Expected: 80; Actual: 239 |
| 48 | MD013 | Line length: Expected: 80; Actual: 282 |
| 50 | MD013 | Line length: Expected: 80; Actual: 246 |
| ... | ... | *48 more issues* |

#### content/infrastructure-fundamentals/network/1-what-is-a-network/what-is-a-network.md

**61 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 377 |
| 18 | MD013 | Line length: Expected: 80; Actual: 321 |
| 20 | MD013 | Line length: Expected: 80; Actual: 387 |
| 22 | MD013 | Line length: Expected: 80; Actual: 397 |
| 26 | MD013 | Line length: Expected: 80; Actual: 108 |
| 30 | MD013 | Line length: Expected: 80; Actual: 240 |
| 32 | MD013 | Line length: Expected: 80; Actual: 368 |
| 34 | MD013 | Line length: Expected: 80; Actual: 254 |
| 38 | MD013 | Line length: Expected: 80; Actual: 292 |
| 40 | MD013 | Line length: Expected: 80; Actual: 300 |
| 42 | MD013 | Line length: Expected: 80; Actual: 361 |
| 46 | MD013 | Line length: Expected: 80; Actual: 221 |
| 48 | MD013 | Line length: Expected: 80; Actual: 426 |
| 50 | MD013 | Line length: Expected: 80; Actual: 423 |
| 54 | MD013 | Line length: Expected: 80; Actual: 168 |
| ... | ... | *46 more issues* |

#### content/infrastructure-fundamentals/network/6-network-intermediaries/network-intermediaries.md

**53 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 353 |
| 18 | MD013 | Line length: Expected: 80; Actual: 471 |
| 20 | MD013 | Line length: Expected: 80; Actual: 483 |
| 24 | MD013 | Line length: Expected: 80; Actual: 301 |
| 26 | MD013 | Line length: Expected: 80; Actual: 455 |
| 28 | MD013 | Line length: Expected: 80; Actual: 357 |
| 30 | MD013 | Line length: Expected: 80; Actual: 267 |
| 34 | MD013 | Line length: Expected: 80; Actual: 362 |
| 36 | MD013 | Line length: Expected: 80; Actual: 665 |
| 38 | MD013 | Line length: Expected: 80; Actual: 404 |
| 40 | MD013 | Line length: Expected: 80; Actual: 266 |
| 44 | MD013 | Line length: Expected: 80; Actual: 401 |
| 46 | MD013 | Line length: Expected: 80; Actual: 129 |
| 50 | MD013 | Line length: Expected: 80; Actual: 406 |
| 52 | MD013 | Line length: Expected: 80; Actual: 269 |
| ... | ... | *38 more issues* |

#### content/infrastructure-fundamentals/compute/1-what-is-a-server/what-is-a-server-slides-swe.md

**52 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD013 | Line length: Expected: 80; Actual: 98 |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 21 | MD032 | Lists should be surrounded by blank lines |
| 23 | MD013 | Line length: Expected: 80; Actual: 96 |
| 23 | MD032 | Lists should be surrounded by blank lines |
| 25 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 25 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 26 | MD032 | Lists should be surrounded by blank lines |
| 29 | MD032 | Lists should be surrounded by blank lines |
| 31 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 31 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| ... | ... | *37 more issues* |

#### content/infrastructure-fundamentals/network/3-private-and-public-networks/private-and-public-networks.md

**50 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 430 |
| 18 | MD013 | Line length: Expected: 80; Actual: 316 |
| 20 | MD013 | Line length: Expected: 80; Actual: 400 |
| 24 | MD013 | Line length: Expected: 80; Actual: 293 |
| 30 | MD013 | Line length: Expected: 80; Actual: 114 |
| 31 | MD013 | Line length: Expected: 80; Actual: 122 |
| 32 | MD013 | Line length: Expected: 80; Actual: 112 |
| 34 | MD013 | Line length: Expected: 80; Actual: 332 |
| 38 | MD013 | Line length: Expected: 80; Actual: 340 |
| 40 | MD013 | Line length: Expected: 80; Actual: 389 |
| 42 | MD013 | Line length: Expected: 80; Actual: 331 |
| 48 | MD013 | Line length: Expected: 80; Actual: 211 |
| 50 | MD013 | Line length: Expected: 80; Actual: 204 |
| 52 | MD013 | Line length: Expected: 80; Actual: 200 |
| 54 | MD013 | Line length: Expected: 80; Actual: 250 |
| ... | ... | *35 more issues* |

#### content/infrastructure-fundamentals/network/2-ip-addresses-and-cidr-ranges/ip-addresses-and-cidr-ranges.md

**49 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 399 |
| 18 | MD013 | Line length: Expected: 80; Actual: 298 |
| 20 | MD013 | Line length: Expected: 80; Actual: 125 |
| 24 | MD013 | Line length: Expected: 80; Actual: 283 |
| 26 | MD013 | Line length: Expected: 80; Actual: 237 |
| 28 | MD013 | Line length: Expected: 80; Actual: 260 |
| 34 | MD013 | Line length: Expected: 80; Actual: 171 |
| 38 | MD013 | Line length: Expected: 80; Actual: 325 |
| 40 | MD013 | Line length: Expected: 80; Actual: 245 |
| 42 | MD013 | Line length: Expected: 80; Actual: 158 |
| 46 | MD013 | Line length: Expected: 80; Actual: 330 |
| 48 | MD013 | Line length: Expected: 80; Actual: 379 |
| 50 | MD013 | Line length: Expected: 80; Actual: 111 |
| 52 | MD040 | Fenced code blocks should have a language specified |
| 56 | MD013 | Line length: Expected: 80; Actual: 261 |
| ... | ... | *34 more issues* |

#### docs/feedback-system-plan.md

**49 issues**

| Line | Rule | Description |
|------|------|-------------|
| 3 | MD013 | Line length: Expected: 80; Actual: 136 |
| 9 | MD040 | Fenced code blocks should have a language specified |
| 54 | MD013 | Line length: Expected: 80; Actual: 94 |
| 117 | MD013 | Line length: Expected: 80; Actual: 86 |
| 122 | MD013 | Line length: Expected: 80; Actual: 95 |
| 267 | MD040 | Fenced code blocks should have a language specified |
| 279 | MD040 | Fenced code blocks should have a language specified |
| 342 | MD013 | Line length: Expected: 80; Actual: 85 |
| 351 | MD013 | Line length: Expected: 80; Actual: 88 |
| 363 | MD013 | Line length: Expected: 80; Actual: 88 |
| 370 | MD013 | Line length: Expected: 80; Actual: 104 |
| 376 | MD013 | Line length: Expected: 80; Actual: 90 |
| 432 | MD013 | Line length: Expected: 80; Actual: 87 |
| 439 | MD013 | Line length: Expected: 80; Actual: 104 |
| 517 | MD013 | Line length: Expected: 80; Actual: 105 |
| ... | ... | *34 more issues* |

#### content/exercises/network-foundation/2-command-line-interface/3-virtual-network-az-cli.md

**48 issues**

| Line | Rule | Description |
|------|------|-------------|
| 10 | MD013 | Line length: Expected: 80; Actual: 169 |
| 15 | MD013 | Line length: Expected: 80; Actual: 94 |
| 40 | MD013 | Line length: Expected: 80; Actual: 209 |
| 61 | MD013 | Line length: Expected: 80; Actual: 390 |
| 63 | MD013 | Line length: Expected: 80; Actual: 223 |
| 71 | MD013 | Line length: Expected: 80; Actual: 102 |
| 75 | MD013 | Line length: Expected: 80; Actual: 216 |
| 143 | MD013 | Line length: Expected: 80; Actual: 265 |
| 145 | MD013 | Line length: Expected: 80; Actual: 240 |
| 147 | MD013 | Line length: Expected: 80; Actual: 196 |
| 149 | MD013 | Line length: Expected: 80; Actual: 304 |
| 156 | MD013 | Line length: Expected: 80; Actual: 83 |
| 158 | MD013 | Line length: Expected: 80; Actual: 136 |
| 162 | MD013 | Line length: Expected: 80; Actual: 186 |
| 270 | MD013 | Line length: Expected: 80; Actual: 280 |
| ... | ... | *33 more issues* |

#### content/infrastructure-fundamentals/compute/1-what-is-a-server/what-is-a-server.md

**48 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 334 |
| 18 | MD013 | Line length: Expected: 80; Actual: 387 |
| 20 | MD013 | Line length: Expected: 80; Actual: 225 |
| 24 | MD013 | Line length: Expected: 80; Actual: 283 |
| 26 | MD013 | Line length: Expected: 80; Actual: 380 |
| 30 | MD013 | Line length: Expected: 80; Actual: 191 |
| 34 | MD013 | Line length: Expected: 80; Actual: 176 |
| 36 | MD013 | Line length: Expected: 80; Actual: 345 |
| 38 | MD013 | Line length: Expected: 80; Actual: 280 |
| 42 | MD013 | Line length: Expected: 80; Actual: 286 |
| 44 | MD013 | Line length: Expected: 80; Actual: 309 |
| 46 | MD013 | Line length: Expected: 80; Actual: 262 |
| 50 | MD013 | Line length: Expected: 80; Actual: 251 |
| 52 | MD013 | Line length: Expected: 80; Actual: 280 |
| 54 | MD013 | Line length: Expected: 80; Actual: 284 |
| ... | ... | *33 more issues* |

#### content/tutorials/setup/firebase-studio.md

**45 issues**

| Line | Rule | Description |
|------|------|-------------|
| 7 | MD025 | Multiple top-level headings in the same document |
| 11 | MD013 | Line length: Expected: 80; Actual: 159 |
| 43 | MD013 | Line length: Expected: 80; Actual: 203 |
| 73 | MD013 | Line length: Expected: 80; Actual: 94 |
| 76 | MD013 | Line length: Expected: 80; Actual: 219 |
| 82 | MD013 | Line length: Expected: 80; Actual: 180 |
| 108 | MD013 | Line length: Expected: 80; Actual: 419 |
| 110 | MD013 | Line length: Expected: 80; Actual: 99 |
| 114 | MD013 | Line length: Expected: 80; Actual: 113 |
| 134 | MD013 | Line length: Expected: 80; Actual: 120 |
| 138 | MD013 | Line length: Expected: 80; Actual: 293 |
| 144 | MD013 | Line length: Expected: 80; Actual: 197 |
| 272 | MD013 | Line length: Expected: 80; Actual: 421 |
| 276 | MD013 | Line length: Expected: 80; Actual: 191 |
| 292 | MD013 | Line length: Expected: 80; Actual: 162 |
| ... | ... | *30 more issues* |

#### content/exercises/network-foundation/1-portal-interface/1-creating-virtual-network.md

**44 issues**

| Line | Rule | Description |
|------|------|-------------|
| 10 | MD013 | Line length: Expected: 80; Actual: 175 |
| 41 | MD013 | Line length: Expected: 80; Actual: 267 |
| 64 | MD013 | Line length: Expected: 80; Actual: 389 |
| 68 | MD013 | Line length: Expected: 80; Actual: 96 |
| 69 | MD013 | Line length: Expected: 80; Actual: 98 |
| 72 | MD013 | Line length: Expected: 80; Actual: 152 |
| 78 | MD013 | Line length: Expected: 80; Actual: 200 |
| 147 | MD013 | Line length: Expected: 80; Actual: 388 |
| 149 | MD013 | Line length: Expected: 80; Actual: 185 |
| 153 | MD013 | Line length: Expected: 80; Actual: 90 |
| 154 | MD013 | Line length: Expected: 80; Actual: 94 |
| 156 | MD013 | Line length: Expected: 80; Actual: 97 |
| 158 | MD013 | Line length: Expected: 80; Actual: 92 |
| 162 | MD013 | Line length: Expected: 80; Actual: 247 |
| 193 | MD013 | Line length: Expected: 80; Actual: 98 |
| ... | ... | *29 more issues* |

#### content/infrastructure-fundamentals/network/4-firewalls/firewalls.md

**44 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD025 | Multiple top-level headings in the same document |
| 16 | MD013 | Line length: Expected: 80; Actual: 503 |
| 20 | MD013 | Line length: Expected: 80; Actual: 323 |
| 22 | MD013 | Line length: Expected: 80; Actual: 421 |
| 26 | MD013 | Line length: Expected: 80; Actual: 114 |
| 34 | MD013 | Line length: Expected: 80; Actual: 242 |
| 38 | MD013 | Line length: Expected: 80; Actual: 172 |
| 46 | MD013 | Line length: Expected: 80; Actual: 270 |
| 50 | MD013 | Line length: Expected: 80; Actual: 217 |
| 54 | MD013 | Line length: Expected: 80; Actual: 197 |
| 56 | MD013 | Line length: Expected: 80; Actual: 372 |
| 60 | MD013 | Line length: Expected: 80; Actual: 314 |
| 62 | MD013 | Line length: Expected: 80; Actual: 413 |
| 64 | MD013 | Line length: Expected: 80; Actual: 171 |
| 68 | MD013 | Line length: Expected: 80; Actual: 283 |
| ... | ... | *29 more issues* |

#### content/exercises/network-foundation/1-portal-interface/2-virtual-network-enhanced-security.md

**42 issues**

| Line | Rule | Description |
|------|------|-------------|
| 10 | MD013 | Line length: Expected: 80; Actual: 192 |
| 44 | MD013 | Line length: Expected: 80; Actual: 205 |
| 62 | MD013 | Line length: Expected: 80; Actual: 384 |
| 66 | MD013 | Line length: Expected: 80; Actual: 95 |
| 70 | MD013 | Line length: Expected: 80; Actual: 89 |
| 74 | MD013 | Line length: Expected: 80; Actual: 212 |
| 93 | MD013 | Line length: Expected: 80; Actual: 413 |
| 101 | MD013 | Line length: Expected: 80; Actual: 88 |
| 105 | MD013 | Line length: Expected: 80; Actual: 231 |
| 158 | MD013 | Line length: Expected: 80; Actual: 440 |
| 162 | MD013 | Line length: Expected: 80; Actual: 87 |
| 164 | MD013 | Line length: Expected: 80; Actual: 97 |
| 165 | MD013 | Line length: Expected: 80; Actual: 88 |
| 174 | MD013 | Line length: Expected: 80; Actual: 97 |
| 178 | MD013 | Line length: Expected: 80; Actual: 192 |
| ... | ... | *27 more issues* |

#### content/infrastructure-fundamentals/compute/2-common-server-roles/common-server-roles-slides-swe.md

**42 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD013 | Line length: Expected: 80; Actual: 136 |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 19 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 19 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD032 | Lists should be surrounded by blank lines |
| 26 | MD013 | Line length: Expected: 80; Actual: 146 |
| 26 | MD032 | Lists should be surrounded by blank lines |
| 28 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 28 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 29 | MD032 | Lists should be surrounded by blank lines |
| 30 | MD013 | Line length: Expected: 80; Actual: 97 |
| 32 | MD007 | Unordered list indentation: Expected: 2; Actual: 4 |
| 33 | MD007 | Unordered list indentation: Expected: 2; Actual: 4 |
| ... | ... | *27 more issues* |

#### content/infrastructure-fundamentals/compute/2-common-server-roles/common-server-roles.md

**42 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 352 |
| 16 | MD013 | Line length: Expected: 80; Actual: 139 |
| 20 | MD013 | Line length: Expected: 80; Actual: 110 |
| 22 | MD013 | Line length: Expected: 80; Actual: 197 |
| 24 | MD013 | Line length: Expected: 80; Actual: 184 |
| 26 | MD013 | Line length: Expected: 80; Actual: 149 |
| 28 | MD013 | Line length: Expected: 80; Actual: 161 |
| 30 | MD013 | Line length: Expected: 80; Actual: 153 |
| 32 | MD013 | Line length: Expected: 80; Actual: 174 |
| 34 | MD013 | Line length: Expected: 80; Actual: 148 |
| 36 | MD013 | Line length: Expected: 80; Actual: 164 |
| 38 | MD013 | Line length: Expected: 80; Actual: 165 |
| 40 | MD013 | Line length: Expected: 80; Actual: 170 |
| 44 | MD013 | Line length: Expected: 80; Actual: 205 |
| 46 | MD013 | Line length: Expected: 80; Actual: 360 |
| ... | ... | *27 more issues* |

#### content/infrastructure-fundamentals/compute/3-inside-a-physical-server/inside-a-physical-server-slides-swe.md

**42 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 19 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 19 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD032 | Lists should be surrounded by blank lines |
| 27 | MD032 | Lists should be surrounded by blank lines |
| 29 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 29 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 30 | MD032 | Lists should be surrounded by blank lines |
| 32 | MD032 | Lists should be surrounded by blank lines |
| 34 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 34 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 35 | MD032 | Lists should be surrounded by blank lines |
| 37 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *27 more issues* |

#### content/infrastructure-fundamentals/compute/3-inside-a-physical-server/inside-a-physical-server-slides.md

**42 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 21 | MD032 | Lists should be surrounded by blank lines |
| 28 | MD032 | Lists should be surrounded by blank lines |
| 30 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 30 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 31 | MD032 | Lists should be surrounded by blank lines |
| 33 | MD032 | Lists should be surrounded by blank lines |
| 35 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 35 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 36 | MD032 | Lists should be surrounded by blank lines |
| 38 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *27 more issues* |

#### content/infrastructure-fundamentals/compute/1-what-is-a-server/what-is-a-server-slides.md

**41 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD013 | Line length: Expected: 80; Actual: 92 |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 21 | MD032 | Lists should be surrounded by blank lines |
| 23 | MD032 | Lists should be surrounded by blank lines |
| 25 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 25 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 26 | MD013 | Line length: Expected: 80; Actual: 107 |
| 26 | MD032 | Lists should be surrounded by blank lines |
| 26 | MD032 | Lists should be surrounded by blank lines |
| 28 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 28 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| ... | ... | *26 more issues* |

#### content/infrastructure-fundamentals/compute/2-common-server-roles/common-server-roles-slides.md

**41 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD013 | Line length: Expected: 80; Actual: 129 |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 19 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 19 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD032 | Lists should be surrounded by blank lines |
| 26 | MD013 | Line length: Expected: 80; Actual: 135 |
| 26 | MD032 | Lists should be surrounded by blank lines |
| 28 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 28 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 29 | MD032 | Lists should be surrounded by blank lines |
| 32 | MD007 | Unordered list indentation: Expected: 2; Actual: 4 |
| 33 | MD007 | Unordered list indentation: Expected: 2; Actual: 4 |
| 34 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *26 more issues* |

#### content/it-security/understanding-ssh.md

**41 issues**

| Line | Rule | Description |
|------|------|-------------|
| 7 | MD013 | Line length: Expected: 80; Actual: 243 |
| 9 | MD013 | Line length: Expected: 80; Actual: 281 |
| 11 | MD013 | Line length: Expected: 80; Actual: 146 |
| 22 | MD013 | Line length: Expected: 80; Actual: 101 |
| 26 | MD013 | Line length: Expected: 80; Actual: 106 |
| 28 | MD013 | Line length: Expected: 80; Actual: 139 |
| 30 | MD013 | Line length: Expected: 80; Actual: 182 |
| 32 | MD013 | Line length: Expected: 80; Actual: 172 |
| 34 | MD013 | Line length: Expected: 80; Actual: 104 |
| 50 | MD013 | Line length: Expected: 80; Actual: 157 |
| 61 | MD013 | Line length: Expected: 80; Actual: 100 |
| 77 | MD013 | Line length: Expected: 80; Actual: 430 |
| 86 | MD013 | Line length: Expected: 80; Actual: 150 |
| 88 | MD013 | Line length: Expected: 80; Actual: 147 |
| 96 | MD013 | Line length: Expected: 80; Actual: 121 |
| ... | ... | *26 more issues* |

#### content/infrastructure-fundamentals/compute/4-inside-a-virtual-server/inside-a-virtual-server.md

**39 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 333 |
| 16 | MD013 | Line length: Expected: 80; Actual: 203 |
| 20 | MD013 | Line length: Expected: 80; Actual: 305 |
| 22 | MD013 | Line length: Expected: 80; Actual: 232 |
| 26 | MD013 | Line length: Expected: 80; Actual: 279 |
| 28 | MD013 | Line length: Expected: 80; Actual: 239 |
| 30 | MD013 | Line length: Expected: 80; Actual: 140 |
| 34 | MD013 | Line length: Expected: 80; Actual: 174 |
| 38 | MD013 | Line length: Expected: 80; Actual: 154 |
| 40 | MD013 | Line length: Expected: 80; Actual: 250 |
| 42 | MD013 | Line length: Expected: 80; Actual: 321 |
| 46 | MD013 | Line length: Expected: 80; Actual: 161 |
| 48 | MD013 | Line length: Expected: 80; Actual: 323 |
| 50 | MD013 | Line length: Expected: 80; Actual: 285 |
| 54 | MD013 | Line length: Expected: 80; Actual: 264 |
| ... | ... | *24 more issues* |

#### content/infrastructure-fundamentals/network/5-the-osi-model/the-osi-model.md

**39 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 476 |
| 18 | MD013 | Line length: Expected: 80; Actual: 369 |
| 22 | MD013 | Line length: Expected: 80; Actual: 269 |
| 24 | MD013 | Line length: Expected: 80; Actual: 233 |
| 28 | MD013 | Line length: Expected: 80; Actual: 300 |
| 30 | MD013 | Line length: Expected: 80; Actual: 327 |
| 34 | MD013 | Line length: Expected: 80; Actual: 241 |
| 36 | MD013 | Line length: Expected: 80; Actual: 288 |
| 38 | MD013 | Line length: Expected: 80; Actual: 288 |
| 42 | MD013 | Line length: Expected: 80; Actual: 273 |
| 44 | MD013 | Line length: Expected: 80; Actual: 87 |
| 46 | MD013 | Line length: Expected: 80; Actual: 535 |
| 48 | MD013 | Line length: Expected: 80; Actual: 564 |
| 50 | MD013 | Line length: Expected: 80; Actual: 272 |
| 54 | MD013 | Line length: Expected: 80; Actual: 296 |
| ... | ... | *24 more issues* |

#### content/infrastructure-fundamentals/storage/2-databases/databases-slides-swe.md

**39 issues**

| Line | Rule | Description |
|------|------|-------------|
| 2 | MD041 | First line in a file should be a top-level heading |
| 17 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 20 | MD013 | Line length: Expected: 80; Actual: 95 |
| 24 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 25 | MD036 | Emphasis used instead of a heading |
| 26 | MD032 | Lists should be surrounded by blank lines |
| 26 | MD007 | Unordered list indentation: Expected: 0; Actual: 3 |
| 27 | MD007 | Unordered list indentation: Expected: 0; Actual: 3 |
| 31 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 31 | MD024 | Multiple headings with the same content |
| 32 | MD036 | Emphasis used instead of a heading |
| 33 | MD032 | Lists should be surrounded by blank lines |
| 33 | MD007 | Unordered list indentation: Expected: 0; Actual: 3 |
| 34 | MD007 | Unordered list indentation: Expected: 0; Actual: 3 |
| ... | ... | *24 more issues* |

#### content/cheat-sheets/linux-cheatsheet.md

**38 issues**

| Line | Rule | Description |
|------|------|-------------|
| 13 | MD060 | Table column style: Table pipe is missing space to the right... |
| 13 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 13 | MD060 | Table column style: Table pipe is missing space to the right... |
| 13 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 24 | MD060 | Table column style: Table pipe is missing space to the right... |
| 24 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 24 | MD060 | Table column style: Table pipe is missing space to the right... |
| 24 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 40 | MD060 | Table column style: Table pipe is missing space to the right... |
| 40 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 40 | MD060 | Table column style: Table pipe is missing space to the right... |
| 40 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 49 | MD060 | Table column style: Table pipe is missing space to the right... |
| 49 | MD060 | Table column style: Table pipe is missing space to the left ... |
| 49 | MD060 | Table column style: Table pipe is missing space to the right... |
| ... | ... | *23 more issues* |

#### content/infrastructure-fundamentals/compute/4-inside-a-virtual-server/inside-a-virtual-server-slides-swe.md

**36 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 21 | MD032 | Lists should be surrounded by blank lines |
| 25 | MD032 | Lists should be surrounded by blank lines |
| 27 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 27 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 28 | MD032 | Lists should be surrounded by blank lines |
| 29 | MD032 | Lists should be surrounded by blank lines |
| 31 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 31 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 32 | MD032 | Lists should be surrounded by blank lines |
| 32 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *21 more issues* |

#### content/infrastructure-fundamentals/compute/4-inside-a-virtual-server/inside-a-virtual-server-slides.md

**36 issues**

| Line | Rule | Description |
|------|------|-------------|
| 16 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 17 | MD032 | Lists should be surrounded by blank lines |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 20 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 21 | MD032 | Lists should be surrounded by blank lines |
| 25 | MD032 | Lists should be surrounded by blank lines |
| 27 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 27 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 28 | MD032 | Lists should be surrounded by blank lines |
| 29 | MD032 | Lists should be surrounded by blank lines |
| 31 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 31 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 32 | MD032 | Lists should be surrounded by blank lines |
| 33 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *21 more issues* |

#### content/application/how-web-applications-work.md

**32 issues**

| Line | Rule | Description |
|------|------|-------------|
| 7 | MD025 | Multiple top-level headings in the same document |
| 9 | MD013 | Line length: Expected: 80; Actual: 330 |
| 13 | MD013 | Line length: Expected: 80; Actual: 338 |
| 15 | MD013 | Line length: Expected: 80; Actual: 351 |
| 17 | MD013 | Line length: Expected: 80; Actual: 362 |
| 21 | MD013 | Line length: Expected: 80; Actual: 163 |
| 32 | MD013 | Line length: Expected: 80; Actual: 154 |
| 46 | MD013 | Line length: Expected: 80; Actual: 111 |
| 66 | MD013 | Line length: Expected: 80; Actual: 272 |
| 70 | MD013 | Line length: Expected: 80; Actual: 212 |
| 80 | MD013 | Line length: Expected: 80; Actual: 139 |
| 88 | MD013 | Line length: Expected: 80; Actual: 106 |
| 92 | MD013 | Line length: Expected: 80; Actual: 302 |
| 101 | MD013 | Line length: Expected: 80; Actual: 99 |
| 109 | MD013 | Line length: Expected: 80; Actual: 319 |
| ... | ... | *17 more issues* |

#### content/infrastructure-fundamentals/compute/3-inside-a-physical-server/inside-a-physical-server.md

**32 issues**

| Line | Rule | Description |
|------|------|-------------|
| 14 | MD013 | Line length: Expected: 80; Actual: 401 |
| 18 | MD013 | Line length: Expected: 80; Actual: 274 |
| 22 | MD013 | Line length: Expected: 80; Actual: 244 |
| 24 | MD013 | Line length: Expected: 80; Actual: 328 |
| 26 | MD013 | Line length: Expected: 80; Actual: 214 |
| 30 | MD013 | Line length: Expected: 80; Actual: 249 |
| 32 | MD013 | Line length: Expected: 80; Actual: 337 |
| 34 | MD013 | Line length: Expected: 80; Actual: 249 |
| 38 | MD013 | Line length: Expected: 80; Actual: 159 |
| 40 | MD013 | Line length: Expected: 80; Actual: 272 |
| 42 | MD013 | Line length: Expected: 80; Actual: 271 |
| 44 | MD013 | Line length: Expected: 80; Actual: 399 |
| 48 | MD013 | Line length: Expected: 80; Actual: 213 |
| 50 | MD013 | Line length: Expected: 80; Actual: 226 |
| 52 | MD013 | Line length: Expected: 80; Actual: 210 |
| ... | ... | *17 more issues* |

#### content/infrastructure-fundamentals/storage/1-what-is-persistence/what-is-persistence.md

**32 issues**

| Line | Rule | Description |
|------|------|-------------|
| 12 | MD013 | Line length: Expected: 80; Actual: 407 |
| 16 | MD013 | Line length: Expected: 80; Actual: 302 |
| 18 | MD013 | Line length: Expected: 80; Actual: 353 |
| 20 | MD013 | Line length: Expected: 80; Actual: 353 |
| 24 | MD013 | Line length: Expected: 80; Actual: 158 |
| 28 | MD013 | Line length: Expected: 80; Actual: 305 |
| 30 | MD013 | Line length: Expected: 80; Actual: 361 |
| 32 | MD013 | Line length: Expected: 80; Actual: 282 |
| 36 | MD013 | Line length: Expected: 80; Actual: 284 |
| 38 | MD013 | Line length: Expected: 80; Actual: 279 |
| 40 | MD013 | Line length: Expected: 80; Actual: 299 |
| 44 | MD013 | Line length: Expected: 80; Actual: 182 |
| 48 | MD013 | Line length: Expected: 80; Actual: 156 |
| 50 | MD013 | Line length: Expected: 80; Actual: 386 |
| 52 | MD013 | Line length: Expected: 80; Actual: 396 |
| ... | ... | *17 more issues* |

#### content/exercises/application-development/deploy-flask-application-basic.md

**30 issues**

| Line | Rule | Description |
|------|------|-------------|
| 7 | MD025 | Multiple top-level headings in the same document |
| 11 | MD013 | Line length: Expected: 80; Actual: 141 |
| 13 | MD013 | Line length: Expected: 80; Actual: 285 |
| 14 | MD028 | Blank line inside blockquote |
| 41 | MD013 | Line length: Expected: 80; Actual: 88 |
| 51 | MD013 | Line length: Expected: 80; Actual: 122 |
| 53 | MD013 | Line length: Expected: 80; Actual: 90 |
| 63 | MD013 | Line length: Expected: 80; Actual: 189 |
| 65 | MD013 | Line length: Expected: 80; Actual: 136 |
| 77 | MD013 | Line length: Expected: 80; Actual: 101 |
| 127 | MD013 | Line length: Expected: 80; Actual: 209 |
| 129 | MD013 | Line length: Expected: 80; Actual: 221 |
| 131 | MD013 | Line length: Expected: 80; Actual: 150 |
| 135 | MD013 | Line length: Expected: 80; Actual: 90 |
| 173 | MD013 | Line length: Expected: 80; Actual: 189 |
| ... | ... | *15 more issues* |

#### content/exercises/server-foundation/1-portal-interface/1-provisioning-vm-portal.md

**30 issues**

| Line | Rule | Description |
|------|------|-------------|
| 11 | MD013 | Line length: Expected: 80; Actual: 132 |
| 40 | MD013 | Line length: Expected: 80; Actual: 226 |
| 50 | MD013 | Line length: Expected: 80; Actual: 209 |
| 63 | MD013 | Line length: Expected: 80; Actual: 252 |
| 69 | MD013 | Line length: Expected: 80; Actual: 236 |
| 71 | MD013 | Line length: Expected: 80; Actual: 101 |
| 92 | MD013 | Line length: Expected: 80; Actual: 144 |
| 93 | MD013 | Line length: Expected: 80; Actual: 110 |
| 101 | MD013 | Line length: Expected: 80; Actual: 122 |
| 105 | MD013 | Line length: Expected: 80; Actual: 563 |
| 111 | MD013 | Line length: Expected: 80; Actual: 185 |
| 123 | MD013 | Line length: Expected: 80; Actual: 106 |
| 124 | MD013 | Line length: Expected: 80; Actual: 105 |
| 128 | MD013 | Line length: Expected: 80; Actual: 201 |
| 130 | MD013 | Line length: Expected: 80; Actual: 146 |
| ... | ... | *15 more issues* |

#### content/exercises/application-development/develop-flask-locally.md

**28 issues**

| Line | Rule | Description |
|------|------|-------------|
| 7 | MD025 | Multiple top-level headings in the same document |
| 11 | MD013 | Line length: Expected: 80; Actual: 99 |
| 38 | MD013 | Line length: Expected: 80; Actual: 99 |
| 42 | MD013 | Line length: Expected: 80; Actual: 98 |
| 55 | MD013 | Line length: Expected: 80; Actual: 117 |
| 62 | MD013 | Line length: Expected: 80; Actual: 91 |
| 65 | MD013 | Line length: Expected: 80; Actual: 327 |
| 67 | MD013 | Line length: Expected: 80; Actual: 268 |
| 86 | MD013 | Line length: Expected: 80; Actual: 123 |
| 106 | MD013 | Line length: Expected: 80; Actual: 103 |
| 109 | MD013 | Line length: Expected: 80; Actual: 98 |
| 111 | MD013 | Line length: Expected: 80; Actual: 125 |
| 136 | MD013 | Line length: Expected: 80; Actual: 123 |
| 185 | MD013 | Line length: Expected: 80; Actual: 323 |
| 187 | MD013 | Line length: Expected: 80; Actual: 250 |
| ... | ... | *13 more issues* |

#### content/exercises/server-foundation/1-portal-interface/2-provisioning-vm-ssh-keys.md

**26 issues**

| Line | Rule | Description |
|------|------|-------------|
| 11 | MD013 | Line length: Expected: 80; Actual: 142 |
| 42 | MD013 | Line length: Expected: 80; Actual: 168 |
| 49 | MD013 | Line length: Expected: 80; Actual: 196 |
| 54 | MD013 | Line length: Expected: 80; Actual: 133 |
| 65 | MD013 | Line length: Expected: 80; Actual: 114 |
| 69 | MD013 | Line length: Expected: 80; Actual: 236 |
| 73 | MD013 | Line length: Expected: 80; Actual: 200 |
| 75 | MD013 | Line length: Expected: 80; Actual: 92 |
| 84 | MD013 | Line length: Expected: 80; Actual: 227 |
| 86 | MD013 | Line length: Expected: 80; Actual: 107 |
| 90 | MD013 | Line length: Expected: 80; Actual: 202 |
| 92 | MD013 | Line length: Expected: 80; Actual: 111 |
| 103 | MD013 | Line length: Expected: 80; Actual: 174 |
| 105 | MD013 | Line length: Expected: 80; Actual: 95 |
| 109 | MD013 | Line length: Expected: 80; Actual: 219 |
| ... | ... | *11 more issues* |

#### content/exercises/server-foundation/2-command-line-interface/5-provisioning-vm-az-cli.md

**21 issues**

| Line | Rule | Description |
|------|------|-------------|
| 11 | MD013 | Line length: Expected: 80; Actual: 124 |
| 41 | MD013 | Line length: Expected: 80; Actual: 273 |
| 65 | MD013 | Line length: Expected: 80; Actual: 233 |
| 80 | MD013 | Line length: Expected: 80; Actual: 113 |
| 95 | MD013 | Line length: Expected: 80; Actual: 276 |
| 118 | MD013 | Line length: Expected: 80; Actual: 140 |
| 129 | MD013 | Line length: Expected: 80; Actual: 113 |
| 147 | MD013 | Line length: Expected: 80; Actual: 238 |
| 152 | MD013 | Line length: Expected: 80; Actual: 111 |
| 164 | MD013 | Line length: Expected: 80; Actual: 251 |
| 175 | MD013 | Line length: Expected: 80; Actual: 139 |
| 176 | MD013 | Line length: Expected: 80; Actual: 159 |
| 179 | MD013 | Line length: Expected: 80; Actual: 238 |
| 183 | MD013 | Line length: Expected: 80; Actual: 251 |
| 200 | MD013 | Line length: Expected: 80; Actual: 97 |
| ... | ... | *6 more issues* |

#### content/infrastructure-fundamentals/network/3-private-and-public-networks/private-and-public-networks-slides.md

**21 issues**

| Line | Rule | Description |
|------|------|-------------|
| 2 | MD041 | First line in a file should be a top-level heading |
| 17 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 23 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 24 | MD032 | Lists should be surrounded by blank lines |
| 30 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 31 | MD032 | Lists should be surrounded by blank lines |
| 37 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 38 | MD013 | Line length: Expected: 80; Actual: 94 |
| 38 | MD032 | Lists should be surrounded by blank lines |
| 39 | MD013 | Line length: Expected: 80; Actual: 93 |
| 40 | MD013 | Line length: Expected: 80; Actual: 111 |
| 44 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 45 | MD032 | Lists should be surrounded by blank lines |
| 54 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| ... | ... | *6 more issues* |

#### content/infrastructure-fundamentals/storage/2-databases/databases-slides.md

**21 issues**

| Line | Rule | Description |
|------|------|-------------|
| 2 | MD041 | First line in a file should be a top-level heading |
| 17 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 23 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 24 | MD032 | Lists should be surrounded by blank lines |
| 37 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 38 | MD032 | Lists should be surrounded by blank lines |
| 44 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 45 | MD032 | Lists should be surrounded by blank lines |
| 46 | MD007 | Unordered list indentation: Expected: 2; Actual: 3 |
| 47 | MD007 | Unordered list indentation: Expected: 2; Actual: 3 |
| 50 | MD007 | Unordered list indentation: Expected: 2; Actual: 3 |
| 51 | MD007 | Unordered list indentation: Expected: 2; Actual: 3 |
| 55 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 56 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *6 more issues* |

#### content/tutorials/deploying-with-scp.md

**21 issues**

| Line | Rule | Description |
|------|------|-------------|
| 10 | MD013 | Line length: Expected: 80; Actual: 177 |
| 38 | MD013 | Line length: Expected: 80; Actual: 213 |
| 60 | MD013 | Line length: Expected: 80; Actual: 359 |
| 66 | MD013 | Line length: Expected: 80; Actual: 206 |
| 68 | MD013 | Line length: Expected: 80; Actual: 92 |
| 86 | MD013 | Line length: Expected: 80; Actual: 311 |
| 98 | MD013 | Line length: Expected: 80; Actual: 186 |
| 110 | MD013 | Line length: Expected: 80; Actual: 292 |
| 138 | MD013 | Line length: Expected: 80; Actual: 244 |
| 179 | MD013 | Line length: Expected: 80; Actual: 104 |
| 199 | MD013 | Line length: Expected: 80; Actual: 389 |
| 205 | MD013 | Line length: Expected: 80; Actual: 109 |
| 207 | MD013 | Line length: Expected: 80; Actual: 90 |
| 213 | MD013 | Line length: Expected: 80; Actual: 145 |
| 215 | MD013 | Line length: Expected: 80; Actual: 150 |
| ... | ... | *6 more issues* |

#### content/infrastructure-fundamentals/storage/1-what-is-persistence/what-is-persistence-slides.md

**20 issues**

| Line | Rule | Description |
|------|------|-------------|
| 2 | MD041 | First line in a file should be a top-level heading |
| 17 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 23 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 24 | MD032 | Lists should be surrounded by blank lines |
| 34 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 35 | MD032 | Lists should be surrounded by blank lines |
| 41 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 42 | MD032 | Lists should be surrounded by blank lines |
| 48 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 49 | MD013 | Line length: Expected: 80; Actual: 96 |
| 49 | MD032 | Lists should be surrounded by blank lines |
| 50 | MD013 | Line length: Expected: 80; Actual: 93 |
| 51 | MD013 | Line length: Expected: 80; Actual: 92 |
| 55 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| ... | ... | *5 more issues* |

#### content/infrastructure-fundamentals/storage/3-storage/storage-slides.md

**20 issues**

| Line | Rule | Description |
|------|------|-------------|
| 2 | MD041 | First line in a file should be a top-level heading |
| 17 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 23 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 24 | MD032 | Lists should be surrounded by blank lines |
| 38 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 39 | MD032 | Lists should be surrounded by blank lines |
| 40 | MD007 | Unordered list indentation: Expected: 2; Actual: 3 |
| 41 | MD007 | Unordered list indentation: Expected: 2; Actual: 3 |
| 44 | MD007 | Unordered list indentation: Expected: 2; Actual: 3 |
| 48 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 49 | MD032 | Lists should be surrounded by blank lines |
| 55 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 56 | MD032 | Lists should be surrounded by blank lines |
| 62 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| ... | ... | *5 more issues* |

#### content/infrastructure-fundamentals/network/1-what-is-a-network/what-is-a-network-slides-swe.md

**19 issues**

| Line | Rule | Description |
|------|------|-------------|
| 2 | MD041 | First line in a file should be a top-level heading |
| 17 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 20 | MD013 | Line length: Expected: 80; Actual: 93 |
| 21 | MD013 | Line length: Expected: 80; Actual: 95 |
| 25 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 26 | MD032 | Lists should be surrounded by blank lines |
| 33 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 33 | MD024 | Multiple headings with the same content |
| 34 | MD013 | Line length: Expected: 80; Actual: 107 |
| 34 | MD032 | Lists should be surrounded by blank lines |
| 38 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 39 | MD032 | Lists should be surrounded by blank lines |
| 47 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 48 | MD032 | Lists should be surrounded by blank lines |
| ... | ... | *4 more issues* |

#### content/exercises/server-foundation/2-command-line-interface/6-automating-vm-bash-script.md

**17 issues**

| Line | Rule | Description |
|------|------|-------------|
| 11 | MD013 | Line length: Expected: 80; Actual: 134 |
| 32 | MD013 | Line length: Expected: 80; Actual: 96 |
| 38 | MD013 | Line length: Expected: 80; Actual: 201 |
| 56 | MD013 | Line length: Expected: 80; Actual: 88 |
| 60 | MD013 | Line length: Expected: 80; Actual: 233 |
| 95 | MD013 | Line length: Expected: 80; Actual: 111 |
| 113 | MD013 | Line length: Expected: 80; Actual: 90 |
| 123 | MD013 | Line length: Expected: 80; Actual: 174 |
| 140 | MD013 | Line length: Expected: 80; Actual: 113 |
| 144 | MD013 | Line length: Expected: 80; Actual: 174 |
| 154 | MD013 | Line length: Expected: 80; Actual: 194 |
| 162 | MD013 | Line length: Expected: 80; Actual: 123 |
| 164 | MD013 | Line length: Expected: 80; Actual: 130 |
| 166 | MD013 | Line length: Expected: 80; Actual: 156 |
| 176 | MD013 | Line length: Expected: 80; Actual: 218 |
| ... | ... | *2 more issues* |

#### content/infrastructure-fundamentals/network/4-firewalls/firewalls-slides-swe.md

**16 issues**

| Line | Rule | Description |
|------|------|-------------|
| 2 | MD041 | First line in a file should be a top-level heading |
| 17 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 18 | MD013 | Line length: Expected: 80; Actual: 103 |
| 18 | MD032 | Lists should be surrounded by blank lines |
| 19 | MD013 | Line length: Expected: 80; Actual: 99 |
| 23 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 24 | MD032 | Lists should be surrounded by blank lines |
| 32 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 33 | MD032 | Lists should be surrounded by blank lines |
| 36 | MD013 | Line length: Expected: 80; Actual: 91 |
| 42 | MD022 | Headings should be surrounded by blank lines: Expected: 1; A... |
| 43 | MD013 | Line length: Expected: 80; Actual: 94 |
| 43 | MD032 | Lists should be surrounded by blank lines |
| 44 | MD013 | Line length: Expected: 80; Actual: 105 |
| 45 | MD047 | Files should end with a single newline character |
| ... | ... | *1 more issues* |

#### content/exercises/server-foundation/1-portal-interface/3-automating-nginx-custom-data.md

**15 issues**

| Line | Rule | Description |
|------|------|-------------|
| 11 | MD013 | Line length: Expected: 80; Actual: 145 |
| 38 | MD013 | Line length: Expected: 80; Actual: 197 |
| 45 | MD013 | Line length: Expected: 80; Actual: 250 |
| 47 | MD013 | Line length: Expected: 80; Actual: 102 |
| 73 | MD013 | Line length: Expected: 80; Actual: 147 |
| 80 | MD013 | Line length: Expected: 80; Actual: 100 |
| 88 | MD013 | Line length: Expected: 80; Actual: 187 |
| 92 | MD013 | Line length: Expected: 80; Actual: 194 |
| 119 | MD013 | Line length: Expected: 80; Actual: 117 |
| 123 | MD013 | Line length: Expected: 80; Actual: 113 |
| 133 | MD013 | Line length: Expected: 80; Actual: 189 |
| 135 | MD013 | Line length: Expected: 80; Actual: 108 |
| 141 | MD013 | Line length: Expected: 80; Actual: 87 |
| 148 | MD013 | Line length: Expected: 80; Actual: 190 |
| 160 | MD013 | Line length: Expected: 80; Actual: 143 |

#### content/infrastructure-fundamentals/network/_index.md

**15 issues**

| Line | Rule | Description |
|------|------|-------------|
| 7 | MD025 | Multiple top-level headings in the same document |
| 9 | MD013 | Line length: Expected: 80; Actual: 268 |
| 11 | MD013 | Line length: Expected: 80; Actual: 384 |
| 15 | MD013 | Line length: Expected: 80; Actual: 127 |
| 16 | MD013 | Line length: Expected: 80; Actual: 110 |
| 17 | MD013 | Line length: Expected: 80; Actual: 108 |
| 18 | MD013 | Line length: Expected: 80; Actual: 112 |
| 19 | MD013 | Line length: Expected: 80; Actual: 101 |
| 20 | MD013 | Line length: Expected: 80; Actual: 90 |
| 24 | MD013 | Line length: Expected: 80; Actual: 156 |
| 25 | MD013 | Line length: Expected: 80; Actual: 171 |
| 26 | MD013 | Line length: Expected: 80; Actual: 169 |
| 27 | MD013 | Line length: Expected: 80; Actual: 138 |
| 28 | MD013 | Line length: Expected: 80; Actual: 139 |
| 29 | MD013 | Line length: Expected: 80; Actual: 153 |
