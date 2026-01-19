+++
title = "Gemini"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Set up Google Gemini and Gemini CLI"
weight = 3
+++

# Google Gemini (Recommended for Students)

**Advantages:**

- Completely free
- No usage limits on free tier
- Good code generation
- Also has free CLI tool

---

## Gemini Web Interface

### Setup

1. Navigate to [https://gemini.google.com/](https://gemini.google.com/)
2. Sign in with Google account
3. Accept terms of service
4. Start using immediately

### Verification

- Ask a test question: "Explain what SSH is"
- Verify you get a response

---

## Gemini CLI (Free)

AI assistance directly in your terminal.

**What you get:**

- 60 requests per minute, 1,000 requests per day (free)
- No API key or credit card required
- Open source (Apache 2.0 license)

---

### PC (Windows): Install Node.js First

**If you don't have Node.js installed:**

1. Download Node.js LTS from [https://nodejs.org/](https://nodejs.org/)
2. Run installer `node-v*-x64.msi`
3. Accept defaults (includes npm)
4. **Restart Git Bash after installation**

**Verify Node.js installation:**

```bash
# Restart Git Bash first
node --version
npm --version
```

**Install Gemini CLI:**

```bash
npm install -g @google/gemini-cli
```

**Verification:**

```bash
gemini --version
```

---

### Mac (Intel and ARM)

**Option A: Using Homebrew (Recommended - No Node.js needed)**

```bash
brew install gemini-cli
```

**Option B: Using npm (if you already have Node.js)**

```bash
npm install -g @google/gemini-cli
```

**If you don't have Node.js and want to use npm method:**

```bash
brew install node
npm install -g @google/gemini-cli
```

**Verification:**

```bash
gemini --version
```

**Note for ARM Mac:** Both Homebrew and Node.js support native ARM.

---

## Authentication

**First time setup:**

```bash
gemini auth login
```

- Browser will open
- Sign in with your Google account
- Grant permissions
- Return to terminal

**Verify authentication:**

```bash
gemini auth status
```

---

## Basic Usage Examples

```bash
# Ask a question
gemini "How do I list all VMs in Azure?"

# Get help with a command
gemini "What does this command do: az vm create"

# Debug an error
gemini "I got this error: 'Connection refused'. What does it mean?"

# Generate code
gemini "Write a bash script to stop all Azure VMs"
```

---

## Why Gemini is Recommended

- ✅ Completely free with no limits
- ✅ Also offers free CLI tool
- ✅ Good balance of capabilities for this course
- ✅ No credit card required

**Optional:** Set up multiple AI chatbots to compare responses and learn which works best for different tasks.
