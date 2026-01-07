# Copr Automation Setup Checklist

Complete these steps to enable automatic Copr builds for your repository.

## ☑️ Prerequisites

- [ ] I have a Copr account at https://copr.fedorainfracloud.org/
- [ ] I have created a Copr project (note the name: `username/projectname`)
- [ ] I have admin access to this GitHub repository

## ☑️ Step 1: Get Copr API Token

- [ ] Logged in to Copr at https://copr.fedorainfracloud.org/
- [ ] Navigated to API settings: https://copr.fedorainfracloud.org/api/
- [ ] Clicked "Show" to reveal my API token
- [ ] Copied the entire configuration block (should look like):
  ```ini
  [copr-cli]
  login = YOUR_LOGIN
  username = YOUR_USERNAME
  token = YOUR_TOKEN
  copr_url = https://copr.fedorainfracloud.org
  ```

## ☑️ Step 2: Configure GitHub Secrets

- [ ] Opened GitHub repository settings
- [ ] Navigated to: **Settings** → **Secrets and variables** → **Actions**
- [ ] Added secret `COPR_CONFIG`:
  - Name: `COPR_CONFIG`
  - Value: (Pasted entire Copr API config from Step 1)
- [ ] Added secret `COPR_PROJECT`:
  - Name: `COPR_PROJECT`
  - Value: `username/projectname` (my actual Copr project identifier)

## ☑️ Step 3: Verify Workflow File

- [ ] Confirmed `.github/workflows/copr-build.yml` exists in my repository
- [ ] File was committed to the `main` branch
- [ ] Workflow appears in the **Actions** tab of my repository

## ☑️ Step 4: Test the Setup

### Option A: Manual Test (Recommended First)
- [ ] Went to **Actions** tab in GitHub
- [ ] Found **Trigger Copr Builds** workflow
- [ ] Clicked **Run workflow**
- [ ] Selected a test package (or left empty)
- [ ] Clicked **Run workflow** button
- [ ] Workflow started executing
- [ ] Workflow completed successfully (green checkmark)
- [ ] Checked Copr project page and saw new build

### Option B: Test with Spec File Change
- [ ] Made a small change to a spec file
- [ ] Committed and pushed to `main` branch
- [ ] Workflow automatically triggered
- [ ] Build appeared on Copr project page

## ☑️ Step 5: Verify Automation

- [ ] Confirmed Renovate is enabled on this repository
- [ ] Renovate configuration file exists: `.github/renovate.json5`
- [ ] Spec files have Renovate comments like:
  ```spec
  # renovate: datasource=github-releases depName=owner/repo
  Version:        1.0.0
  ```
- [ ] Tested that Renovate creates PRs (or wait for next upstream release)

## ☑️ Step 6: Monitor and Maintain

- [ ] Bookmarked GitHub Actions page: `https://github.com/USERNAME/copr/actions`
- [ ] Bookmarked Copr builds page: `https://copr.fedorainfracloud.org/coprs/MY_PROJECT/builds/`
- [ ] Know how to manually trigger builds if needed
- [ ] Understand the automation flow:
  ```
  New Release → Renovate PR → Merge → GitHub Actions → Copr Build
  ```

## ☑️ Troubleshooting Reference

If something doesn't work:

- [ ] Reviewed common issues in `COPR_AUTOMATION_SETUP.md`
- [ ] Checked GitHub Actions logs for error messages
- [ ] Verified secrets are correctly configured
- [ ] Confirmed Copr project exists and is accessible
- [ ] Checked that spec file structure matches: `packages/pkgname/pkgname.spec`

## 🎉 Setup Complete!

Once all items are checked, your automation is ready!

### What happens next:

1. **Automatic updates**: Renovate will monitor upstream repos and create PRs when new versions are released
2. **Review and merge**: You review Renovate PRs and merge when ready
3. **Automatic builds**: GitHub Actions detects changes and triggers Copr builds
4. **Package availability**: Built packages appear in your Copr repository

### Quick Links:

- **Quick Start Guide**: [QUICK_START.md](../QUICK_START.md)
- **Full Setup Guide**: [COPR_AUTOMATION_SETUP.md](../COPR_AUTOMATION_SETUP.md)
- **Package Template**: [PACKAGE_TEMPLATE.spec](PACKAGE_TEMPLATE.spec)
- **Copr Documentation**: https://docs.pagure.org/copr.copr/
- **Renovate Documentation**: https://docs.renovatebot.com/

---

**Date Completed**: _______________

**Notes**: