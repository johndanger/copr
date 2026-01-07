# Updated Workflow - SCM-Based Copr Builds

## 🎯 What Changed

The workflow has been **simplified and optimized** to work with Copr's native SCM (Source Code Management) build system.

### Before (Original Plan)
```
GitHub Actions → Build SRPM locally → Upload SRPM → Copr builds package
```

### After (Current Implementation)
```
GitHub Actions → Trigger rebuild → Copr pulls from Git → Copr builds package
```

## ✨ Key Improvements

### 1. **Simpler Workflow**
- ❌ No local SRPM building required
- ❌ No spectool/rpmbuild in GitHub Actions
- ❌ No SRPM artifact management
- ✅ Just one simple command: `copr-cli build-package`

### 2. **Faster Execution**
- GitHub Actions job completes in seconds instead of minutes
- No dependency installation overhead
- No source downloading in Actions
- Copr handles everything after trigger

### 3. **Better Integration**
- Uses Copr's native package management system
- Each package is properly configured in Copr
- Copr tracks package configurations
- Webhook support for even faster automation

### 4. **More Reliable**
- Copr handles source downloading (more reliable infrastructure)
- Consistent build environment
- Less can go wrong in GitHub Actions
- Easier to debug (failures show up in Copr logs)

## 🏗️ Architecture

### Package Configuration (One-time Setup)

Each package is configured in Copr with:
- **Package name**: Matches directory name
- **Clone URL**: Your GitHub repository
- **Spec file path**: `packages/PACKAGE_NAME/PACKAGE_NAME.spec`
- **Type**: Git
- **Method**: make_srpm

### Automation Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. UPSTREAM RELEASE                                         │
└─────────────────────────────────────────────────────────────┘
   │
   ↓ New version released
   │
┌─────────────────────────────────────────────────────────────┐
│ 2. RENOVATE BOT                                             │
│    • Detects new version                                    │
│    • Creates PR with updated spec file                      │
└─────────────────────────────────────────────────────────────┘
   │
   ↓ You merge PR
   │
┌─────────────────────────────────────────────────────────────┐
│ 3. GITHUB ACTIONS (Lightweight)                             │
│    • Detects spec file change                               │
│    • Identifies package name                                │
│    • Runs: copr-cli build-package --name PKG PROJECT        │
│    • Job completes in ~10 seconds                           │
└─────────────────────────────────────────────────────────────┘
   │
   ↓ Rebuild command sent
   │
┌─────────────────────────────────────────────────────────────┐
│ 4. COPR SCM BUILD SYSTEM                                    │
│    • Receives rebuild trigger                               │
│    • Clones your Git repository                             │
│    • Reads spec file from packages/PKG/PKG.spec             │
│    • Downloads sources (spectool)                           │
│    • Builds SRPM                                            │
│    • Queues package builds for all chroots                  │
└─────────────────────────────────────────────────────────────┘
   │
   ↓ Builds complete
   │
┌─────────────────────────────────────────────────────────────┐
│ 5. PACKAGE AVAILABLE                                        │
│    Users can install with: dnf install PACKAGE              │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Setup Requirements

### One-Time Configuration

Before automation works, each package must be configured in Copr:

#### Easy Way: Use the Setup Script
```bash
./setup-copr-packages.sh username/projectname your-github-username
```

This automatically configures all packages in your `packages/` directory.

#### Manual Way: Configure Each Package
```bash
copr-cli edit-package-scm YOUR_PROJECT \
  --name PACKAGE_NAME \
  --clone-url https://github.com/USERNAME/copr \
  --spec packages/PACKAGE_NAME/PACKAGE_NAME.spec \
  --type git \
  --method make_srpm
```

### Ongoing Requirements

- ✅ GitHub secrets configured (COPR_CONFIG, COPR_PROJECT)
- ✅ Spec files in correct location: `packages/PKG/PKG.spec`
- ✅ Package name matches directory name

## 🔧 Commands

### Trigger Rebuild (Automatic via GitHub Actions)
```bash
# Happens automatically when you push changes to spec files
git add packages/matugen/matugen.spec
git commit -m "chore: bump matugen to 3.2.0"
git push origin main
```

### Trigger Rebuild (Manual via CLI)
```bash
# Rebuild specific package
copr-cli build-package --name matugen username/project

# Rebuild without waiting
copr-cli build-package --name matugen username/project --nowait
```

### Trigger Rebuild (Manual via GitHub Actions UI)
1. Go to Actions tab
2. Select "Trigger Copr Builds"
3. Click "Run workflow"
4. Enter package name (optional)
5. Click "Run workflow"

### Check Package Configuration
```bash
# List all configured packages
copr-cli list-packages username/project

# Get specific package details
copr-cli get-package username/project --name matugen
```

### Add New Package
```bash
# 1. Create spec file
mkdir -p packages/newpkg
cp .github/PACKAGE_TEMPLATE.spec packages/newpkg/newpkg.spec

# 2. Configure in Copr
copr-cli add-package-scm username/project \
  --name newpkg \
  --clone-url https://github.com/username/copr \
  --spec packages/newpkg/newpkg.spec \
  --type git \
  --method make_srpm

# 3. Commit and push
git add packages/newpkg/
git commit -m "feat: add newpkg"
git push origin main

# First build happens automatically!
```

## 🎯 Benefits of This Approach

### For You (Maintainer)
- ✅ Less code to maintain in GitHub Actions
- ✅ Faster workflow execution
- ✅ Easier to debug
- ✅ Better separation of concerns
- ✅ Native Copr integration

### For Users
- ✅ More reliable builds
- ✅ Consistent build environment
- ✅ Better build logs
- ✅ No difference in end result

### For the Project
- ✅ Industry standard approach (Copr SCM builds)
- ✅ Easier to understand
- ✅ Less infrastructure to manage
- ✅ More scalable

## 🔄 Migration Path

If you were using the old SRPM-based approach:

1. **Configure packages in Copr** (one-time):
   ```bash
   ./setup-copr-packages.sh username/project github-username
   ```

2. **Update workflow** (already done):
   - Old: Build SRPM → Upload
   - New: Trigger rebuild

3. **Test**:
   ```bash
   # Trigger test rebuild
   copr-cli build-package --name matugen username/project
   ```

4. **Done!** Future builds will use the new method automatically.

## 📊 Performance Comparison

| Metric | SRPM Upload Method | SCM Build Method |
|--------|-------------------|------------------|
| GitHub Actions time | 5-10 minutes | 10-30 seconds |
| Dependencies installed | 10+ packages | 1 package (copr-cli) |
| Lines of workflow code | ~100 lines | ~30 lines |
| Artifacts stored | Yes (SRPMs) | No |
| Debugging location | Actions + Copr | Copr only |
| Setup complexity | Low | Medium (initial config) |
| Ongoing maintenance | Low | Very low |

## ❓ FAQ

### Q: Do I need to rebuild everything?
**A:** No. Existing packages continue to work. Just configure them in Copr and they'll use the new method automatically.

### Q: What if a package isn't configured in Copr?
**A:** The GitHub Actions workflow will fail with "package not found". Just run the setup script or manually configure the package.

### Q: Can I still build SRPMs locally?
**A:** Yes! Local development is unchanged. See `COMMANDS.md` for details.

### Q: Do I lose any functionality?
**A:** No. You gain reliability and simplicity. The end result (built packages) is identical.

### Q: What about SRPM artifacts?
**A:** No longer needed. Copr builds the SRPM, and you can download it from Copr if needed.

### Q: How do I update package configuration?
**A:** Use `copr-cli edit-package-scm` or the Copr web UI to update settings.

### Q: Can I use both methods?
**A:** Not recommended. Choose SCM builds for consistency and simplicity.

## 🚀 Next Steps

1. **Read the Quick Start**: [QUICK_START.md](QUICK_START.md)
2. **Run the setup script**: `./setup-copr-packages.sh`
3. **Configure secrets**: Add COPR_CONFIG and COPR_PROJECT
4. **Test a build**: Use GitHub Actions or CLI
5. **Enjoy automated builds!** 🎉

## 📚 Related Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get started in 5 minutes
- **[COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md)** - Detailed setup guide
- **[COMMANDS.md](COMMANDS.md)** - Command reference
- **[INDEX.md](INDEX.md)** - Documentation hub

---

**Summary**: The workflow now uses Copr's native SCM build system, making it simpler, faster, and more reliable. Each package must be configured in Copr (one-time setup), after which GitHub Actions just triggers rebuilds with a simple command.

**Status**: ✅ Implementation complete and ready to use