# MangosteenOS COPR

Custom Copr repository for MangosteenOS packages.

Primary reason for these packages is that DMS requires Matugen version greater than 3.0 to generate colorschemes from wallpaper. Also currently pulling in MangoWC from terra repository and would like to pull it from my repo.

## 🚀 Automated Builds

This repository uses automated builds powered by:
- **Renovate Bot** - Automatically detects new upstream releases
- **GitHub Actions** - Triggers Copr package rebuilds
- **Copr SCM Builds** - Copr pulls from Git and builds packages

### Quick Setup

1. **Configure packages in Copr** (one-time setup):
   ```bash
   ./setup-copr-packages.sh username/projectname your-github-username
   ```

2. **Add GitHub secrets** (see [QUICK_START.md](QUICK_START.md)):
   - `COPR_CONFIG` - Your Copr API configuration
   - `COPR_PROJECT` - Your Copr project identifier

3. **Test it** - Trigger a manual build from GitHub Actions

### Full Documentation
- **[QUICK_START.md](QUICK_START.md)** - 5-minute setup guide
- **[COPR_AUTOMATION_SETUP.md](COPR_AUTOMATION_SETUP.md)** - Detailed instructions
- **[INDEX.md](INDEX.md)** - Complete documentation index

## 📦 Packages

- **matugen** - Material you color generation tool (v3.0+)
- **mangowc** - Wayland compositor component
- **cliphist** - Clipboard history manager for Wayland
- **scenefx** - Eye-candy effects for wlroots compositors
- **valent-git** - Device sync and control
- **zed** - High-performance code editor

### Package Dependencies

- **scenefx** → **mangowc** (mangowc depends on scenefx)
- The workflow automatically builds scenefx before mangowc when both change
- See [PACKAGE_DEPENDENCIES.md](PACKAGE_DEPENDENCIES.md) for details

## 🔄 How It Works

1. **Renovate** detects new releases and updates spec files
2. **You** review and merge the PR
3. **GitHub Actions** detects changes and triggers Copr rebuilds
4. **Copr** pulls from Git, builds packages, and publishes them

**Note:** For packages with dependencies (like mangowc → scenefx), the workflow ensures dependencies build first.

## 🛠️ Adding a New Package

1. Create `packages/newpackage/newpackage.spec` using the template:
   ```bash
   cp .github/PACKAGE_TEMPLATE.spec packages/newpackage/newpackage.spec
   ```

2. Configure the package in Copr:
   ```bash
   copr-cli add-package-scm username/project \
     --name newpackage \
     --clone-url https://github.com/username/copr \
     --spec packages/newpackage/newpackage.spec \
     --type git --method make_srpm
   ```

3. Add Renovate comment for auto-updates:
   ```spec
   # renovate: datasource=github-releases depName=owner/repo
   Version:        1.0.0
   ```

4. Commit and push - automated builds will handle the rest!

**Note:** If your package depends on other packages, add `BuildRequires` to the spec file and ensure dependencies are built first.

See **[COMMANDS.md](COMMANDS.md)** for more details and **[PACKAGE_DEPENDENCIES.md](PACKAGE_DEPENDENCIES.md)** for dependency handling.
