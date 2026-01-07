# Package Dependencies in Copr

This guide explains how to handle package dependencies in your Copr automation setup, specifically for packages like `mangowc` that depend on `scenefx`.

## Overview

When one package depends on another (e.g., `mangowc` depends on `scenefx`), you need to ensure:
1. The dependency package is built first
2. The dependency package is available in the build environment
3. The dependent package can find the dependency during build

## Current Dependencies

```
scenefx (base library)
    ↓
mangowc (depends on scenefx)
```

## How It Works

### 1. Spec File Declaration

The dependency is already declared in `packages/mangowc/mangowc.spec`:

```spec
BuildRequires:  pkgconfig(scenefx-0.4)
```

This tells RPM that `mangowc` needs `scenefx` version 0.4 to build.

### 2. Copr Build Environment

When Copr builds `mangowc`, it will:
1. Check BuildRequires
2. Look for `scenefx` in your Copr repository
3. Install it before building `mangowc`
4. If `scenefx` is not available, the build will fail

### 3. Build Order

**Important:** You must build `scenefx` before `mangowc` if both are new or updated together.

## Setup Instructions

### Step 1: Configure Packages in Copr (Correct Order)

Configure packages in dependency order:

```bash
# 1. Configure scenefx first (the dependency)
copr-cli edit-package-scm YOUR_PROJECT \
  --name scenefx \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/scenefx/scenefx.spec \
  --type git \
  --method make_srpm

# 2. Configure mangowc second (depends on scenefx)
copr-cli edit-package-scm YOUR_PROJECT \
  --name mangowc \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/mangowc/mangowc.spec \
  --type git \
  --method make_srpm
```

### Step 2: Initial Builds

Build in dependency order:

```bash
# 1. Build scenefx first
copr-cli build-package --name scenefx YOUR_PROJECT

# Wait for build to complete (check status)
copr-cli list-builds YOUR_PROJECT --limit 1

# 2. Once scenefx is built, build mangowc
copr-cli build-package --name mangowc YOUR_PROJECT
```

### Step 3: Verify Dependencies

Check that mangowc can find scenefx:

```bash
# View mangowc build logs
# Look for lines like:
# "Installing: scenefx-devel-0.4.x..."
```

## Automation Behavior

### When Only mangowc Changes

If you update only `mangowc.spec` and push:
1. GitHub Actions triggers `mangowc` rebuild
2. Copr pulls your repo
3. Copr installs `scenefx` from your repository (already built)
4. Copr builds `mangowc` successfully ✅

### When Only scenefx Changes

If you update only `scenefx.spec` and push:
1. GitHub Actions triggers `scenefx` rebuild
2. Copr builds new `scenefx` version
3. `mangowc` is **not** automatically rebuilt
4. You may need to manually rebuild `mangowc` to use new `scenefx`

### When Both Change Together

If both spec files are updated in the same commit:
1. GitHub Actions detects both packages
2. **Builds happen in parallel** (potential issue!)
3. `mangowc` may fail if `scenefx` isn't ready yet

**Solution:** Build dependencies first (see solutions below).

## Solutions for Handling Build Order

### Solution 1: Manual Ordering (Simple)

When both packages change, trigger builds manually in order:

```bash
# 1. Build dependency first
copr-cli build-package --name scenefx YOUR_PROJECT

# 2. Wait for completion (monitor in Copr UI)

# 3. Build dependent package
copr-cli build-package --name mangowc YOUR_PROJECT
```

### Solution 2: Sequential Workflow (Automated)

Modify `.github/workflows/copr-build.yml` to build dependencies first:

```yaml
jobs:
  detect-changes:
    # ... existing code ...

  build:
    needs: detect-changes
    if: needs.detect-changes.outputs.packages != '[]'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install copr-cli
        run: sudo dnf install -y copr-cli

      - name: Configure copr-cli
        run: |
          mkdir -p ~/.config
          echo "${{ secrets.COPR_CONFIG }}" > ~/.config/copr
          chmod 600 ~/.config/copr

      - name: Build dependencies first
        run: |
          PACKAGES='${{ needs.detect-changes.outputs.packages }}'
          
          # If mangowc is in the list, ensure scenefx is built first
          if echo "$PACKAGES" | grep -q "mangowc"; then
            if echo "$PACKAGES" | grep -q "scenefx"; then
              echo "Building scenefx first (dependency of mangowc)..."
              copr-cli build-package --name scenefx ${{ secrets.COPR_PROJECT }}
              sleep 180  # Wait for build to start processing
            fi
          fi

      - name: Build all packages
        run: |
          PACKAGES='${{ needs.detect-changes.outputs.packages }}'
          
          for pkg in $(echo "$PACKAGES" | jq -r '.[]'); do
            # Skip scenefx if already built
            if [ "$pkg" = "scenefx" ] && echo "$PACKAGES" | grep -q "mangowc"; then
              echo "scenefx already triggered, skipping"
              continue
            fi
            
            echo "Triggering rebuild for: $pkg"
            copr-cli build-package --name $pkg ${{ secrets.COPR_PROJECT }} --nowait
          done
```

### Solution 3: Separate Commits (Recommended)

Best practice for maintaining dependency order:

```bash
# Commit 1: Update scenefx
git add packages/scenefx/scenefx.spec
git commit -m "chore: update scenefx to X.Y.Z"
git push origin main
# Wait for build to complete

# Commit 2: Update mangowc (if needed)
git add packages/mangowc/mangowc.spec
git commit -m "chore: rebuild mangowc with new scenefx"
git push origin main
```

### Solution 4: Copr Build Batches

Copr can handle dependencies if they're in the same build batch:

```bash
# Build both together (Copr resolves dependencies)
copr-cli build-package --name scenefx YOUR_PROJECT --nowait
copr-cli build-package --name mangowc YOUR_PROJECT
# Copr will wait for scenefx before building mangowc
```

## Troubleshooting

### Issue: mangowc build fails with "nothing provides scenefx"

**Cause:** scenefx is not built yet or not available in the buildroot

**Solution:**
1. Check if scenefx is built: `copr-cli list-builds YOUR_PROJECT | grep scenefx`
2. If not built, build it first: `copr-cli build-package --name scenefx YOUR_PROJECT`
3. Wait for completion, then rebuild mangowc

### Issue: Both packages change but build fails

**Cause:** Parallel builds - mangowc tries to build before scenefx is ready

**Solution:**
- Use Solution 3 (separate commits)
- Or manually trigger builds in order
- Or implement Solution 2 (sequential workflow)

### Issue: Old scenefx version used in mangowc build

**Cause:** Copr caches packages, new scenefx not yet available

**Solution:**
1. Wait a few minutes for repository metadata to update
2. Rebuild mangowc: `copr-cli build-package --name mangowc YOUR_PROJECT`

## Best Practices

1. **Always build dependencies first** when both packages change
2. **Use separate commits** for dependency updates when possible
3. **Monitor build logs** to verify correct versions are being used
4. **Document dependencies** in your README
5. **Test locally** before pushing changes to both packages

## Adding New Dependencies

If you add a new package that depends on existing packages:

1. **Add BuildRequires** to spec file:
   ```spec
   BuildRequires:  pkgconfig(dependency-name)
   ```

2. **Configure in Copr** after dependencies exist:
   ```bash
   copr-cli add-package-scm YOUR_PROJECT \
     --name newpackage \
     --clone-url https://github.com/YOUR_USERNAME/copr \
     --spec packages/newpackage/newpackage.spec \
     --type git \
     --method make_srpm
   ```

3. **Build dependencies first**, then build the new package

## Dependency Graph

Current package dependencies in this repository:

```
Independent packages:
├── cliphist
├── matugen
├── valent-git
└── zed

Dependency chain:
└── scenefx (library)
    └── mangowc (depends on scenefx)
```

## Commands Reference

```bash
# Check what a package depends on
rpmspec -q --buildrequires packages/mangowc/mangowc.spec

# Build dependency chain manually
copr-cli build-package --name scenefx YOUR_PROJECT
# Wait...
copr-cli build-package --name mangowc YOUR_PROJECT

# Check if scenefx is available in repo
dnf repoquery --repofrompath=copr,https://download.copr.fedorainfracloud.org/results/YOUR_PROJECT/fedora-39-x86_64/ \
  --repo=copr scenefx

# Rebuild all packages in dependency order
for pkg in scenefx mangowc; do
  copr-cli build-package --name $pkg YOUR_PROJECT
  sleep 300  # Wait between builds
done
```

## Summary

✅ **mangowc already declares its dependency on scenefx** in the spec file  
✅ **Copr will automatically install scenefx** when building mangowc  
⚠️ **You must build scenefx first** if both packages are new or updated together  
💡 **Recommended:** Use separate commits or manual build ordering for safety  

The dependency relationship is properly configured in the spec files. Just ensure you build `scenefx` before `mangowc` when both change!