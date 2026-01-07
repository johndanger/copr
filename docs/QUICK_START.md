# Copr Automation Quick Start

## 🚀 Quick Setup (5 minutes)

### 1. Get Your Copr API Token
1. Go to https://copr.fedorainfracloud.org/api/
2. Click "Show" and copy the entire config block

### 2. Add GitHub Secrets
Go to: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these two secrets:

| Secret Name | Value |
|------------|-------|
| `COPR_CONFIG` | Your full Copr API config (the [copr-cli] block) |
| `COPR_PROJECT` | Your project name (e.g., `username/projectname`) |

### 3. Configure Packages in Copr

**Important:** Each package must be configured in Copr to build from SCM (your Git repository).

For each package, run:
```bash
copr-cli edit-package-scm YOUR_PROJECT \
  --name PACKAGE_NAME \
  --clone-url https://github.com/YOUR_USERNAME/copr \
  --spec packages/PACKAGE_NAME/PACKAGE_NAME.spec \
  --type git \
  --method make_srpm
```

Or configure via Copr Web UI:
1. Go to your Copr project → Packages
2. Click "New Package" → "SCM"
3. Fill in:
   - **Package name**: (e.g., `matugen`)
   - **Clone URL**: Your GitHub repo URL
   - **Spec file**: `packages/matugen/matugen.spec`
   - **Type**: Git
   - **Method**: make_srpm

### 4. Test It
Go to **Actions** → **Trigger Copr Builds** → **Run workflow**

That's it! 🎉

---

## 📖 How It Works

```
New Release → Renovate Updates Spec → You Merge PR → GitHub Actions → Copr Rebuilds Package
```

1. **Renovate Bot** watches upstream repos and creates PRs when new versions are released
2. **You review and merge** the PR
3. **GitHub Actions** automatically detects the change and triggers a Copr rebuild
4. **Copr** pulls from your Git repo, builds the package, and publishes it

---

## 🔄 Common Operations

### Manually Trigger a Build
1. Go to **Actions** tab
2. Select **Trigger Copr Builds**
3. Click **Run workflow**
4. (Optional) Enter a package name like `matugen`
5. Click **Run workflow**

### Check Build Status
- **GitHub Actions**: https://github.com/YOUR_USERNAME/copr/actions
- **Copr Project**: https://copr.fedorainfracloud.org/coprs/YOUR_PROJECT/builds/

### Add a New Package
1. Create directory: `packages/newpackage/`
2. Add spec file: `packages/newpackage/newpackage.spec`
3. Add Renovate comment in spec:
   ```spec
   # renovate: datasource=github-releases depName=owner/repo
   Version:        1.0.0
   ```
4. Configure the package in Copr (see Step 3 above)
5. Commit and push - builds automatically!

---

## 🏷️ Renovate Comment Examples

### For GitHub Releases
```spec
# renovate: datasource=github-releases depName=InioX/matugen
Version:        3.1.0
```

### For Git Commits
```spec
# renovate: datasource=git-refs depName=https://github.com/owner/repo versioning=loose currentValue=main
%global commit abcdef1234567890
```

### For GitLab Releases
```spec
# renovate: datasource=gitlab-releases depName=owner/repo
Version:        2.5.0
```

---

## 🛠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| ❌ Authentication failed | Regenerate Copr token and update `COPR_CONFIG` secret |
| ❌ Package not found | Configure package in Copr (Step 3 above) |
| ❌ Build not triggered | Check if spec file changed in the commit |
| ❌ Copr build failed | Check Copr build logs for details |

---

## 📦 Package Structure

Your repo should look like this:

```
copr/
├── packages/
│   ├── matugen/
│   │   └── matugen.spec
│   ├── cliphist/
│   │   └── cliphist.spec
│   └── newpackage/
│       └── newpackage.spec
├── .github/
│   └── workflows/
│       └── copr-build.yml
└── README.md
```

**Important**: Package directory name MUST match:
- The spec filename
- The package name configured in Copr

---

## 🎯 What Triggers a Build?

✅ Push to `main` branch that changes a `.spec` file  
✅ Manual workflow dispatch  
❌ Pull requests (detection only, no build)  
❌ Changes to non-spec files  

---

## 🔐 Security

- API tokens are encrypted GitHub secrets
- Never committed to the repository
- Only accessible during workflow execution
- Not visible in logs

---

## 📚 More Help

- **Full Setup Guide**: See `COPR_AUTOMATION_SETUP.md`
- **Command Reference**: See `COMMANDS.md`
- **Copr Docs**: https://docs.pagure.org/copr.copr/
- **Renovate Docs**: https://docs.renovatebot.com/

---

## ✅ Checklist

Before your first build:

- [ ] Copr account created
- [ ] Copr project created
- [ ] Each package configured in Copr as SCM build
- [ ] `COPR_CONFIG` secret added
- [ ] `COPR_PROJECT` secret added
- [ ] Test workflow run successful

Happy building! 🚀