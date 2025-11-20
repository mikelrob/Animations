# GitHub Pages Setup Instructions

This repository includes a GitHub Actions workflow that automatically builds and deploys documentation to GitHub Pages.

## Enabling GitHub Pages

To enable GitHub Pages for this repository, follow these steps:

1. Go to the repository on GitHub
2. Click on **Settings** (gear icon)
3. In the left sidebar, click on **Pages** (under "Code and automation")
4. Under "Build and deployment":
   - **Source**: Select "GitHub Actions"
5. Save the configuration

## How it Works

The documentation workflow (`.github/workflows/documentation.yml`) automatically:

1. Triggers on every push to the `master` branch
2. Uses `xcodebuild docbuild` to generate Swift documentation from the source code
3. Converts the DocC archive to static HTML
4. Deploys the generated documentation to GitHub Pages

## Accessing the Documentation

Once the workflow completes successfully, the documentation will be available at:

https://mikelrob.github.io/Animations/documentation/animations/

## Manual Trigger

You can also manually trigger the documentation build:

1. Go to the **Actions** tab in the repository
2. Select the "Documentation" workflow
3. Click "Run workflow"
4. Select the branch (usually `master`)
5. Click "Run workflow"

## Requirements

- The workflow requires GitHub Pages to be enabled with "GitHub Actions" as the source
- The workflow uses macOS runners (required for Swift DocC tooling)
- Repository must have proper permissions set for the workflow (already configured in the workflow file)
