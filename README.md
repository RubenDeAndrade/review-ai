# Review AI

An automated code review tool that uses GitHub Copilot to analyze pull requests and provide feedback based on your team's standards.

## Features

- Automated code reviews using GitHub Copilot or OpenAI API
- Configurable review standards based on your team's guidelines
- Direct integration with GitHub pull requests
- VSCode integration for seamless workflow
- Support for detailed review feedback including line-specific comments

## Setup

### Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- `jq` command-line tool installed
- GitHub Copilot CLI extension installed (`gh extension install github/gh-copilot`)
- Git

### Environment Configuration

1. Copy the example environment file:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your specific configuration:
   - Add your GitHub token for authentication
   - Configure review verbosity and style
   - If using the Python script, add your OpenAI API key

### VSCode Integration

This project includes VSCode integration:

- Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on macOS) to run the default review task
- Use the "Run Task" command to select specific review tasks
- Configure tasks in `.vscode/tasks.json`
- Debug scripts with launch configurations in `.vscode/launch.json`

## Usage

### Command Line

```bash
# Review a specific PR
./automated-review.sh 123

# Review current branch's PR
./automated-review.sh
```

### VSCode

1. Open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P` on macOS)
2. Type "Tasks: Run Task"
3. Select "Run PR Review" or other review tasks

## Review Instructions

Review instructions are stored in `.github/instructions/github-review.instructions.md`.
Edit this file to customize the review criteria based on your team's standards.
