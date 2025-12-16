# AxonDB Search Release Process

This document describes how to create and publish AxonDB Search container releases for both development and production.

**Important:** All images are cryptographically signed with Sigstore Cosign using keyless signing (OIDC). Use the `-signed` workflows for all releases.

## Table of Contents

- [Overview](#overview)
- [Development Release Workflow](#development-release-workflow)
  - [1. Development and Testing](#1-development-and-testing)
  - [2. Publish Development Images (Optional)](#2-publish-development-images-optional)
  - [3. Promote to Production](#3-promote-to-production)
- [Production Release Workflow](#production-release-workflow)
  - [4. Create Git Tag on Main Branch](#4-create-git-tag-on-main-branch)
  - [5. Trigger Production Publish Workflow](#5-trigger-production-publish-workflow)
  - [6. Workflow Execution](#6-workflow-execution)
  - [7. Verify Release](#7-verify-release)
- [Inputs Reference](#inputs-reference)
  - [main_git_tag](#main_git_tag)
  - [container_version](#container_version)
- [Published Artifacts](#published-artifacts)
  - [Container Images (GHCR)](#container-images-ghcr)
  - [GitHub Release](#github-release)
  - [Cosign Signatures](#cosign-signatures)
- [Troubleshooting](#troubleshooting)
  - [Version Already Exists](#version-already-exists)
  - [Tests Fail During Publish](#tests-fail-during-publish)
  - [Workflow Cannot Find Tag](#workflow-cannot-find-tag)
  - [Tag Not on Main Branch](#tag-not-on-main-branch)
  - [Image Push Fails](#image-push-fails)
  - [Signature Verification Fails](#signature-verification-fails)
- [Re-releasing](#re-releasing)
- [Versioning Strategy](#versioning-strategy)
  - [2D Versioning](#2d-versioning)
  - [Semantic Versioning](#semantic-versioning)
  - [Examples](#examples)
  - [When to Increment](#when-to-increment)
  - [Pre-release Versions](#pre-release-versions)
- [Checklist](#checklist)
- [Release Cadence](#release-cadence)

## Overview

The release process uses separate workflows for development and production:

**Development Workflow:**
1. **axondb-search-build-and-test.yml** - Automatic testing on pushes/PRs to `development`
2. **axondb-search-development-publish-signed.yml** - Manual publishing to development registry (Cosign signed)

**Production Workflow:**
1. **axondb-search-build-and-test.yml** - Automatic testing on pushes/PRs to `main`
2. **axondb-search-publish-signed.yml** - Manual publishing to production registry (Cosign signed)

This approach ensures:
- Testing happens on both development and main branches
- Development images available for testing before production
- Manual control over all publishing
- Production releases are immutable and cryptographically signed

## Development Release Workflow

Use this workflow to publish images to the development registry for testing.

### 1. Development and Testing

Code changes are tested automatically:

```bash
# Create feature branch from development
git checkout development
git pull origin development
git checkout -b feature/my-feature

# Make changes and push
git add .
git commit -m "Add my feature"
git push origin feature/my-feature

# Create PR to development - tests run automatically
# Merge when tests pass
```

The `axondb-search-build-and-test.yml` workflow runs on:
- Push to `development` branch (when `axonops/axondb-search/**` changes)
- Pull requests to `development` (when `axonops/axondb-search/**` changes)

### 2. Publish Development Images (Optional)

To test images before promoting to production, publish to development registry:

```bash
# Tag on development branch
git checkout development
git pull origin development
git tag vdev-axondb-search-1.0.0
git push origin vdev-axondb-search-1.0.0

# Trigger development publish workflow (--ref development ensures correct branch)
gh workflow run axondb-search-development-publish-signed.yml \
  --ref development \
  -f dev_git_tag=vdev-axondb-search-1.0.0 \
  -f container_version=1.0.0
```

**Images published to (with 2D versioning):**
- `ghcr.io/axonops/development/axondb-search:3.3.2-1.0.0`
- `ghcr.io/axonops/development/axondb-search:3.3.2`
- `ghcr.io/axonops/development/axondb-search:latest`

**Testing development images:**
```bash
docker pull ghcr.io/axonops/development/axondb-search:3.3.2-1.0.0
docker run -d --name test -p 9200:9200 -p 9600:9600 ghcr.io/axonops/development/axondb-search:3.3.2-1.0.0
# Run tests, validate functionality
```

**Note:** Development images can be overwritten (no version validation). No GitHub Releases are created.

### 3. Promote to Production

When development images are tested and validated, promote to main:

```bash
# Create PR from development to main
gh pr create --base main --head development \
  --title "Release 1.0.0" \
  --body "Promote tested changes to production"

# After PR approved and merged, continue to production release (step 4)
```

---

## Production Release Workflow

### 4. Create Git Tag on Main Branch

**IMPORTANT:** Tags must be created on the `main` branch only. The publish workflow validates this.

When ready to release, create a git tag:

```bash
# Ensure you're on main branch and up to date
git checkout main
git pull origin main

# Tag the release commit
git tag axondb-search-3.3.2-1.0.0

# Push tag to remote
git push origin axondb-search-3.3.2-1.0.0
```

**Tag naming:** Recommended format: `axondb-search-<opensearch_version>-<axonops_version>` (e.g., `axondb-search-3.3.2-1.0.0`)

**Validation:** The publish workflow will verify the tag points to a commit on `main` branch. If you tag a commit from a feature branch, the workflow will fail.

### 5. Trigger Production Publish Workflow

#### Option A: Using GitHub UI

1. Go to **Actions** tab in GitHub
2. Select **AxonDB Search Publish Signed to GHCR** workflow
3. Click **Run workflow** button
4. Fill in inputs:
   - **main_git_tag**: The tag you created (e.g., `axondb-search-3.3.2-1.0.0`)
   - **container_version**: Container version (e.g., `1.0.0`)
5. Click **Run workflow**

#### Option B: Using GitHub CLI

```bash
# Install gh CLI if not already installed
# macOS: brew install gh
# Linux: https://github.com/cli/cli#installation

# Authenticate
gh auth login

# IMPORTANT: Ensure you're on main branch first
git checkout main
git pull origin main

# Trigger the signed workflow (--ref main ensures correct branch)
gh workflow run axondb-search-publish-signed.yml \
  --ref main \
  -f main_git_tag=axondb-search-3.3.2-1.0.0 \
  -f container_version=1.0.0

# Monitor workflow progress
gh run watch
```

### 6. Workflow Execution

The production workflow performs these steps:

1. **Validate** - Checks if `container_version` already exists in GHCR
   - Fails if any image tag `*-container_version` exists
   - Prevents accidental overwrites
   - Validates tag is on main branch

2. **Test** - Runs full test suite on the tagged code
   - Container build verification
   - Startup banner verification (production mode)
   - Version verification
   - Healthcheck tests
   - OpenSearch API and plugin tests
   - Security scanning (Trivy)

3. **Create Release** - Creates GitHub Release
   - Name: `axondb-search-<container_version>`
   - Tag: `<main_git_tag>`
   - Body: Image details and Cosign verification instructions

4. **Build** - Builds multi-arch images
   - Platforms: `linux/amd64`, `linux/arm64`
   - Full metadata in build-info.txt
   - Production release flag set to true

5. **Sign** - Cryptographically sign images with Cosign
   - Keyless signing using GitHub OIDC token
   - Signatures pushed to GHCR
   - Transparency log entries created

6. **Publish** - Pushes images to GHCR
   - Immutable tag: `3.3.2-1.0.0`
   - Floating tag: `3.3.2` (tracks latest AxonOps for this OpenSearch)
   - Global latest: `latest`
   - Registry: `ghcr.io/axonops/axondb-search`

7. **Verify** - Post-publish verification
   - Pulls image from GHCR (not local cache)
   - Verifies Cosign signature
   - Starts container and runs smoke tests
   - Validates healthcheck probes

### 7. Verify Release

Check that images were published:

```bash
# Check GHCR for published images
gh api /orgs/axonops/packages/container/axondb-search/versions | \
  jq '.[] | select(.metadata.container.tags[] | contains("1.0.0"))'

# Pull and test an image
docker pull ghcr.io/axonops/axondb-search:3.3.2-1.0.0
docker run -d --name axondb-search-test \
  -p 9200:9200 -p 9600:9600 \
  ghcr.io/axonops/axondb-search:3.3.2-1.0.0

# Wait for startup
docker logs -f axondb-search-test

# Test connectivity
curl -X GET "http://localhost:9200/_cluster/health?pretty"

# Cleanup
docker stop axondb-search-test
docker rm axondb-search-test
```

Check GitHub Release:

```bash
# List releases
gh release list

# View specific release
gh release view axondb-search-3.3.2-1.0.0
```

**Verify Signatures:**

All production images are signed. Verify before deployment:

```bash
# Install cosign if needed
# macOS: brew install cosign
# Linux: https://docs.sigstore.dev/cosign/installation

# Verify signature
cosign verify \
  --certificate-identity-regexp='https://github.com/axonops/axonops-containers' \
  --certificate-oidc-issuer='https://token.actions.githubusercontent.com' \
  ghcr.io/axonops/axondb-search:3.3.2-1.0.0

# Check signature exists
cosign tree ghcr.io/axonops/axondb-search:3.3.2-1.0.0
```

## Inputs Reference

### main_git_tag
**Required:** Yes
**Type:** String
**Description:** Git tag on main branch to checkout and build from

The workflow validates this tag is on main branch, then checks out this exact tag. This ensures you're publishing a frozen snapshot of code from main, not from a feature branch.

**Examples:**
- `axondb-search-3.3.2-1.0.0` (recommended)
- `axondb-search-1.0.0`
- `1.0.0`

### container_version
**Required:** Yes
**Type:** String
**Description:** Container version for published images in GHCR

This becomes the AxonOps version component in the 2D tag:
- `3.3.2-<container_version>` (e.g., `3.3.2-1.0.0`)

**Format:** Semantic versioning recommended (e.g., `1.0.0`, `1.2.3`, `2.0.0-beta`)

**Validation:** Workflow fails if any image with this version already exists in GHCR.

## Published Artifacts

Each release publishes:

### Container Images (GHCR)

**Production registry:**
- `ghcr.io/axonops/axondb-search:3.3.2-1.0.0` (immutable)
- `ghcr.io/axonops/axondb-search:3.3.2` (floating)
- `ghcr.io/axonops/axondb-search:latest` (floating)

**Development registry:**
- `ghcr.io/axonops/development/axondb-search:3.3.2-1.0.0`
- `ghcr.io/axonops/development/axondb-search:3.3.2`
- `ghcr.io/axonops/development/axondb-search:latest`

All images are multi-arch: `linux/amd64`, `linux/arm64`

### GitHub Release
- Name: `axondb-search-<container_version>`
- Tag: `<main_git_tag>`
- Body: Lists image tags, Cosign verification instructions, changelog

### Cosign Signatures
- Keyless signatures using GitHub OIDC
- Transparency log entries in Rekor
- Attestations pushed to GHCR

## Troubleshooting

### Version Already Exists

**Error:** `Container version X.Y.Z already exists in GHCR`

**Solution:**
- Use a different `container_version` (e.g., increment to next version)
- Or delete the existing release and images from GHCR if this was a mistake

**Delete and re-release:**
```bash
# Delete GitHub Release
gh release delete axondb-search-3.3.2-1.0.0 --yes

# Delete GHCR package version (via GitHub Packages UI)
# Navigate to: https://github.com/orgs/axonops/packages/container/axondb-search

# Re-run workflow with same inputs
```

### Tests Fail During Publish

**Error:** Tests fail in the publish workflow

**Solution:**
- The git tag has code that doesn't pass tests
- Fix the issues on `main` branch
- Create a new git tag pointing to the fixed commit
- Trigger publish workflow with the new tag

### Workflow Cannot Find Tag

**Error:** `fatal: reference is not a tree: <tag>`

**Solution:**
- Ensure you pushed the tag: `git push origin <tag>`
- Check tag exists: `git tag -l`
- Tag must exist in remote repository

### Tag Not on Main Branch

**Error:** `Tag X.Y.Z is not on main branch`

**Solution:**
- Tags must point to commits on `main` branch
- Merge your feature branch to main first
- Then create the tag on main:
  ```bash
  git checkout main
  git pull origin main
  git tag axondb-search-3.3.2-1.0.0
  git push origin axondb-search-3.3.2-1.0.0
  ```

### Image Push Fails

**Error:** Failed to push to GHCR

**Solution:**
- Check GitHub token permissions (should be automatic in Actions)
- Verify GHCR registry is accessible
- Re-run the workflow (images may have partially published)

### Signature Verification Fails

**Error:** Cosign verification fails after publish

**Solution:**
```bash
# Check signature was created
cosign tree ghcr.io/axonops/axondb-search:3.3.2-1.0.0

# Verify with verbose output
cosign verify \
  --certificate-identity-regexp='https://github.com/axonops/axonops-containers' \
  --certificate-oidc-issuer='https://token.actions.githubusercontent.com' \
  ghcr.io/axonops/axondb-search:3.3.2-1.0.0 \
  --verbose

# If signature missing, re-run publish workflow
```

## Re-releasing

If you need to re-publish the same version (e.g., image push failed):

1. Delete the existing GitHub Release: `gh release delete axondb-search-3.3.2-1.0.0`
2. Delete images from GHCR (via GitHub Packages UI)
3. Re-run the publish workflow with the same inputs

**Note:** Only do this for failed releases. Never overwrite successfully published releases.

## Versioning Strategy

### 2D Versioning

AxonDB Search uses 2D versioning: `OPENSEARCH_VERSION-AXONOPS_VERSION`

**Format:** `<OpenSearch major.minor.patch>-<AxonOps major.minor.patch>`

**Example:** `3.3.2-1.0.0`
- OpenSearch version: `3.3.2`
- AxonOps container version: `1.0.0`

This allows tracking:
- Which OpenSearch version is included
- Which AxonOps container version wraps it

### Semantic Versioning

The AxonOps version component follows semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR** - Breaking changes, incompatible changes
- **MINOR** - New features, backwards-compatible
- **PATCH** - Bug fixes, backwards-compatible

### Examples

- `3.3.2-1.0.0` - Initial stable release for OpenSearch 3.3.2
- `3.3.2-1.1.0` - New feature (e.g., new environment variable support)
- `3.3.2-1.1.1` - Bug fix (e.g., healthcheck script fix)
- `3.3.2-2.0.0` - Breaking change to container features
- `3.4.0-1.0.0` - Upgrade to OpenSearch 3.4.0

### When to Increment

**MAJOR (1.0.0 → 2.0.0):**
- New OpenSearch major version (3.x → 4.x)
- Removing environment variables
- Changing default behavior in breaking ways
- Removing initialization features

**MINOR (1.0.0 → 1.1.0):**
- Adding new environment variables
- Adding new features (e.g., new healthcheck mode)
- Adding new OpenSearch plugins
- Adding new initialization options

**PATCH (1.0.0 → 1.0.1):**
- Bug fixes in scripts
- Documentation updates
- Security patches (base image updates)
- OpenSearch patch updates (3.3.2 → 3.3.3)

### Pre-release Versions

Use suffixes for pre-releases:
- `3.3.2-1.0.0-alpha` - Alpha release
- `3.3.2-1.0.0-beta` - Beta release
- `3.3.2-1.0.0-rc1` - Release candidate

## Checklist

Before publishing:

- [ ] All tests passing on `main` branch
- [ ] Documentation updated (README.md, DEVELOPMENT.md)
- [ ] Git tag created and pushed
- [ ] `container_version` doesn't exist in GHCR
- [ ] Ready to make release public

During publishing:

- [ ] Workflow validation passed
- [ ] All tests passed on tagged code
- [ ] Images built successfully (multi-arch)
- [ ] Images pushed to GHCR
- [ ] Images signed with Cosign
- [ ] GitHub Release created
- [ ] Post-publish verification passed

After publishing:

- [ ] Verify images in GHCR
- [ ] Test pulling and running images
- [ ] Verify Cosign signatures
- [ ] Test healthcheck probes
- [ ] Test OpenSearch API connectivity
- [ ] Announce release (if applicable)
- [ ] Update documentation with new version numbers

## Release Cadence

**Recommended Release Schedule:**

- **Patch releases:** As needed for bug fixes and security updates
- **Minor releases:** Monthly or when new features accumulate
- **Major releases:** When OpenSearch major versions are released

**Security Updates:**
- Base image updates: Automated in Dockerfile, publish as PATCH
- OpenSearch security releases: Publish as PATCH (same major.minor)
- Plugin updates: Publish as MINOR

---

For development workflow and testing, see [DEVELOPMENT.md](./DEVELOPMENT.md).

For general usage and features, see [README.md](./README.md).
