# Copr Automation Setup Guide

This guide will help you set up automatic Copr builds triggered by GitHub Actions when spec files are updated (either manually or by Renovate Bot).

## Overview

The automation workflow consists of:
1. **Renovate Bot** - Automatically detects new upstream releases and updates spec files
2. **GitHub Actions** - Detects spec file changes and triggers Copr package rebuilds
3. **Copr SCM Builds** - Copr pulls from your Git repository and builds packages

## Prerequisites

- A Copr account at https://copr.fedorainfracloud.org/
- A Copr project created (e.g., `username/projectname`)
- Admin access to this GitHub repository
- Each package configured in Copr as an SCM build

## Setup Steps

### Step 1: Get Your Copr API Token

1. Log in to Copr: https://copr.fedorainfracloud.org/
2. Go to your API settings: https://copr.fedorainfracloud.org/api/
3. Click on "Show" to reveal your API token
4. Copy the entire configuration block that looks like this:

```ini
[copr-cli]
login = YOUR_LOGIN_HERE
username = YOUR_USERNAME
token = YOUR_TOKEN_HERE
copr_url = https://copr.fedorainfracloud.org
```

### Step 2: Configure Packages in Copr

**Important:** Each package must be configured in Copr to build from your Git repository.

#### Option A: Using Copr CLI (Recommended)

For each package in your `packages/` directory, run:

```bash
# Install copr-cli if needed
sudo dnf install -y copr-cli

# Configure copr-cli (use token from Step 1)
copr-cli --config

# Add or update each package
copr-cli edit-package-scm YOUR_PROJECT \
  --name matugen \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/matugen/matugen.spec \
  --type git \
  --method make_srpm

# Repeat for each package
copr-cli edit-package-scm YOUR_PROJECT \
  --name cliphist \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/cliphist/cliphist.spec \
  --type git \
  --method make_srpm
```

**Note:** Replace `YOUR_PROJECT` with your Copr project identifier (e.g., `username/projectname`) and `YOUR_USERNAME` with your GitHub username.

#### Option B: Using Copr Web UI

For each package:

1. Go to your Copr project page
2. Click on **Packages** tab
3. Click **New Package** → **SCM**
4. Fill in the form:
   - **Package name**: Must match directory name (e.g., `matugen`)
   - **Clone URL**: `https://github.com/YOUR_USERNAME/copr`
   - **Committish**: `main` (or your default branch)
   - **Subdirectory**: Leave empty
   - **Spec File**: `packages/matugen/matugen.spec`
   - **Type**: `Git`
   - **Method**: `make_srpm`
5. Click **Create**
6. Repeat for all packages

#### Verify Package Configuration

List all configured packages:
```bash
copr-cli list-packages YOUR_PROJECT
```

You should see all your packages listed.

### Step 3: Add GitHub Secrets

1. Go to your GitHub repository settings
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

#### Secret 1: COPR_CONFIG
- **Name:** `COPR_CONFIG`
- **Value:** Paste the entire Copr API configuration block from Step 1

#### Secret 2: COPR_PROJECT
- **Name:** `COPR_PROJECT`
- **Value:** Your Copr project identifier in the format `username/projectname`
  - Example: `metcya/mangosteenos` (replace with your actual username and project name)

### Step 4: Verify the Workflow File

The workflow file `.github/workflows/copr-build.yml` has been created with the following features:

- ✅ Triggers on pushes to `main` branch when spec files change
- ✅ Manual trigger option via GitHub Actions UI
- ✅ Detects which packages changed
- ✅ Rebuilds only the changed packages
- ✅ Parallel builds for multiple packages
- ✅ Build status summary

### Step 5: Test the Setup

#### Option A: Manual Test (Recommended First)

1. Go to **Actions** tab in your GitHub repository
2. Select **Trigger Copr Builds** workflow
3. Click **Run workflow**
4. Optionally specify a package name (e.g., `matugen`) or leave empty to build all
5. Click **Run workflow** button
6. Monitor the workflow execution

#### Option B: Test with a Spec File Change

1. Make a small change to a spec file (e.g., update a comment)
   ```bash
   # Edit a spec file
   nano packages/matugen/matugen.spec
   
   # Commit and push
   git add packages/matugen/matugen.spec
   git commit -m "test: trigger copr build"
   git push origin main
   ```

2. Go to the **Actions** tab to see the workflow running
3. Check your Copr project page for the new build

### Step 6: Monitor Builds

After triggering a build, you can monitor it at:
- **GitHub Actions:** https://github.com/YOUR_USERNAME/copr/actions
- **Copr Builds:** https://copr.fedorainfracloud.org/coprs/YOUR_USERNAME/YOUR_PROJECT/builds/

## How It Works

### Automatic Flow

1. **Renovate Bot detects new release** → Creates PR with updated spec file
2. **You merge the PR** → Pushes to main branch
3. **GitHub Actions detects spec change** → Identifies which package(s) changed
4. **Workflow triggers Copr rebuild** → Uses `copr-cli build-package` command
5. **Copr pulls from Git** → Clones repo, finds spec file, downloads sources
6. **Copr builds the package** → Builds for all configured chroots
7. **Package becomes available** → Published to your repository

### Workflow Triggers

The workflow runs when:
- ✅ A spec file is modified and pushed to `main` branch
- ✅ Manually triggered via GitHub Actions UI

## Troubleshooting

### Issue: "Authentication failed"

**Cause:** Copr API token is incorrect or expired

**Solution:**
1. Regenerate your Copr API token at https://copr.fedorainfracloud.org/api/
2. Update the `COPR_CONFIG` secret in GitHub
3. Make sure the token includes all required fields (login, username, token, copr_url)

### Issue: "Package not found"

**Cause:** The package is not configured in Copr

**Solution:**
1. Verify package exists in Copr:
   ```bash
   copr-cli list-packages YOUR_PROJECT
   ```
2. If missing, add the package using Step 2 instructions
3. Ensure package name matches directory name in `packages/`

### Issue: "Spec file not found" (in Copr build logs)

**Cause:** The spec file path is incorrect in Copr package configuration

**Solution:**
Ensure your package structure follows this pattern:
```
packages/
  packagename/
    packagename.spec
```

And the Copr package configuration has:
- **Spec File**: `packages/packagename/packagename.spec`

### Issue: "copr-cli: command not found"

**Cause:** The workflow failed to install copr-cli

**Solution:**
This should be automatic. The workflow uses a Fedora container to properly install `copr-cli` with DNF. Check the workflow logs if issues persist.

### Issue: Builds not triggering automatically

**Cause:** Renovate PRs might not trigger workflows by default (GitHub security)

**Solution:**
1. Manually merge Renovate PRs - the merge commit will trigger the workflow
2. Or configure Renovate to use a PAT (Personal Access Token) instead of the default GITHUB_TOKEN

### Issue: "No changes detected"

**Cause:** The spec file wasn't actually modified in the commit

**Solution:**
1. Verify the spec file path is correct: `packages/*/*.spec`
2. Check the commit diff to ensure spec file was changed
3. Make sure you're pushing to the `main` branch

### Issue: Copr build fails

**Cause:** Various reasons - missing dependencies, source download failure, compilation errors

**Solution:**
1. Check Copr build logs at https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/builds/
2. Click on the failed build to see detailed logs
3. Common issues:
   - Missing BuildRequires in spec file
   - Incorrect Source URL
   - Upstream tarball not available
   - Build failures in the code itself

## Customization Options

### Build Only on Merged PRs

To avoid building on every commit, you can add a condition:

```yaml
jobs:
  detect-changes:
    if: github.event.head_commit.author.username != 'renovate[bot]' || github.event.commits[0].message contains '[build]'
```

### Build All Packages

To build all packages regardless of changes, modify the workflow or use manual trigger with an empty package name.

### Add Notifications

You can add Slack, Discord, or email notifications by adding steps to the `notify` job:

```yaml
- name: Send notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Copr builds completed'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## Security Notes

- ✅ Copr API tokens are stored as encrypted GitHub secrets
- ✅ Tokens are never exposed in logs (using heredoc to write config file)
- ✅ Workflow uses Fedora container to safely install copr-cli
- ✅ Config file has 600 permissions (owner read/write only)
- ✅ The workflow only has access to secrets, not your local credentials
- ⚠️ Be careful about building from external PRs (disabled by default)
- ✅ Copr builds from your repository, ensuring source code authenticity

### How Secrets Are Protected

The workflow uses a heredoc (`<< 'EOF'`) to write the Copr configuration to prevent the secret from appearing in command-line arguments or logs:

```yaml
cat > ~/.config/copr << 'EOF'
${{ secrets.COPR_CONFIG }}
EOF
chmod 600 ~/.config/copr
```

This is more secure than using `echo` which could expose the secret in process listings.

## Package Configuration Template

When adding a new package to Copr, use this template:

```bash
copr-cli edit-package-scm YOUR_PROJECT \
  --name PACKAGE_NAME \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/PACKAGE_NAME/PACKAGE_NAME.spec \
  --type git \
  --method make_srpm \
  --webhook-rebuild on
```

The `--webhook-rebuild on` option allows Copr to rebuild automatically when you push to GitHub (requires webhook setup).

## Advanced: Copr Webhooks

For even faster automation, you can set up webhooks:

1. In your Copr project settings, enable webhooks
2. Add the webhook URL to your GitHub repository settings
3. Copr will rebuild automatically on push (without GitHub Actions)

However, using GitHub Actions gives you more control and visibility.

## Getting Help

- **Copr Documentation:** https://docs.pagure.org/copr.copr/
- **Copr CLI Manual:** https://docs.pagure.org/copr.copr/user_documentation.html#cli
- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Renovate Docs:** https://docs.renovatebot.com/

## Current Status

- ✅ Renovate configured to detect version updates
- ✅ GitHub Actions workflow created
- ⏳ Copr packages need to be configured (see Step 2)
- ⏳ Secrets need to be configured (see Step 3)
- ⏳ Test run needed (see Step 5)

Once you complete Steps 2, 3, and 5, your automation will be fully operational! 🚀

## Quick Command Reference

```bash
# List packages in Copr project
copr-cli list-packages YOUR_PROJECT

# Manually trigger a package rebuild
copr-cli build-package --name PACKAGE_NAME YOUR_PROJECT

# Check package configuration
copr-cli get-package YOUR_PROJECT --name PACKAGE_NAME

# Delete a package from Copr
copr-cli delete-package YOUR_PROJECT --name PACKAGE_NAME

# List recent builds
copr-cli list-builds YOUR_PROJECT --limit 10
```

## Summary Checklist

Before your automation is ready:

- [ ] Copr API token obtained
- [ ] All packages configured in Copr as SCM builds
- [ ] GitHub secrets added (COPR_CONFIG, COPR_PROJECT)
- [ ] Test build triggered manually
- [ ] Test build completed successfully
- [ ] Renovate creating PRs correctly
- [ ] Merge test PR and verify automatic build

Once all items are checked, you have fully automatic package management! 🎉