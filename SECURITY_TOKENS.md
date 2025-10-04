# 🔐 TAKERMAN Security Guide - Managing GitHub Tokens

## ✅ Your GitHub PAT Has Been Secured!

The hardcoded GitHub Personal Access Token has been removed from the source code and replaced with environment variable usage.

## 🚨 IMMEDIATE ACTION REQUIRED

**1. Revoke the Exposed Token**
- Go to GitHub → Settings → Developer Settings → Personal Access Tokens
- Find token: `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`
- **REVOKE IT IMMEDIATELY** (it's already exposed in git history)

**2. Create a New Token**
- Generate a new Personal Access Token
- Required scopes: `read:packages`, `write:packages`, `repo` (if accessing private repos)

## 📝 How to Use the New Secure Setup

### Method 1: Environment Variable (Recommended)

```bash
# Set temporarily
export GITHUB_TOKEN=your_new_github_pat_here

# Set permanently (add to ~/.bashrc)
echo 'export GITHUB_TOKEN=your_new_github_pat_here' >> ~/.bashrc
source ~/.bashrc
```

### Method 2: .env File (For Development)

```bash
# Create .env file in project root
echo "GITHUB_TOKEN=your_new_github_pat_here" > .env

# Load it before running scripts
source .env
./docker/build.sh jupyter
```

### Method 3: GitHub Secrets (For CI/CD)

```yaml
# In GitHub Actions workflow
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 🔧 Updated Script Usage

### Building Docker Images

```bash
# With token (will push to registry)
export GITHUB_TOKEN=your_token
./docker/build.sh jupyter

# Without token (local build only)
./docker/build.sh jupyter
```

### AI Setup Script

The `ai_setup.sh` script will now:
- ✅ Login to GitHub registry if `GITHUB_TOKEN` is provided
- ⚠️ Skip registry login if token is missing (with warning)
- Continue with installation regardless

## 🛡️ Security Best Practices

### ✅ DO
- Use environment variables for tokens
- Use `.env` files for local development (they're in `.gitignore`)
- Regularly rotate your tokens
- Use minimal required scopes for tokens
- Store tokens in secure password managers

### ❌ DON'T
- Commit tokens to git (ever!)
- Share tokens in chat/email
- Use tokens with excessive permissions
- Leave old tokens active after creating new ones

## 🔍 Files That Were Secured

1. **`docker/build.sh`** - Now uses `$GITHUB_TOKEN` environment variable
2. **`scripts/ai_setup.sh`** - Now checks for token before attempting login
3. **`.gitignore`** - Updated to prevent future token commits

## 🧹 Cleaning Git History (Optional)

If you want to remove the token from git history completely:

```bash
# Use git filter-branch or BFG Repo-Cleaner
# WARNING: This rewrites history and affects all collaborators
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch docker/build.sh' \
  --prune-empty --tag-name-filter cat -- --all

# Force push (use with caution!)
git push --force --all
```

## ✅ Verification

Test that everything works:

```bash
# Set your new token
export GITHUB_TOKEN=your_new_token

# Test docker build
cd docker
./build.sh jupyter

# Should see: "✅ Image pushed to ghcr.io/takermanltd/takerman.jupyter:latest"
```

Your TAKERMAN AI Server is now secure! 🎉