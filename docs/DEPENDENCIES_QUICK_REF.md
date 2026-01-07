# Package Dependencies Quick Reference

## Current Dependency Chain

```
scenefx (base library)
    ↓
mangowc (depends on scenefx via BuildRequires)
```

## How the Workflow Handles It

### Automatic Dependency Resolution

The GitHub Actions workflow automatically handles the dependency order:

1. **When both scenefx and mangowc change:**
   - `build-dependencies` job runs first
   - Builds `scenefx` first
   - Waits 60 seconds for processing
   - Then `build` job triggers `mangowc`

2. **When only scenefx changes:**
   - `scenefx` is built normally
   - `mangowc` is NOT rebuilt (uses existing version)

3. **When only mangowc changes:**
   - `mangowc` is built normally
   - Uses already-built `scenefx` from Copr repo

## Manual Build Commands

### Build Both Packages

```bash
# Option 1: Sequential (safe)
copr-cli build-package --name scenefx username/project
# Wait for completion...
copr-cli build-package --name mangowc username/project

# Option 2: Let Copr handle it
copr-cli build-package --name scenefx username/project --nowait
sleep 60
copr-cli build-package --name mangowc username/project
```

### Build Only mangowc

```bash
# scenefx must already be built in Copr
copr-cli build-package --name mangowc username/project
```

### Verify Dependency

```bash
# Check what mangowc requires
rpmspec -q --buildrequires packages/mangowc/mangowc.spec | grep scenefx
# Output: pkgconfig(scenefx-0.4)

# Check if scenefx is available in Copr
copr-cli list-builds username/project | grep scenefx
```

## Best Practices

✅ **DO:**
- Commit scenefx changes separately when possible
- Wait for scenefx build to complete before rebuilding mangowc
- Let the workflow handle dependencies automatically

❌ **DON'T:**
- Try to build mangowc without scenefx in the repo
- Manually trigger both builds simultaneously
- Skip scenefx when updating both packages

## Troubleshooting

### mangowc build fails: "nothing provides scenefx"

**Solution:**
```bash
# Build scenefx first
copr-cli build-package --name scenefx username/project

# Wait for completion (check Copr UI)

# Then rebuild mangowc
copr-cli build-package --name mangowc username/project
```

### Both packages updated but build fails

**Cause:** Race condition - mangowc started before scenefx finished

**Solution:** The workflow now prevents this automatically. If it still happens, rebuild manually:
```bash
copr-cli build-package --name mangowc username/project
```

## Workflow Behavior Summary

| Scenario | What Happens |
|----------|--------------|
| Update only `scenefx.spec` | ✅ scenefx builds automatically |
| Update only `mangowc.spec` | ✅ mangowc builds automatically (uses existing scenefx) |
| Update both spec files | ✅ scenefx builds first, then mangowc |
| Manual trigger for mangowc | ✅ Works if scenefx exists in repo |

## Adding New Dependencies

If you add another package that depends on scenefx or mangowc:

1. Add `BuildRequires` to the spec file:
   ```spec
   BuildRequires:  pkgconfig(scenefx-0.4)
   ```

2. Update the workflow to include it in dependency checking:
   ```yaml
   if: contains(needs.detect-changes.outputs.packages, 'newpkg') || 
       contains(needs.detect-changes.outputs.packages, 'scenefx')
   ```

3. Build dependencies first, then the new package

## Quick Commands

```bash
# Check build order needed
grep -r "BuildRequires.*scenefx" packages/*/

# Build everything in order
for pkg in scenefx mangowc; do
  copr-cli build-package --name $pkg username/project
  echo "Waiting for $pkg..."
  sleep 180
done

# Force rebuild mangowc with latest scenefx
copr-cli build-package --name mangowc username/project
```

---

**Summary:** The workflow automatically builds scenefx before mangowc when both change. For manual builds, always build scenefx first!