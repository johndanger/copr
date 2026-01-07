# Copr Automation Summary

## 🎯 What Has Been Set Up

This repository now has **full automation** for building and maintaining Copr packages. When upstream projects release new versions, your packages will be automatically updated and built.

## 📁 Files Created

### Workflow Files
- **`.github/workflows/copr-build.yml`** - Main automation workflow that builds SRPMs and submits to Copr

### Documentation
- **`QUICK_START.md`** - 5-minute setup guide (START HERE!)
- **`COPR_AUTOMATION_SETUP.md`** - Detailed setup instructions and troubleshooting
- **`.github/SETUP_CHECKLIST.md`** - Step-by-step checklist to verify setup
- **`.github/PACKAGE_TEMPLATE.spec`** - Template for adding new packages
- **`AUTOMATION_SUMMARY.md`** - This file

### Existing Files (Already Configured)
- **`.github/renovate.json5`** - Renovate Bot configuration for version updates

## 🔄 The Complete Automation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Automation Flow                          │
└─────────────────────────────────────────────────────────────────┘

1. 📦 New Release Published
   └─> Upstream project (e.g., InioX/matugen) releases v3.2.0

2. 🤖 Renovate Bot Detects Update
   └─> Scans spec files with renovate comments
   └─> Detects version 3.1.0 → 3.2.0
   └─> Creates PR with updated spec file

3. 👤 You Review & Merge PR
   └─> Review the changes
   └─> Merge to main branch

4. ⚡ GitHub Actions Triggers
   └─> Detects spec file change
   └─> Identifies changed package(s)
   └─> Triggers Copr package rebuild

5. 🏗️ Copr Builds Package
   └─> Pulls from Git repository
   └─> Finds spec file and downloads sources
   └─> Builds for configured Fedora versions
   └─> Publishes to your repository

6. ✅ Package Available
   └─> Users can install with dnf/yum
   └─> Automatic updates continue
```

## 🚀 Next Steps to Complete Setup

### Required (Do These Now)

1. **Get Your Copr API Token**
   - Visit: https://copr.fedorainfracloud.org/api/
   - Copy your API configuration

2. **Configure Packages in Copr**
   - Each package must be set up as an SCM build in Copr
   - Run for each package: `copr-cli edit-package-scm YOUR_PROJECT --name PACKAGE_NAME --clone-url https://github.com/YOUR_USERNAME/copr --spec packages/PACKAGE_NAME/PACKAGE_NAME.spec --type git --method make_srpm`
   - Or configure via Copr web UI

3. **Add GitHub Secrets**
   - Go to: Repository Settings → Secrets and variables → Actions
   - Add `COPR_CONFIG` (your full Copr API config)
   - Add `COPR_PROJECT` (format: `username/projectname`)

4. **Test the Setup**
   - Go to Actions tab → "Trigger Copr Builds" → Run workflow
   - Verify build succeeds

📖 **See [QUICK_START.md](QUICK_START.md) for detailed instructions**

## 🎨 Features

### ✅ What Works Now

- ✅ **Automatic version detection** - Renovate watches upstream repos
- ✅ **Automatic PR creation** - Version updates create pull requests
- ✅ **Automatic rebuild triggers** - GitHub Actions triggers Copr rebuilds
- ✅ **SCM-based builds** - Copr pulls directly from your Git repository
- ✅ **Multi-package support** - Rebuilds only changed packages
- ✅ **Parallel builds** - Multiple packages build simultaneously
- ✅ **Manual triggers** - Can manually rebuild specific packages
- ✅ **Status summaries** - Clear build status in GitHub UI
- ✅ **No SRPM management** - Copr handles source packaging

### 🎯 Supported Package Types

The workflow supports triggering rebuilds for any package type that Copr can build:
- Rust projects (Cargo)
- Go projects
- Python projects
- C/C++ projects (Make, CMake, Meson)
- Any project with a valid RPM spec file and configured in Copr

## 📊 Current Package Status

### Packages with Renovate Auto-Update

| Package | Upstream | Auto-Update Status |
|---------|----------|-------------------|
| **cliphist** | `sentriz/cliphist` | ✅ Configured |
| **matugen** | `InioX/matugen` | ✅ Configured |
| **valent-git** | `andyholmes/valent` | ✅ Configured (git commits) |

### Packages Needing Renovate Configuration

| Package | Upstream | Action Needed |
|---------|----------|---------------|
| **mangowc** | `DreamMaoMao/mangowc` | Add renovate comment + configure in Copr |
| **scenefx** | `wlrfx/scenefx` | Add renovate comment + configure in Copr |
| **zed** | `zed-industries/zed` | Add renovate comment + configure in Copr |

To enable auto-updates for remaining packages, add this comment to their spec files:
```spec
# renovate: datasource=github-releases depName=owner/repo
Version:        x.y.z
```

## 🔧 How to Use

### Automatic Updates (Recommended)
1. Wait for Renovate to create PR
2. Review changes
3. Merge PR
4. Builds happen automatically ✨

### Manual Build (When Needed)
1. Go to **Actions** tab
2. Select **Trigger Copr Builds**
3. Click **Run workflow**
4. (Optional) Enter package name
5. Click **Run workflow** button

### Adding New Packages
1. Create `packages/newpackage/newpackage.spec`
2. Add Renovate comment for auto-updates
3. Configure package in Copr as SCM build
4. Commit and push
5. Done! 🎉

## 🔍 Monitoring

### Where to Check Build Status

- **GitHub Actions**: https://github.com/YOUR_USERNAME/copr/actions
- **Copr Builds**: https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/builds/

### What to Look For

✅ **Green checkmarks** in GitHub Actions = Build submitted successfully  
🟡 **Yellow dots** = Build in progress  
❌ **Red X's** = Build failed (check logs)  

## 🛠️ Troubleshooting

### Common Issues

| Issue | Quick Fix |
|-------|-----------|
| ❌ Authentication failed | Update `COPR_CONFIG` secret |
| ❌ SRPM build failed | Check spec file syntax |
| ❌ No builds triggered | Verify spec file was actually changed |
| ❌ Spec file not found | Ensure `packages/name/name.spec` structure |

See [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md) for detailed troubleshooting.

## 📚 Documentation Index

### Getting Started
1. 🚀 **[QUICK_START.md](QUICK_START.md)** - Start here! 5-minute setup
2. ☑️ **[.github/SETUP_CHECKLIST.md](.github/SETUP_CHECKLIST.md)** - Verify your setup

### Reference
3. 📖 **[COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md)** - Complete guide
4. 📝 **[.github/PACKAGE_TEMPLATE.spec](.github/PACKAGE_TEMPLATE.spec)** - Template for new packages
5. 📄 **[AUTOMATION_SUMMARY.md](AUTOMATION_SUMMARY.md)** - This document

### External Resources
- **Copr Docs**: https://docs.pagure.org/copr.copr/
- **Renovate Docs**: https://docs.renovatebot.com/
- **GitHub Actions**: https://docs.github.com/en/actions

## 💡 Tips & Best Practices

### For Renovate PRs
- ✅ Review PRs promptly to keep packages up-to-date
- ✅ Check upstream changelogs for breaking changes
- ✅ Test important updates before merging
- ✅ Merge during low-usage times

### For Copr Builds
- ✅ Monitor first few automated builds closely
- ✅ Set up email notifications in Copr settings
- ✅ Keep build dependencies up-to-date
- ✅ Use `--nowait` flag to avoid blocking workflows

### For Maintenance
- ✅ Check Actions tab weekly for failed builds
- ✅ Update Renovate configuration as needed
- ✅ Document any custom build requirements
- ✅ Keep secrets up-to-date if tokens expire

## 🎉 Benefits of This Setup

### Before Automation
- 😓 Manual version checking
- 😓 Manual spec file updates
- 😓 Manual build triggering
- 😓 Manual monitoring
- ⏰ Hours of work per update

### After Automation
- ✅ Automatic version detection
- ✅ Automatic spec updates via PR
- ✅ Automatic build triggering
- ✅ Automatic Copr rebuilds
- ⏰ Minutes of work (just merge PR)

## 🔐 Security Considerations

- 🔒 API tokens stored as encrypted GitHub secrets
- 🔒 Secrets never exposed in logs or outputs
- 🔒 Workflow only runs on main branch (not external PRs)
- 🔒 Manual approval required for Renovate PRs
- 🔒 Copr builds run in isolated environments

## ❓ FAQ

**Q: Will this build on every commit?**  
A: No, only when spec files in `packages/*/` change on the main branch.

**Q: What if I don't want to build a package right away?**  
A: Don't merge the Renovate PR. Build when you're ready.

**Q: Can I disable automation temporarily?**  
A: Yes, disable the workflow in Settings → Actions → Workflows.

**Q: How much does this cost?**  
A: GitHub Actions is free for public repos. Copr is free for open source.

**Q: What if an upstream project changes their release format?**  
A: Update the Renovate comment in the spec file with the correct datasource.

**Q: Can I test builds locally before pushing?**  
A: Yes, use `rpmbuild` locally to test spec files before committing changes.

## 🤝 Contributing

To add new packages:
1. Use [.github/PACKAGE_TEMPLATE.spec](.github/PACKAGE_TEMPLATE.spec)
2. Follow the structure: `packages/pkgname/pkgname.spec`
3. Configure package in Copr as SCM build
4. Add Renovate comment for auto-updates
5. Submit PR

## 📞 Getting Help

If you encounter issues:
1. Check the troubleshooting section in `COPR_AUTOMATION_SETUP.md`
2. Review GitHub Actions logs for error messages
3. Check Copr build logs for build failures
4. Verify your secrets are correctly configured

---

## ✅ Setup Status

- [x] Workflow file created
- [x] Documentation written
- [ ] **Packages configured in Copr** ← DO THIS FIRST
- [ ] **Secrets configured** ← THEN THIS
- [ ] **Test build successful** ← FINALLY THIS
- [ ] Automation fully operational

**Next Action**: Follow [QUICK_START.md](QUICK_START.md) to complete setup!

---

*Last Updated: 2024-01-06*  
*Automation Version: 1.0*