# Security Best Practices

This document explains the security measures implemented in the Copr automation workflow and best practices for maintaining secure operations.

## 🔐 Overview

The automation workflow handles sensitive credentials (Copr API tokens) that must be protected from exposure. This document outlines how secrets are protected and what you should know.

## Security Features

### 1. Encrypted GitHub Secrets

**What:** GitHub encrypts secrets at rest and in transit.

**How it works:**
- Secrets are stored encrypted in GitHub's database
- Only decrypted at runtime in the workflow
- Never visible in logs or UI
- Cannot be retrieved after being set

**Your action:**
- Store `COPR_CONFIG` and `COPR_PROJECT` as GitHub secrets
- Never commit these values to the repository
- Rotate tokens periodically

### 2. Secure Secret Writing (Heredoc)

**What:** The workflow uses heredoc syntax to write secrets to files without exposing them.

**Why it matters:**
```yaml
# ❌ INSECURE - secret appears in process listings and logs
echo "${{ secrets.COPR_CONFIG }}" > ~/.config/copr

# ✅ SECURE - heredoc prevents exposure
cat > ~/.config/copr << 'EOF'
${{ secrets.COPR_CONFIG }}
EOF
```

**How it protects you:**
- Secret doesn't appear in command-line arguments
- Not visible in process listings (`ps aux`)
- Not logged by shell history
- Not captured in debug logs

### 3. Fedora Container Environment

**What:** Workflow runs in a Fedora container, not Ubuntu host.

**Why:**
```yaml
runs-on: ubuntu-latest        # Host OS
container:
  image: fedora:latest        # Container with DNF
```

**Benefits:**
- Proper environment for `copr-cli` (requires DNF)
- Isolated from host system
- Consistent build environment
- Proper package dependencies

### 4. File Permissions

**What:** Config files are set to restrictive permissions.

**Implementation:**
```bash
chmod 600 ~/.config/copr
# Owner: read + write
# Group: no access
# Others: no access
```

**Protection:**
- Only the workflow user can read the config
- Prevents other processes from accessing credentials
- Standard Unix security practice

### 5. Branch Protection

**What:** Workflow only runs on `main` branch for push events.

**Configuration:**
```yaml
on:
  push:
    branches:
      - main
```

**Why it matters:**
- External PRs cannot trigger builds with your secrets
- Forks cannot access your secrets
- Manual review required before merge
- Prevents secret exfiltration attacks

## Security Checklist

### Setup Phase

- [ ] Generate unique Copr API token
- [ ] Store token as GitHub secret (never commit)
- [ ] Verify secrets are not in git history
- [ ] Set restrictive branch protection rules
- [ ] Enable 2FA on GitHub account
- [ ] Enable 2FA on Copr account

### Operational Phase

- [ ] Monitor GitHub Actions logs for suspicious activity
- [ ] Review Renovate PRs before merging
- [ ] Rotate Copr API token periodically (every 90 days)
- [ ] Audit who has repository access
- [ ] Review workflow runs regularly
- [ ] Keep workflow dependencies updated

### If Compromised

- [ ] Immediately regenerate Copr API token
- [ ] Update GitHub secret with new token
- [ ] Review recent builds in Copr
- [ ] Check GitHub Actions logs for unauthorized runs
- [ ] Audit repository access logs
- [ ] Consider rotating all credentials

## Best Practices

### DO ✅

1. **Use GitHub Secrets** for all sensitive data
   ```yaml
   ${{ secrets.COPR_CONFIG }}
   ```

2. **Limit repository access** to trusted collaborators only

3. **Review PRs carefully** before merging, especially from Renovate

4. **Monitor build logs** for unexpected behavior

5. **Use branch protection** rules to prevent direct pushes

6. **Rotate credentials** regularly (every 90 days)

7. **Keep workflow minimal** - less code = less attack surface

8. **Use official actions** from trusted sources:
   ```yaml
   - uses: actions/checkout@v4  # Official GitHub action
   ```

### DON'T ❌

1. **Never commit secrets** to the repository
   ```bash
   # ❌ BAD - secret in file
   cat > ~/.config/copr << EOF
   login = mylogin
   token = abc123...
   EOF
   
   # ✅ GOOD - secret from GitHub
   cat > ~/.config/copr << 'EOF'
   ${{ secrets.COPR_CONFIG }}
   EOF
   ```

2. **Never echo secrets** to output
   ```yaml
   # ❌ BAD
   - run: echo "Token: ${{ secrets.COPR_CONFIG }}"
   
   # ✅ GOOD
   - run: echo "Config written successfully"
   ```

3. **Never use secrets in PR workflows** unless absolutely necessary

4. **Never expose secrets in filenames** or paths

5. **Never share secrets** via insecure channels (email, chat, etc.)

6. **Never reuse tokens** across multiple projects

7. **Never run untrusted code** in workflows with access to secrets

## Secret Rotation

### When to Rotate

- **Regularly:** Every 90 days
- **After compromise:** Immediately
- **After team member leaves:** Within 24 hours
- **After suspicious activity:** Immediately
- **After workflow modifications:** Consider rotating

### How to Rotate

1. **Generate new Copr API token:**
   - Go to https://copr.fedorainfracloud.org/api/
   - Click "Regenerate" or create new token
   - Copy the new configuration

2. **Update GitHub secret:**
   ```bash
   # Using GitHub CLI
   cat new-copr-config.txt | gh secret set COPR_CONFIG
   
   # Or via GitHub UI:
   # Settings → Secrets → Actions → COPR_CONFIG → Update
   ```

3. **Verify new token works:**
   - Trigger a test build via GitHub Actions
   - Check that build succeeds
   - Review logs for authentication errors

4. **Revoke old token** (if possible in Copr)

## Audit Trail

### What to Monitor

1. **GitHub Actions runs:**
   - Go to Actions tab
   - Review run history
   - Check for unexpected runs
   - Verify expected users triggered runs

2. **Copr build history:**
   - Review builds at https://copr.fedorainfracloud.org/
   - Check for unexpected packages
   - Verify build sources match your repository

3. **Repository access:**
   - Settings → Manage access
   - Review who has write access
   - Remove users who no longer need access

### Logging

GitHub Actions provides audit logs for:
- Secret access (when secrets are read)
- Workflow runs (who triggered, when, what changed)
- Repository access (who has access, when granted)

**Access audit logs:**
- Organization: Settings → Audit log
- Repository: Settings → Security → Audit log

## Threat Model

### Threats Protected Against

✅ **Secret exposure in logs** - Heredoc prevents logging
✅ **Unauthorized builds** - Branch protection + PR reviews
✅ **Token theft from process list** - Heredoc prevents exposure
✅ **External PR attacks** - Workflows don't run with secrets on PRs
✅ **Compromised dependencies** - Minimal dependencies, official actions
✅ **File permission exploits** - Restrictive permissions (600)

### Threats NOT Protected Against

⚠️ **Compromised GitHub account** - Use 2FA to mitigate
⚠️ **Malicious collaborator** - Careful access control required
⚠️ **Supply chain attacks** - Keep dependencies minimal and updated
⚠️ **GitHub Actions platform compromise** - Trust GitHub's security
⚠️ **Copr platform compromise** - Trust Copr's security

## Incident Response

### If Secrets Are Exposed

1. **Immediately rotate** Copr API token
2. **Update GitHub secret** with new token
3. **Review** all recent builds for unauthorized activity
4. **Audit** repository access logs
5. **Document** what happened and how to prevent recurrence
6. **Notify** team members if applicable

### If Unauthorized Build Detected

1. **Cancel** the build immediately in Copr
2. **Investigate** who triggered it and why
3. **Review** git history for malicious commits
4. **Check** GitHub Actions logs for trigger source
5. **Rotate** credentials if compromise suspected
6. **Strengthen** access controls and branch protection

## Compliance

### Data Handled

- **Copr API credentials** (login, username, token)
- **Repository access tokens** (GitHub Actions)
- **Package source code** (publicly visible in Copr)
- **Build logs** (publicly visible in Copr)

### Data Protection

- All sensitive data stored as GitHub encrypted secrets
- No credentials stored in repository
- No sensitive data in logs or outputs
- Copr builds are publicly accessible (open source)

## References

- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Copr API Documentation](https://docs.pagure.org/copr.copr/user_documentation.html#api)
- [Best Practices for Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets#best-practices)

## Questions?

If you have security concerns or questions:

1. Review this document thoroughly
2. Check GitHub Actions security guides (link above)
3. Audit your workflow configuration
4. Test in a separate test project first
5. Rotate credentials if unsure about security

---

**Remember:** Security is an ongoing process, not a one-time setup. Regular audits and updates are essential.

**Last Updated:** 2024-01-06
**Security Level:** ✅ Production-ready with proper secret handling