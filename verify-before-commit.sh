#!/bin/bash
# Pre-Deployment Verification Script
# Run this before committing and pushing to Railway

echo "🔍 Starting Pre-Deployment Security Verification..."
echo ""

# Check 1: Verify .gitignore
echo "✓ Check 1: Verifying .gitignore contains sensitive patterns..."
if grep -q "\.env" .gitignore 2>/dev/null; then
    echo "  ✅ .env patterns are in .gitignore"
else
    echo "  ⚠️  Add these to .gitignore:"
    echo "     .env"
    echo "     *.env"
fi

# Check 2: Scan properties files for hardcoded secrets
echo ""
echo "✓ Check 2: Scanning property files for hardcoded credentials..."
secrets_found=false
for file in src/main/resources/application*.properties; do
    if [ -f "$file" ]; then
        if grep -E "password\s*=\s*[^$\{]|username\s*=\s*postgres|jdbc:postgresql://localhost" "$file" > /dev/null; then
            if [[ "$file" == *"dev"* ]] || [[ "$file" == *"local"* ]] || [[ "$file" == *"test"* ]]; then
                echo "  ⚠️  $(basename $file) has hardcoded values (OK for dev)"
            else
                echo "  ❌ $(basename $file) has potentially exposed credentials"
                secrets_found=true
            fi
        else
            echo "  ✅ $(basename $file) looks secure (uses environment variables)"
        fi
    fi
done

# Check 3: Look for hardcoded secrets in Java files
echo ""
echo "✓ Check 3: Scanning Java files for hardcoded credentials..."
if grep -r "password\s*=\s*['\`\"]" src/main/java/ 2>/dev/null | grep -v "//"; then
    echo "  ⚠️  Check above Java files for hardcoded credentials"
else
    echo "  ✅ No obvious hardcoded credentials in Java files"
fi

# Check 4: Verify Spring profiles exist
echo ""
echo "✓ Check 4: Verifying Spring profile files..."
for profile in dev railway; do
    if [ -f "src/main/resources/application-${profile}.properties" ]; then
        echo "  ✅ application-${profile}.properties exists"
    else
        echo "  ❌ application-${profile}.properties NOT FOUND"
    fi
done

# Check 5: Verify configuration files for Railway
echo ""
echo "✓ Check 5: Verifying Railway deployment files..."
for file in Dockerfile Procfile .railway.json; do
    if [ -f "$file" ]; then
        echo "  ✅ $file exists"
    else
        echo "  ⚠️  $file NOT FOUND (optional but recommended)"
    fi
done

# Check 6: Check git status
echo ""
echo "✓ Check 6: Checking Git status..."
echo "  Changes to commit:"
git status --porcelain | sed 's/^/    /'

# Summary
echo ""
echo "================================"
if [ "$secrets_found" = true ]; then
    echo "❌ VERIFICATION FAILED - Found exposed credentials!"
    echo "   Do NOT commit until separated into environment variables"
else
    echo "✅ PRE-DEPLOYMENT VERIFICATION PASSED"
    echo "   Safe to commit and deploy to Railway"
fi
echo "================================"

echo ""
echo "📋 Next steps:"
echo "  1. git add ."
echo "  2. git commit -m 'feat: Add Spring profiles and Railway deployment'"
echo "  3. git push origin main"
echo "  4. Set SPRING_PROFILES_ACTIVE=railway in Railway Dashboard"
