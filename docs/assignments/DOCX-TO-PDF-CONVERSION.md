# Converting DOCX to PDF on macOS

This document describes methods for converting Microsoft Word (.docx) or Google Docs exported files to PDF format on macOS.

## Method Used: AppleScript with Microsoft Word

This method uses AppleScript to automate Microsoft Word for the conversion.

### Prerequisites

- Microsoft Word installed (`/Applications/Microsoft Word.app`)

### Command

```bash
osascript <<'EOF'
set inputFile to "/path/to/input.docx"
set outputFile to "/path/to/output.pdf"

tell application "Microsoft Word"
    activate
    open inputFile
    delay 2
    set theDoc to active document
    save as theDoc file name outputFile file format format PDF
    close theDoc saving no
end tell
EOF
```

### How It Works

1. `activate` - Launches Microsoft Word (or brings it to foreground)
2. `open inputFile` - Opens the .docx file
3. `delay 2` - Waits 2 seconds for the document to fully load
4. `save as ... file format format PDF` - Exports the document as PDF
5. `close theDoc saving no` - Closes without saving changes to the original

### Advantages

- Uses Word's native rendering engine
- Preserves all formatting exactly as intended
- No additional software installation required (if Word is installed)

### Disadvantages

- Requires Microsoft Word license
- Opens a GUI application (not headless)
- Slower than command-line tools

## Alternative Methods

### 1. AppleScript with Pages

If Pages is installed but Word is not:

```bash
osascript <<'EOF'
set inputFile to "/path/to/input.docx"
set outputFile to "/path/to/output.pdf"

tell application "Pages"
    activate
    open inputFile
    delay 2
    set theDoc to front document
    export theDoc to file outputFile as PDF
    close theDoc saving no
end tell
EOF
```

### 2. Pandoc (Command Line)

A versatile document converter.

**Installation:**
```bash
brew install pandoc
brew install basictex  # Required for PDF output
```

**Usage:**
```bash
pandoc input.docx -o output.pdf
```

**Advantages:**
- Headless (no GUI)
- Fast
- Supports many formats

**Disadvantages:**
- Requires installation
- May not preserve complex Word formatting perfectly

### 3. LibreOffice (Command Line)

LibreOffice can run headless for batch conversions.

**Installation:**
```bash
brew install --cask libreoffice
```

**Usage:**
```bash
/Applications/LibreOffice.app/Contents/MacOS/soffice \
    --headless \
    --convert-to pdf \
    --outdir /output/directory \
    input.docx
```

**Advantages:**
- Headless (no GUI popup)
- Good formatting preservation
- Free and open source

**Disadvantages:**
- Large installation (~500MB)
- Slower startup than native tools

### 4. Python docx2pdf

A Python library that uses Word (macOS/Windows) or LibreOffice (Linux).

**Installation:**
```bash
pip install docx2pdf
```

**Usage (Python):**
```python
from docx2pdf import convert
convert("input.docx", "output.pdf")
```

**Usage (Command Line):**
```bash
docx2pdf input.docx output.pdf
```

**Advantages:**
- Simple API
- Cross-platform
- Scriptable in Python

**Disadvantages:**
- Requires Python
- Uses Word under the hood on macOS (so Word must be installed)

### 5. Online Services (Not Recommended for Sensitive Data)

- Google Drive: Upload .docx, open with Google Docs, File → Download → PDF
- CloudConvert, Zamzar, etc.

**Warning:** Do not use for student reports or sensitive data due to privacy concerns.

## Batch Conversion Script

For converting multiple files at once using the AppleScript method:

```bash
#!/bin/bash
# batch-convert-docx.sh

INPUT_DIR="$1"
OUTPUT_DIR="${2:-$INPUT_DIR}"

for docx in "$INPUT_DIR"/*.docx; do
    if [ -f "$docx" ]; then
        filename=$(basename "$docx" .docx)
        output="$OUTPUT_DIR/${filename}.pdf"

        echo "Converting: $docx -> $output"

        osascript <<EOF
tell application "Microsoft Word"
    open "$docx"
    delay 2
    set theDoc to active document
    save as theDoc file name "$output" file format format PDF
    close theDoc saving no
end tell
EOF
    fi
done

echo "Done!"
```

**Usage:**
```bash
chmod +x batch-convert-docx.sh
./batch-convert-docx.sh /path/to/documents
```

## Recommendation

| Scenario | Recommended Method |
|----------|-------------------|
| Word installed, single file | AppleScript + Word |
| Word installed, batch conversion | AppleScript + Word (loop) |
| No Word, have LibreOffice | LibreOffice headless |
| Developer environment | Pandoc |
| Python scripting needed | docx2pdf |
| Sensitive/student data | Any local method (avoid online) |
