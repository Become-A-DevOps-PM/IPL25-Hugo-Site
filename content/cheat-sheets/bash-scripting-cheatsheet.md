+++
title = "Bash Scripting Cheat Sheet"
program = "IPL"
cohort = "25"
courses = ["SNS"]
weight = 20
date = 2024-11-25
draft = false
+++

Quick reference for Bash scripting basics.

## Script Structure

```bash
#!/bin/bash

# Your commands here
echo "Hello World"
```

Always start with `#!/bin/bash` (shebang).

## Making Scripts Executable

```bash
chmod +x script.sh
./script.sh
```

## Variables

```bash
# Define
name="value"
count=10

# Use
echo $name
echo "Count is $count"
echo "Count is ${count} items"
```

## Command Substitution

```bash
# Store command output
current_date=$(date)
vm_ip=$(az vm show --name VM --query publicIps -o tsv)

echo "Date: $current_date"
```

## Conditional Execution

### If Statement

```bash
if [ -f "/path/to/file" ]; then
    echo "File exists"
else
    echo "File not found"
fi
```

### Common Test Operators

| Operator | Description |
|----------|-------------|
| `-f file` | File exists |
| `-d dir` | Directory exists |
| `-z "$var"` | Variable is empty |
| `-n "$var"` | Variable is not empty |
| `"$a" = "$b"` | Strings equal |
| `$a -eq $b` | Numbers equal |
| `$a -gt $b` | Greater than |
| `$a -lt $b` | Less than |

### Exit Codes

```bash
# Check last command
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi

# Chain with &&
apt update && apt install nginx -y
```

## User Feedback

```bash
echo "Starting..."
echo "Step 1: Installing packages"
echo "Complete!"
```

## Reading Input

```bash
read -p "Enter name: " username
echo "Hello $username"
```

## Loops

### For Loop

```bash
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

for file in *.txt; do
    echo "Processing $file"
done
```

### While Loop

```bash
count=0
while [ $count -lt 5 ]; do
    echo $count
    count=$((count + 1))
done
```

## Functions

```bash
greet() {
    echo "Hello $1"
}

greet "World"
```

## Common Patterns

### Check if running as root

```bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi
```

### Exit on error

```bash
set -e  # Exit on any error
```

### Default variable value

```bash
name=${1:-"default"}
```

### Redirect output

```bash
command > file.txt      # Overwrite
command >> file.txt     # Append
command 2>&1            # Redirect errors
```

## Example Script

```bash
#!/bin/bash

# Variables
PACKAGE="nginx"

# Update and install
echo "Installing $PACKAGE..."
apt update
apt install -y $PACKAGE

# Verify
if systemctl is-active --quiet $PACKAGE; then
    echo "$PACKAGE is running"
else
    echo "Failed to start $PACKAGE"
    exit 1
fi

echo "Installation complete!"
```
