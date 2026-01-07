# Copr Automation Documentation Index

**Quick Navigation** | [Setup](#-setup-guides) | [Reference](#-reference-guides) | [Troubleshooting](#-troubleshooting) | [Examples](#-examples)

---

## 📚 Documentation Overview

This repository contains complete automation for building and maintaining Copr packages. All the tools and documentation you need are organized below.

---

## 🚀 Setup Guides

**Start here if you're setting up for the first time:**

### 1. Quick Start (5 minutes)
📄 **[QUICK_START.md](QUICK_START.md)** (you are in docs/)
- Fastest way to get up and running
- Step-by-step setup instructions
- Common operations cheat sheet
- Perfect for: First-time setup

### 2. Detailed Setup Guide
📄 **[COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md)** (you are in docs/)
- Complete setup walkthrough
- Detailed explanations
- Troubleshooting section
- Security considerations
- Perfect for: Understanding how everything works

### 3. Setup Checklist
📄 **[../.github/SETUP_CHECKLIST.md](../.github/SETUP_CHECKLIST.md)**
- Interactive checklist format
- Track your progress
- Verify everything is configured correctly
- Perfect for: Making sure nothing is missed

---

## 📖 Reference Guides

**Use these for day-to-day operations:**

### Command Reference
📄 **[COMMANDS.md](COMMANDS.md)**
- All commands in one place
- GitHub Actions commands
- Copr CLI commands
- Local build commands
- Debugging commands
- Useful one-liners
- Perfect for: Quick command lookup

### Automation Summary
📄 **[AUTOMATION_SUMMARY.md](AUTOMATION_SUMMARY.md)**
- Complete system overview
- Flow diagrams
- Feature list
- Package status
- Benefits and FAQ
- Perfect for: Understanding the big picture

### Workflow Diagram
📄 **[WORKFLOW_DIAGRAM.txt](WORKFLOW_DIAGRAM.txt)**
- Visual ASCII workflow
- Step-by-step process flow
- Timeline estimates
- Trigger points
- Error handling
- Perfect for: Visual learners

---

## 🛠️ Templates & Tools

### Package Template
📄 **[PACKAGE_TEMPLATE.spec](PACKAGE_TEMPLATE.spec)** (you are in docs/)
- Template spec file
- Common build patterns
- Renovate comment examples
- Perfect for: Adding new packages

### Package Dependencies
📄 **[PACKAGE_DEPENDENCIES.md](PACKAGE_DEPENDENCIES.md)**
- Comprehensive dependency guide
- scenefx → mangowc example
- Build order handling
- Perfect for: Understanding package dependencies

📄 **[DEPENDENCIES_QUICK_REF.md](DEPENDENCIES_QUICK_REF.md)**
- Quick reference for dependencies
- Common commands
- Troubleshooting
- Perfect for: Quick dependency lookups

### GitHub Actions Workflow
📄 **[../.github/workflows/copr-build.yml](../.github/workflows/copr-build.yml)**
- Main automation workflow
- Dependency-aware build ordering
- Copr rebuild triggers
- Perfect for: Understanding/modifying automation

### Renovate Configuration
📄 **[../.github/renovate.json5](../.github/renovate.json5)**
- Renovate Bot settings
- Custom managers for spec files
- Version detection patterns
- Perfect for: Configuring auto-updates

### Setup Script
📄 **[../scripts/setup-copr-packages.sh](../scripts/setup-copr-packages.sh)**
- Automated package configuration
- Configures all packages in Copr at once
- Perfect for: Initial setup

### Security Documentation
📄 **[SECURITY.md](SECURITY.md)**
- Security best practices
- Secret handling and protection
- Threat model and incident response
- Credential rotation procedures
- Perfect for: Understanding security measures

---

## 🎯 Quick Links by Task

### I want to...

#### Set up automation for the first time
1. Read [QUICK_START.md](QUICK_START.md)
2. Follow [../.github/SETUP_CHECKLIST.md](../.github/SETUP_CHECKLIST.md)
3. Test with manual workflow run

#### Add a new package
1. Copy [PACKAGE_TEMPLATE.spec](PACKAGE_TEMPLATE.spec)
2. Customize for your package
3. Add Renovate comment
4. Commit and push

#### Manually trigger a build
1. Go to Actions tab in GitHub
2. Select "Trigger Copr Builds"
3. Click "Run workflow"

#### Check build status
- **GitHub Actions**: https://github.com/YOUR_USERNAME/copr/actions
- **Copr Builds**: https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/builds/

#### Troubleshoot a failed build
1. Check [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md) troubleshooting section
2. Review GitHub Actions logs
3. Check Copr build logs
4. Consult [COMMANDS.md](COMMANDS.md) for debugging commands

#### Update a package version manually
1. Edit the spec file
2. Update `Version:` line
3. Commit and push to main
4. Build triggers automatically

#### Find a specific command
1. Open [COMMANDS.md](COMMANDS.md)
2. Use search (Ctrl+F) to find what you need
3. Copy and customize the command

---

## 📊 System Components

### What each piece does:

```
┌─────────────────┐
│  Renovate Bot   │ → Detects new versions, creates PRs
└─────────────────┘
         ↓
┌─────────────────┐
│  GitHub Actions │ → Builds SRPMs, submits to Copr
└─────────────────┘
         ↓
┌─────────────────┐
│  Copr           │ → Builds packages, publishes to repo
└─────────────────┘
```

---

## 🔧 Configuration Files

| File | Purpose | Modify? |
|------|---------|---------|
| `../.github/workflows/copr-build.yml` | Main automation | Rarely |
| `../.github/renovate.json5` | Version detection | Occasionally |
| `../packages/*/*.spec` | Package definitions | Frequently |

---

## 📈 Workflow States

### Automatic Flow
```
New Release → Renovate PR → You Merge → GitHub Actions → Copr → Package Available
```

### Manual Flow
```
GitHub Actions UI → Run Workflow → Copr → Package Available
```

---

## 🆘 Troubleshooting

### Common Issues Quick Reference

| Symptom | Check | Solution Guide |
|---------|-------|----------------|
| ❌ No builds triggering | Spec file changed? | [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md#issue-builds-not-triggering-automatically) |
| ❌ Authentication failed | COPR_CONFIG secret | [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md#issue-authentication-failed) |
| ❌ SRPM build failed | Spec syntax | [COMMANDS.md](COMMANDS.md#check-spec-file-syntax) |
| ❌ Copr build failed | Build logs | [COMMANDS.md](COMMANDS.md#monitor-copr-builds) |

---

## 📦 Current Packages

Located in `packages/` directory:

- **cliphist** - Clipboard history manager for Wayland
- **mangowc** - Wayland compositor component (depends on scenefx)
- **matugen** - Material you color generation tool
- **scenefx** - Eye-candy effects for wlroots (dependency for mangowc)
- **valent-git** - Device sync and control
- **zed** - High-performance code editor

### Dependency Chain
```
scenefx (base library)
    ↓
mangowc (depends on scenefx)
```

See [PACKAGE_DEPENDENCIES.md](PACKAGE_DEPENDENCIES.md) for details.

---

## 🎓 Learning Path

### Beginner
1. Start with [QUICK_START.md](QUICK_START.md)
2. Complete [.github/SETUP_CHECKLIST.md](.github/SETUP_CHECKLIST.md)
3. Trigger first manual build
4. Review [AUTOMATION_SUMMARY.md](AUTOMATION_SUMMARY.md)

### Intermediate
1. Study [WORKFLOW_DIAGRAM.txt](WORKFLOW_DIAGRAM.txt)
2. Read [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md) fully
3. Add a new package using template
4. Customize Renovate settings

### Advanced
1. Modify `.github/workflows/copr-build.yml`
2. Use [COMMANDS.md](COMMANDS.md) for local builds
3. Set up custom build configurations
4. Optimize workflow performance

---

## 🔗 External Resources

- **Copr Documentation**: https://docs.pagure.org/copr.copr/
- **Renovate Documentation**: https://docs.renovatebot.com/
- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **RPM Packaging Guide**: https://rpm-packaging-guide.github.io/
- **Fedora Packaging Guidelines**: https://docs.fedoraproject.org/en-US/packaging-guidelines/

---

## 📞 Getting Help

### Documentation Not Clear?
1. Check all sections of this index
2. Use search in relevant guide
3. Review examples in [COMMANDS.md](COMMANDS.md)

### Build Failing?
1. Check error message in GitHub Actions logs
2. Consult troubleshooting section in [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md)
3. Review Copr build logs

### Adding New Features?
1. Review [.github/workflows/copr-build.yml](.github/workflows/copr-build.yml)
2. Consult GitHub Actions documentation
3. Test changes carefully

---

## ✅ Quick Checklist

Before you start using the automation:

- [ ] Read [QUICK_START.md](QUICK_START.md)
- [ ] Configure GitHub secrets (COPR_CONFIG, COPR_PROJECT)
- [ ] Run test build
- [ ] Bookmark this INDEX.md for quick reference
- [ ] Bookmark [COMMANDS.md](COMMANDS.md) for daily use

---

## 📝 File Overview

| File | Lines | Purpose | Read Time |
|------|-------|---------|-----------|
| [INDEX.md](INDEX.md) | ~350 | Navigation hub | 5 min |
| [QUICK_START.md](QUICK_START.md) | ~180 | Fast setup | 5 min |
| [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md) | ~360 | Detailed guide | 20 min |
| [AUTOMATION_SUMMARY.md](AUTOMATION_SUMMARY.md) | ~282 | System overview | 10 min |
| [COMMANDS.md](COMMANDS.md) | ~540 | Command reference | As needed |
| [WORKFLOW_DIAGRAM.txt](WORKFLOW_DIAGRAM.txt) | ~356 | Visual guide | 10 min |
| [PACKAGE_DEPENDENCIES.md](PACKAGE_DEPENDENCIES.md) | ~320 | Dependency guide | 15 min |
| [DEPENDENCIES_QUICK_REF.md](DEPENDENCIES_QUICK_REF.md) | ~146 | Dependency quick ref | 5 min |
| [UPDATED_WORKFLOW.md](UPDATED_WORKFLOW.md) | ~280 | SCM workflow guide | 10 min |
| [SECURITY.md](SECURITY.md) | ~330 | Security guide | 15 min |
| [../.github/SETUP_CHECKLIST.md](../.github/SETUP_CHECKLIST.md) | ~114 | Setup tracker | 5 min |
| [PACKAGE_TEMPLATE.spec](PACKAGE_TEMPLATE.spec) | ~76 | Template | 5 min |

**Total documentation**: ~3,300+ lines | Comprehensive coverage

---

## 🎯 Most Important Files

If you only read three files, make them:

1. **[QUICK_START.md](QUICK_START.md)** - Get started in 5 minutes
2. **[COMMANDS.md](COMMANDS.md)** - Daily command reference
3. **[AUTOMATION_SUMMARY.md](AUTOMATION_SUMMARY.md)** - Understand the system

If you have packages with dependencies, also read:
4. **[DEPENDENCIES_QUICK_REF.md](DEPENDENCIES_QUICK_REF.md)** - Dependency handling

For security concerns:
5. **[SECURITY.md](SECURITY.md)** - Security best practices

---

## 🚀 Next Steps

**Right now:**
1. Open [QUICK_START.md](QUICK_START.md)
2. Follow the setup steps
3. Run your first build

**This week:**
1. Read [COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md)
2. Set up all packages with Renovate
3. Wait for first automatic update

**This month:**
1. Add new packages using template
2. Optimize your workflow
3. Enjoy fully automated package management! 🎉

---

**Last Updated**: 2024-01-06  
**Automation Version**: 1.0  
**Status**: ✅ Complete and ready to use

*Happy building!* 🚀