# Copr Automation Commands Reference

Quick reference for common commands and operations.

## 🚀 GitHub Actions Commands

### Trigger Build Manually (via GitHub UI)
1. Go to **Actions** tab in GitHub
2. Select **Trigger Copr Builds** workflow
3. Click **Run workflow**
4. (Optional) Enter package name
5. Click **Run workflow** button

### Trigger Build Manually (via GitHub CLI)
```bash
# Install GitHub CLI if needed
# https://cli.github.com/

# Trigger build for all changed packages
gh workflow run "Trigger Copr Builds"

# Trigger build for specific package
gh workflow run "Trigger Copr Builds" -f package=matugen

# View workflow runs
gh run list --workflow="Trigger Copr Builds"

# Watch latest run
gh run watch

# View logs of latest run
gh run view --log
```

## 📦 Copr Package Management

### Configure Package in Copr
```bash
# Add/edit package in Copr to build from SCM
copr-cli edit-package-scm YOUR_PROJECT \
  --name matugen \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/matugen/matugen.spec \
  --type git \
  --method make_srpm

# Enable webhook rebuilds (optional)
copr-cli edit-package-scm YOUR_PROJECT \
  --name matugen \
  --webhook-rebuild on
```

### Trigger Package Rebuild
```bash
# Rebuild a specific package
copr-cli build-package --name matugen YOUR_PROJECT

# Rebuild without waiting for completion
copr-cli build-package --name matugen YOUR_PROJECT --nowait

# Rebuild for specific chroots
copr-cli build-package --name matugen YOUR_PROJECT \
  --chroot fedora-39-x86_64 \
  --chroot fedora-40-x86_64
```

### Test Build Locally (Optional)
```bash
# If you want to test spec file locally before pushing
sudo dnf install -y rpm-build rpmdevtools spectool

# Navigate to package directory
cd packages/matugen

# Download sources
spectool -g -R matugen.spec

# Build SRPM locally
rpmbuild -bs matugen.spec \
  --define "_sourcedir $(pwd)" \
  --define "_srcrpmdir $(pwd)"

# Install build dependencies
sudo dnf builddep matugen.spec

# Build binary RPM
rpmbuild -bb matugen.spec \
  --define "_sourcedir $(pwd)"
```

## 🔧 Copr CLI Commands

### Setup Copr CLI
```bash
# Install copr-cli
sudo dnf install -y copr-cli

# Configure (interactive)
copr-cli --config

# Or create config file manually at ~/.config/copr
cat > ~/.config/copr << 'EOF'
[copr-cli]
login = YOUR_LOGIN
username = YOUR_USERNAME
token = YOUR_TOKEN
copr_url = https://copr.fedorainfracloud.org
EOF

chmod 600 ~/.config/copr
```

### Build Commands
```bash
# Rebuild a configured package (recommended method)
copr-cli build-package --name PACKAGE_NAME YOUR_PROJECT

# Rebuild without waiting
copr-cli build-package --name PACKAGE_NAME YOUR_PROJECT --nowait

# Rebuild for specific chroots only
copr-cli build-package --name PACKAGE_NAME YOUR_PROJECT \
  --chroot fedora-39-x86_64 \
  --chroot fedora-40-x86_64

# One-time build from SCM (without package configuration)
copr-cli buildscm YOUR_PROJECT \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/PACKAGE_NAME/PACKAGE_NAME.spec \
  --type git \
  --method make_srpm

# Legacy: Build from pre-built SRPM (not used in our workflow)
copr-cli build YOUR_PROJECT path/to/package.src.rpm --nowait
```

### Project Management
```bash
# List your projects
copr-cli list

# Get project info
copr-cli get YOUR_PROJECT

# List builds
copr-cli list-builds YOUR_PROJECT

# Get build status
copr-cli status YOUR_PROJECT BUILD_ID

# Cancel build
copr-cli cancel YOUR_PROJECT BUILD_ID

# Delete build
copr-cli delete-build YOUR_PROJECT BUILD_ID
```

### Package Management
```bash
# List packages in project
copr-cli list-packages YOUR_PROJECT

# Add new package from SCM
copr-cli add-package-scm YOUR_PROJECT \
  --name packagename \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/packagename/packagename.spec \
  --type git \
  --method make_srpm

# Edit existing package configuration
copr-cli edit-package-scm YOUR_PROJECT \
  --name packagename \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/packagename/packagename.spec

# Get package details
copr-cli get-package YOUR_PROJECT --name packagename

# Delete package
copr-cli delete-package YOUR_PROJECT --name packagename

# Reset package (useful if builds are stuck)
copr-cli edit-package-scm YOUR_PROJECT \
  --name packagename \
  --webhook-rebuild off
```

## 🤖 Renovate Commands

### Test Renovate Configuration Locally
```bash
# Install Renovate CLI
npm install -g renovate

# Dry-run Renovate on your repo
renovate --platform=github \
  --token=YOUR_GITHUB_TOKEN \
  --dry-run=full \
  YOUR_USERNAME/copr

# Validate config only
renovate-config-validator
```

### Manual Renovate Trigger (GitHub)
```bash
# Trigger Renovate via GitHub API
curl -X POST \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/YOUR_USERNAME/copr/dispatches \
  -d '{"event_type":"renovate"}'
```

## 🔍 Debugging Commands

### Check Spec File Syntax
```bash
# Parse spec file for errors
rpmlint packages/matugen/matugen.spec

# Show parsed spec content
rpmspec -P packages/matugen/matugen.spec

# Query spec file info
rpmspec -q packages/matugen/matugen.spec

# Show build requires
rpmspec -q --buildrequires packages/matugen/matugen.spec

# Show requires
rpmspec -q --requires packages/matugen/matugen.spec
```

### Check Source URLs
```bash
# List sources in spec
spectool -l packages/matugen/matugen.spec

# Download all sources
spectool -g -R packages/matugen/matugen.spec

# Verify source checksums (if defined)
spectool -C packages/matugen/matugen.spec
```

### Inspect SRPM
```bash
# List contents of SRPM
rpm -qpl package.src.rpm

# Show info from SRPM
rpm -qpi package.src.rpm

# Extract SRPM contents
rpm2cpio package.src.rpm | cpio -idmv
```

## 📊 Monitoring Commands

### Monitor GitHub Actions
```bash
# List recent workflow runs
gh run list --limit 10

# Watch specific run
gh run watch RUN_ID

# View run details
gh run view RUN_ID

# Download artifacts
gh run download RUN_ID

# View job logs
gh run view RUN_ID --log --job JOB_ID
```

### Monitor Copr Builds
```bash
# List recent builds
copr-cli list-builds YOUR_PROJECT --limit 10

# Watch build status (poll every 30s)
watch -n 30 'copr-cli status YOUR_PROJECT BUILD_ID'

# Get build logs URL
copr-cli get-build YOUR_PROJECT BUILD_ID

# Download build logs (requires browser/curl)
curl -o build.log https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/build/BUILD_ID/logs/...
```

## 🔄 Git Commands for Package Updates

### Update Package Version Manually
```bash
# Edit spec file
vim packages/matugen/matugen.spec

# Update Version: line
# Update Release: to 1%{?dist} (reset release on version bump)

# Commit changes
git add packages/matugen/matugen.spec
git commit -m "chore: bump matugen to X.Y.Z"

# Push to trigger build
git push origin main
```

### Add New Package
```bash
# Create package directory
mkdir -p packages/newpackage

# Copy template or create spec
cp .github/PACKAGE_TEMPLATE.spec packages/newpackage/newpackage.spec

# Edit spec file
vim packages/newpackage/newpackage.spec

# Add Renovate comment for auto-updates
# renovate: datasource=github-releases depName=owner/repo
# Version:        1.0.0

# Configure package in Copr
copr-cli add-package-scm YOUR_PROJECT \
  --name newpackage \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/newpackage/newpackage.spec \
  --type git \
  --method make_srpm

# Commit and push
git add packages/newpackage/
git commit -m "feat: add newpackage"
git push origin main

# First build will trigger automatically or run manually:
copr-cli build-package --name newpackage YOUR_PROJECT
```

## 🔐 Security Commands

### Rotate Copr Token
```bash
# 1. Generate new token at https://copr.fedorainfracloud.org/api/
# 2. Update GitHub secret:
gh secret set COPR_CONFIG < new_copr_config.txt

# 3. Test with manual workflow run
gh workflow run "Trigger Copr Builds" -f package=matugen
```

### Verify Secrets
```bash
# List secrets (values not shown)
gh secret list

# Remove secret
gh secret remove SECRET_NAME

# Set secret from file
gh secret set COPR_CONFIG < ~/.config/copr

# Set secret from stdin
echo "username/project" | gh secret set COPR_PROJECT
```

## 🧹 Cleanup Commands

### Clean Local Build Artifacts
```bash
# Remove built RPMs (if building locally)
rm -rf ~/rpmbuild/RPMS/* ~/rpmbuild/SRPMS/*

# Clean downloaded sources
find packages -name "*.tar.gz" -delete
find packages -name "*.tar.xz" -delete
find packages -name "*.zip" -delete
find packages -name "*.src.rpm" -delete

# Clean temporary files
find packages -name "*.rpm" -type f -delete
```

### Clean Copr Builds
```bash
# Delete old builds (keep last 10)
for build in $(copr-cli list-builds YOUR_PROJECT --limit 100 | tail -n +11 | awk '{print $1}'); do
  copr-cli delete-build YOUR_PROJECT $build
done
```

## 📝 Useful One-Liners

### List all packages with versions
```bash
grep -r "^Version:" packages/*/*.spec | sed 's|packages/||; s|/.*:|\t|'
```

### Check which packages have Renovate enabled
```bash
grep -l "renovate:" packages/*/*.spec | sed 's|packages/||; s|/.*||'
```

### Find packages without Renovate
```bash
comm -23 \
  <(ls packages | sort) \
  <(grep -l "renovate:" packages/*/*.spec | sed 's|packages/||; s|/.*||' | sort)
```

### Get all GitHub source URLs
```bash
grep -h "^URL:" packages/*/*.spec | sort -u
```

### Check for outdated versions (requires GitHub CLI)
```bash
for spec in packages/*/*.spec; do
  pkg=$(basename $(dirname $spec))
  echo "Checking $pkg..."
  rpmspec -q --qf "%{VERSION}\n" $spec
done
```

## 🆘 Emergency Commands

### Stop All Running Builds
```bash
# List running builds
copr-cli list-builds YOUR_PROJECT | grep "running"

# Cancel each running build
for build_id in $(copr-cli list-builds YOUR_PROJECT | grep "running" | awk '{print $1}'); do
  copr-cli cancel YOUR_PROJECT $build_id
done

# Or manually cancel a specific build
copr-cli cancel YOUR_PROJECT BUILD_ID
```

### Rollback Package Version
```bash
# Revert spec file
git checkout HEAD~1 packages/matugen/matugen.spec

# Commit
git commit -am "revert: rollback matugen to previous version"

# Push to rebuild
git push origin main
```

### Disable Automation Temporarily
```bash
# Disable GitHub Actions workflow
gh workflow disable "Trigger Copr Builds"

# Re-enable later
gh workflow enable "Trigger Copr Builds"

# Or disable package rebuilds in Copr
copr-cli edit-package-scm YOUR_PROJECT \
  --name PACKAGE_NAME \
  --webhook-rebuild off

# Re-enable
copr-cli edit-package-scm YOUR_PROJECT \
  --name PACKAGE_NAME \
  --webhook-rebuild on
```

## 📚 Documentation Commands

### Generate Package List
```bash
# Create markdown table of packages
echo "| Package | Version | URL |"
echo "|---------|---------|-----|"
for spec in packages/*/*.spec; do
  name=$(rpmspec -q --qf "%{NAME}\n" $spec | head -1)
  version=$(rpmspec -q --qf "%{VERSION}\n" $spec | head -1)
  url=$(rpmspec -q --qf "%{URL}\n" $spec | head -1)
  echo "| $name | $version | $url |"
done
```

### Check Repository Statistics
```bash
# Count packages
echo "Total packages: $(ls packages | wc -l)"

# Count with Renovate
echo "With Renovate: $(grep -l 'renovate:' packages/*/*.spec | wc -l)"

# Show package types
echo "Package types:"
grep -h "BuildRequires:" packages/*/*.spec | sort | uniq -c | sort -rn | head -10
```

## 🔗 Useful URLs

- **GitHub Actions**: https://github.com/YOUR_USERNAME/copr/actions
- **Copr Project**: https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/
- **Copr Packages**: https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/packages/
- **Copr Builds**: https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/builds/
- **Copr API**: https://copr.fedorainfracloud.org/api/
- **Copr API Tokens**: https://copr.fedorainfracloud.org/api/
- **Renovate Dashboard**: https://app.renovatebot.com/dashboard

## 🎯 Quick Package Setup

Complete command sequence for adding a new package:

```bash
# 1. Create package files
mkdir -p packages/mypackage
cp .github/PACKAGE_TEMPLATE.spec packages/mypackage/mypackage.spec
vim packages/mypackage/mypackage.spec

# 2. Configure in Copr
copr-cli add-package-scm username/project \
  --name mypackage \
  --clone-url https://github.com/username/copr \
  --spec packages/mypackage/mypackage.spec \
  --type git \
  --method make_srpm

# 3. Commit and push
git add packages/mypackage/
git commit -m "feat: add mypackage"
git push origin main

# 4. First build (automatic or manual)
copr-cli build-package --name mypackage username/project
```

---

**Tip**: Bookmark this file and use `grep` to quickly find commands!

Example: `grep -A 3 "Build SRPM" COMMANDS.md`
