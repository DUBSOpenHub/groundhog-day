# Security Policy 🔒

## Supported Versions

| Version | Supported |
| ------- | --------- |
| v1.x    | ✅ |
| < v1.0  | ❌ |

## Reporting a Vulnerability

**Do not open a GitHub issue for security vulnerabilities.**

If you discover a security vulnerability in Groundhog Day (for example: shell injection, unauthorized file access, or credential exposure via sync), please report it privately.

### Preferred channel

- **GitHub Security Advisories** (if enabled on the repository)

### What to include

- A clear description of the issue
- Steps to reproduce
- Potential impact (what could be exposed or compromised)
- Any proof-of-concept artifacts (safe to share)

## Response Timeline

- **Acknowledgment:** within 24 hours
- **Assessment:** within 72 hours
- **Resolution:** depends on severity; critical issues are prioritized for the next release

## Scope

**In scope:**

- Shell injection in skill file names or content
- rsync `--delete` data loss scenarios
- Git credential or token exposure
- Lock file race conditions
- Log file information leakage

**Out of scope:**

- Vulnerabilities in `fswatch`, `rsync`, or `git` themselves
- Vulnerabilities in GitHub CLI (`gh`)
- User-created skills that contain sensitive content (users must review what they commit)
