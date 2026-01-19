+++
title = "Initialize a Local Git Repository"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Learn Git fundamentals: initialize a repository, track changes, and create commits"
weight = 1
+++

# Initialize a Local Git Repository

## Goal

Learn the fundamentals of Git version control by initializing a repository, understanding the staging area, and creating your first commits.

> **What you'll learn:**
>
> - What version control is and why developers use it
> - How to initialize a Git repository
> - The difference between the working directory, staging area, and repository
> - How to create commits that track your changes over time

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ A Flask project directory (from the Hello World Flask exercise or similar)
> - ✓ Git installed on your machine
> - ✓ Terminal (macOS/Linux) or Git Bash (Windows)

To verify Git is installed, run:

```bash
git --version
```

You should see output like `git version 2.x.x`. If not, install Git from [git-scm.com](https://git-scm.com/).

## Exercise Steps

### Overview

1. **Understand Version Control Basics**
2. **Create a .gitignore File**
3. **Initialize the Repository**
4. **Explore with git status**
5. **Stage and Commit Your Files**

### **Step 1:** Understand Version Control Basics

Version control is a system that records changes to files over time. It allows you to recall specific versions later, see who changed what, and collaborate with others without overwriting each other's work.

Git is a distributed version control system, meaning every developer has a complete copy of the project history on their machine. This makes Git fast, reliable, and enables offline work.

> ℹ **Concept Deep Dive**
>
> Git tracks changes through **commits** - snapshots of your project at a specific point in time. Each commit has:
>
> - A unique identifier (hash)
> - A message describing the change
> - A pointer to the previous commit (parent)
> - The actual changes made
>
> Before files become part of a commit, they go through the **staging area** (also called the index). This intermediate step lets you choose exactly which changes to include in each commit.
>
> ```
> Working Directory → Staging Area → Repository
>       (edit)          (add)        (commit)
> ```
>
> ✓ **Quick check:** You understand that Git tracks changes through commits, not by saving entire files

### **Step 2:** Create a .gitignore File

Before initializing Git, create a `.gitignore` file to tell Git which files and directories to ignore. This prevents temporary files, dependencies, and sensitive data from being tracked.

1. **Navigate to** your Flask project directory:

   ```bash
   cd ~/your-workspace-directory/hello-flask
   ```

2. **Create** a new file named `.gitignore`

3. **Add** the following content:

   > `.gitignore`

   ```text
   # Virtual environment
   .venv/
   venv/
   ENV/

   # Python cache
   __pycache__/
   *.py[cod]
   *$py.class

   # IDE settings
   .vscode/
   .idea/

   # OS files
   .DS_Store
   Thumbs.db
   ```

> ℹ **Concept Deep Dive**
>
> The `.gitignore` file uses pattern matching:
>
> - Lines starting with `#` are comments
> - `folder/` ignores an entire directory
> - `*.pyc` ignores all files ending in `.pyc`
> - `*.py[cod]` ignores `.pyc`, `.pyo`, and `.pyd` files
>
> We ignore `.venv/` because virtual environments are large and can be recreated from `requirements.txt`. We ignore `__pycache__/` because these are compiled Python files that Python regenerates automatically.
>
> ⚠ **Common Mistakes**
>
> - Creating the file as `gitignore` instead of `.gitignore` (note the leading dot)
> - Adding files to `.gitignore` after they've already been tracked (they will remain tracked)
>
> ✓ **Quick check:** File created as `.gitignore` (with the leading dot) in your project root

### **Step 3:** Initialize the Repository

Now turn your project directory into a Git repository. This creates a hidden `.git` folder that stores all of Git's tracking information.

1. **Ensure** you are in your project directory:

   ```bash
   pwd
   ```

   This should show the path to your `hello-flask` directory.

2. **Initialize** the Git repository:

   ```bash
   git init
   ```

   You should see output like:

   ```
   Initialized empty Git repository in /path/to/hello-flask/.git/
   ```

3. **Verify** the repository was created:

   ```bash
   ls -la
   ```

   You should see a `.git` directory in the listing.

> ℹ **Concept Deep Dive**
>
> The `git init` command creates a `.git` directory containing:
>
> - `HEAD` - points to the current branch
> - `config` - repository-specific configuration
> - `objects/` - stores all commits, files, and trees
> - `refs/` - stores branch and tag pointers
>
> You never need to edit these files directly. Git manages them through its commands.
>
> ✓ **Quick check:** Running `ls -la` shows a `.git` directory

### **Step 4:** Explore with git status

The `git status` command is your window into the current state of the repository. Use it frequently to understand what Git sees.

1. **Check** the repository status:

   ```bash
   git status
   ```

   You should see output similar to:

   ```
   On branch main

   No commits yet

   Untracked files:
     (use "git add <file>..." to include in what will be committed)
           .gitignore
           app.py
           requirements.txt

   nothing added to commit but untracked files present (use "git add" to track)
   ```

2. **Notice** what Git shows:

   - The current branch (`main`)
   - That there are no commits yet
   - A list of **untracked files** (files Git sees but isn't tracking)
   - The `.venv/` directory is NOT listed (because `.gitignore` is working)

> ℹ **Concept Deep Dive**
>
> Files in Git can be in several states:
>
> - **Untracked** - Git sees the file but isn't tracking it
> - **Staged** - File is marked to be included in the next commit
> - **Committed** - File is safely stored in the repository
> - **Modified** - Tracked file has been changed since the last commit
>
> The `git status` command always tells you what state your files are in and suggests what to do next.
>
> ✓ **Quick check:** The `.venv` directory does not appear in `git status` output

### **Step 5:** Stage and Commit Your Files

Now create your first commit by staging files and then committing them with a descriptive message.

1. **Stage all files** for the first commit:

   ```bash
   git add .
   ```

   The `.` means "all files in the current directory."

2. **Check** the status again:

   ```bash
   git status
   ```

   You should now see:

   ```
   On branch main

   No commits yet

   Changes to be committed:
     (use "git rm --cached <file>..." to unstage)
           new file:   .gitignore
           new file:   app.py
           new file:   requirements.txt
   ```

   The files are now in the **staging area**, ready to be committed.

3. **Create** your first commit:

   ```bash
   git commit -m "Initial commit: Hello Flask application"
   ```

   You should see output like:

   ```
   [main (root-commit) abc1234] Initial commit: Hello Flask application
    3 files changed, 25 insertions(+)
    create mode 100644 .gitignore
    create mode 100644 app.py
    create mode 100644 requirements.txt
   ```

4. **Verify** the commit was created:

   ```bash
   git log --oneline
   ```

   You should see your commit:

   ```
   abc1234 Initial commit: Hello Flask application
   ```

> ℹ **Concept Deep Dive**
>
> The commit workflow has two steps:
>
> 1. `git add` stages files (selects what to include)
> 2. `git commit` creates the snapshot (saves the staged changes)
>
> The `-m` flag lets you write the commit message inline. Without it, Git opens a text editor for you to write the message.
>
> A good commit message:
>
> - Starts with a capital letter
> - Uses imperative mood ("Add feature" not "Added feature")
> - Is concise but descriptive
> - Explains what and why, not how
>
> ⚠ **Common Mistakes**
>
> - Forgetting to stage files before committing (commit will fail or be empty)
> - Writing vague messages like "fix" or "update" that don't explain the change
>
> ✓ **Quick check:** Running `git log --oneline` shows your commit

## Practice: Make a Change and Commit Again

Reinforce what you've learned by making a small change and committing it.

1. **Open** `app.py` in your editor

2. **Change** the return message to something different:

   ```python
   @app.route('/')
   def hello():
       return 'Hello, Git!'
   ```

3. **Save** the file

4. **Check** the status:

   ```bash
   git status
   ```

   You should see:

   ```
   On branch main
   Changes not staged for commit:
     (use "git add <file>..." to update what will be committed)
     (use "git restore <file>..." to discard changes in working directory)
           modified:   app.py

   no changes added to commit (use "git add" and/or "git commit -a")
   ```

5. **Stage and commit** the change:

   ```bash
   git add app.py
   git commit -m "Update greeting message"
   ```

6. **View** the commit history:

   ```bash
   git log --oneline
   ```

   You should now see two commits:

   ```
   def5678 Update greeting message
   abc1234 Initial commit: Hello Flask application
   ```

> ✓ **Practice complete:** You've successfully made a change, staged it, and committed it

## Common Issues

> **If you encounter problems:**
>
> **"git: command not found":** Git is not installed. Download it from [git-scm.com](https://git-scm.com/)
>
> **Files in .gitignore still appear in git status:** If you added files before creating `.gitignore`, they're already tracked. Remove them with `git rm --cached filename` to untrack them without deleting the actual file
>
> **Commit message editor opens unexpectedly:** If you forget the `-m` flag, Git opens the default editor. Type your message, save, and close the file. Or press `Esc` and type `:q!` to quit without saving (in vim)
>
> **"Please tell me who you are" error:** Configure your identity:
> ```bash
> git config --global user.name "Your Name"
> git config --global user.email "your.email@example.com"
> ```
>
> **Still stuck?** Run `git status` - it usually suggests what to do next

## Summary

You've successfully initialized a Git repository and created commits which:

- ✓ Tracks your project files with version control
- ✓ Excludes temporary and generated files via `.gitignore`
- ✓ Creates a history of changes you can review and revert to

> **Key takeaway:** The Git workflow of `edit → add → commit` becomes second nature with practice. Use `git status` frequently to understand what state your files are in. Every commit is a checkpoint you can return to if something goes wrong.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Use `git diff` to see what changed before staging
> - Use `git diff --staged` to see what's staged before committing
> - Try `git log` (without `--oneline`) to see full commit details
> - Research `.gitignore` patterns for your specific IDE and operating system at [gitignore.io](https://www.toptal.com/developers/gitignore)
> - Learn about `git restore` to discard changes you don't want

## Done! 🎉

You've mastered the fundamentals of local Git version control. Your project now has a complete history of changes, and you can confidently track future modifications. The next step is connecting your local repository to GitHub so you can back up your code and collaborate with others.
